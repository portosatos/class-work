-- Week 17: Data Import/Export and Backup -- part 1, COPY
-- Topics: COPY TO / COPY FROM (server side), \copy (client side), CSV
--         options (HEADER, DELIMITER, NULL, QUOTE, ESCAPE, FORCE_QUOTE,
--         ENCODING, ON_ERROR IGNORE), exporting a query, and an ETL load
--         through a staging table with ON CONFLICT.
--
-- Builds the "company" database that backup.sh (part 2) then backs up.
--
-- Run with (from this folder):
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


DROP DATABASE IF EXISTS company;
DROP DATABASE IF EXISTS company_restored;
CREATE DATABASE company;
\c company


-- ============================================================
-- data
-- ============================================================
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    name          VARCHAR(50) UNIQUE NOT NULL
);
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    email       VARCHAR(100),
    department  VARCHAR(50),
    hire_date   DATE
);
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name       VARCHAR(50),
    category   VARCHAR(50),
    price      NUMERIC(10,2)
);
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name        VARCHAR(100),
    email       VARCHAR(100)
);
CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date  DATE,
    total       NUMERIC(10,2)
);
CREATE TABLE customer_feedback (
    id      SERIAL PRIMARY KEY,
    author  VARCHAR(50),
    comment TEXT
);
CREATE TABLE sales_data (
    sale_id INT PRIMARY KEY,
    region  VARCHAR(20),
    amount  NUMERIC(10,2),
    note    TEXT
);
CREATE TABLE log_table (
    id      SERIAL PRIMARY KEY,
    message TEXT
);

INSERT INTO departments (name) VALUES ('IT'), ('Sales'), ('HR');
INSERT INTO employees (first_name, last_name, email, department, hire_date) VALUES
('Aibek',  'Sharshenov', 'aibek@corp.kg',  'IT',    '2021-03-15'),
('Ainura', 'Toktomamatova', NULL,          'IT',    '2022-07-01'),
('Bakyt',  'Mamatov',    'bakyt@corp.kg',  'Sales', '2020-01-10'),
('Gulzat', 'Sultanova',  'gulzat@corp.kg', 'HR',    '2023-05-05');
INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 1200.00), (2, 'Mouse', 'Electronics', 20.00),
(3, 'Desk', 'Furniture', 300.00);
INSERT INTO customers VALUES
(1, 'Aibek Sharshenov', 'aibek@mail.kg'),
(2, 'Ainura Toktomamatova', 'ainura@mail.kg'),
(3, 'Bakyt Mamatov', 'bakyt@mail.kg');
INSERT INTO orders (customer_id, order_date, total) VALUES
(1, '2026-10-01', 1220.00), (2, '2026-10-03', 300.00), (1, '2026-10-20', 20.00);
INSERT INTO customer_feedback (author, comment) VALUES
('Aibek',  'Fast delivery, great price'),
('Ainura', 'The box said "fragile", it was not packed well'),
('Bakyt',  'Fine, thanks');
INSERT INTO log_table (message)
SELECT 'log line ' || g FROM generate_series(1, 1000) g;


-- ============================================================
-- 1. COPY TO / COPY FROM on the server
-- ============================================================
-- COPY runs inside the server process: the path is on the SERVER's disk,
-- must be absolute, and the server's OS account must be able to write there.
-- The server's own data directory always qualifies, so the files go there.
SELECT current_setting('data_directory') AS datadir \gset
\set emp_csv :datadir '/lab17_employees.csv'
\set emp_txt :datadir '/lab17_employees.txt'
\set it_csv  :datadir '/lab17_it_employees.csv'

COPY employees TO :'emp_csv' WITH CSV HEADER;

-- read the file back (it lives on the server, so pg_read_file can see it)
SELECT pg_read_file(:'emp_csv');

-- import it into an empty copy of the table
CREATE TABLE employees_copy (LIKE employees);
COPY employees_copy FROM :'emp_csv' WITH CSV HEADER;
SELECT * FROM employees_copy;

-- custom delimiter and NULL marker
COPY employees TO :'emp_txt' WITH DELIMITER '|' NULL 'N/A' CSV HEADER;
SELECT pg_read_file(:'emp_txt');

-- the result of a query instead of a whole table
COPY (SELECT * FROM employees WHERE department = 'IT') TO :'it_csv' WITH CSV HEADER;
SELECT pg_read_file(:'it_csv');

-- a relative path is refused
COPY employees TO 'employees.csv' WITH CSV HEADER;


-- ============================================================
-- 2. \copy: the same, but files on the CLIENT side
-- ============================================================
-- psql reads/writes the file and streams it through the connection, so
-- the files below are in this folder (exports/, data/), not on the server.
\copy products TO 'exports/products.csv' WITH CSV HEADER
\copy customers TO 'exports/customers.csv' WITH CSV HEADER DELIMITER ';' QUOTE '"'
\copy orders TO 'exports/orders.csv' WITH (FORMAT csv, HEADER, FORCE_QUOTE (order_date))
\copy customer_feedback TO 'exports/feedback.csv' WITH CSV HEADER DELIMITER ',' QUOTE '"' ESCAPE '"'
\copy (SELECT department, count(*) AS employees FROM employees GROUP BY department ORDER BY 1) TO 'exports/employees_per_department.csv' WITH CSV HEADER

-- import specific columns only: employee_id and the rest come from defaults
\copy employees(first_name, last_name, email) FROM 'data/new_employees.csv' WITH CSV HEADER
SELECT employee_id, first_name, last_name, email, department FROM employees ORDER BY employee_id;

-- a custom NULL marker on import: the word NULL in the file becomes SQL NULL
\copy sales_data FROM 'data/sales.csv' WITH CSV HEADER NULL 'NULL' ENCODING 'UTF8'
SELECT sale_id, region, amount, note, note IS NULL AS note_is_null FROM sales_data;


-- ============================================================
-- 3. Bad rows: stop, or skip them with ON_ERROR IGNORE
-- ============================================================
-- by default one bad row aborts the whole COPY and nothing is loaded
\copy products FROM 'data/products_with_errors.csv' WITH CSV HEADER
SELECT count(*) AS products_after_failed_copy FROM products;

-- PostgreSQL 17+: skip the rows that do not convert, load the rest
\copy products FROM 'data/products_with_errors.csv' WITH (FORMAT csv, HEADER, ON_ERROR ignore, LOG_VERBOSITY verbose)
SELECT * FROM products ORDER BY product_id;


-- ============================================================
-- 4. ETL: extract in batches, load into staging, merge
-- ============================================================
-- staging table with the same columns and no rows
CREATE TABLE staging_customers AS SELECT * FROM customers WHERE 1 = 0;

-- extract a batch (LIMIT / OFFSET) -- here everything fits in one
\copy (SELECT * FROM customers ORDER BY customer_id LIMIT 10000 OFFSET 0) TO 'exports/customers_batch_1.csv' WITH CSV HEADER

-- an incoming file with one changed e-mail and two new customers
\copy staging_customers FROM 'data/customers_update.csv' WITH CSV HEADER
SELECT * FROM staging_customers;

-- validate: no duplicates, no missing e-mails
SELECT count(*) AS rows, count(DISTINCT customer_id) AS distinct_ids,
       count(*) FILTER (WHERE email IS NULL) AS missing_emails
FROM staging_customers;

-- merge: insert new, update existing
INSERT INTO customers
SELECT * FROM staging_customers
ON CONFLICT (customer_id) DO UPDATE
SET name = EXCLUDED.name, email = EXCLUDED.email;

SELECT * FROM customers ORDER BY customer_id;
DROP TABLE staging_customers, employees_copy;


-- ============================================================
-- 5. WAL, restore points and backup monitoring
-- ============================================================
SHOW wal_level;
SHOW archive_mode;

-- a named point that point-in-time recovery could stop at
SELECT pg_create_restore_point('before_data_migration');

-- force a switch to a new WAL segment (what archiving would pick up)
SELECT pg_walfile_name(pg_current_wal_lsn()) AS wal_file_before;
SELECT pg_switch_wal();
SELECT pg_walfile_name(pg_current_wal_lsn()) AS wal_file_after;

-- pre-migration check: row counts per table
SELECT relname AS table_name, n_live_tup AS rows
FROM pg_stat_user_tables ORDER BY relname;

\dt
\c ulan
