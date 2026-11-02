-- Week 12: Querying Data
-- Topics: SELECT, computed columns and aliases, WHERE with comparison /
--         logical / range / NULL operators, LIKE and ILIKE, regular
--         expressions, IN and EXISTS, CASE, CTEs, ORDER BY, LIMIT, DISTINCT.
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


DROP TABLE IF EXISTS sales, employees, departments, products, customers, users;


-- ============================================================
-- data
-- ============================================================
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name          VARCHAR(50)
);
INSERT INTO departments VALUES
(1, 'Sales'), (2, 'Engineering'), (3, 'Marketing'), (4, 'HR'), (5, 'Finance');

CREATE TABLE employees (
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(50) NOT NULL,
    department    VARCHAR(50),
    department_id INT REFERENCES departments(department_id),
    salary        NUMERIC(10,2),
    hire_date     DATE,
    phone         VARCHAR(20)
);
INSERT INTO employees (name, department, department_id, salary, hire_date, phone) VALUES
('Aibek',   'Sales',       1,  52000, '2021-03-15', '0555-100100'),
('Ainura',  'Engineering', 2,  98000, '2019-07-01', NULL),
('Bakyt',   'Engineering', 2,  76000, '2022-01-10', '0700-200200'),
('Bermet',  'Marketing',   3,  61000, '2020-11-20', NULL),
('Gulzat',  'Sales',       1,  47000, '2023-05-05', '0777-300300'),
('Azamat',  'Engineering', 2, 120000, '2017-02-14', '0555-400400'),
('Meerim',  'HR',          4,  55000, '2021-09-01', NULL),
('Nurlan',  'Finance',     5, 105000, '2018-04-30', '0700-500500'),
('Aidai',   'Sales',       1,  83000, '2019-12-12', '0777-600600');

CREATE TABLE sales (
    sale_id     SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    amount      NUMERIC(10,2),
    sale_date   DATE
);
INSERT INTO sales (employee_id, amount, sale_date) VALUES
(1,  800, '2026-09-01'), (1, 1500, '2026-09-15'), (5,  300, '2026-09-20'),
(9, 2500, '2026-10-02'), (9,  900, '2026-10-10'), (5, 1200, '2026-10-21');

CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(50),
    price        NUMERIC(8,2)
);
INSERT INTO products (product_name, price) VALUES
('Strawberry jam', 12.50), ('Blueberry muffin', 24.00), ('Raspberry tart', 35.90),
('Apple juice', 8.00), ('Cheesecake', 49.99), ('Chocolate cake', 55.00),
('Blackberry pie', 20.00);

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    customer_name VARCHAR(50)
);
INSERT INTO customers (customer_name) VALUES
('Brad'), ('Brandon'), ('Bryan'), ('Abraham'), ('bradley'), ('Alice');

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email   VARCHAR(100)
);
INSERT INTO users (email) VALUES
('aibek@gmail.com'), ('AINURA@GMAIL.COM'), ('bakyt@mail.ru'),
('broken-email@'), ('meerim@alatoo.edu.kg'), ('no at sign.com');


-- ============================================================
-- 1. SELECT
-- ============================================================
SELECT * FROM employees;

SELECT name, department FROM employees;

-- calculation on the fly, renamed with AS
SELECT name, salary, salary * 0.10 AS potential_bonus
FROM employees;

-- DISTINCT, ORDER BY, LIMIT
SELECT DISTINCT department FROM employees ORDER BY department;

SELECT name, salary FROM employees ORDER BY salary DESC LIMIT 3;


-- ============================================================
-- 2. WHERE
-- ============================================================
SELECT name, salary FROM employees WHERE department = 'Sales';

SELECT name FROM employees WHERE salary > 75000 AND department = 'Engineering';

SELECT name, department FROM employees
WHERE department = 'HR' OR department = 'Finance';

SELECT name, department FROM employees WHERE NOT department = 'Engineering';

SELECT name, department FROM employees WHERE department <> 'Sales';

SELECT product_name, price FROM products WHERE price BETWEEN 20 AND 50;

-- NULL is never "= NULL"; it needs IS NULL / IS NOT NULL
SELECT name FROM employees WHERE phone = NULL;        -- 0 rows!
SELECT name FROM employees WHERE phone IS NULL;
SELECT count(*) AS with_phone FROM employees WHERE phone IS NOT NULL;


-- ============================================================
-- 3. LIKE and ILIKE
-- ============================================================
-- % = any number of characters, _ = exactly one
SELECT customer_name FROM customers WHERE customer_name LIKE 'Bra%';

SELECT customer_name FROM customers WHERE customer_name ILIKE 'bra%';   -- also 'bradley'

SELECT product_name FROM products WHERE product_name LIKE '%berry%';

SELECT customer_name FROM customers WHERE customer_name LIKE 'Br_an%';  -- Bryan

SELECT email FROM users WHERE email ILIKE '%@gmail.com';


-- ============================================================
-- 4. Regular expressions
-- ============================================================
SELECT name FROM employees WHERE name ~ '^[AB]';           -- starts with A or B

SELECT name FROM employees WHERE name ~* '^a.*k$';         -- case-insensitive

-- a simple validity check of e-mail addresses
SELECT email,
       email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$' AS looks_valid
FROM users;

SELECT email FROM users
WHERE email !~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$';   -- the invalid ones


-- ============================================================
-- 5. IN and EXISTS
-- ============================================================
SELECT name, department FROM employees WHERE department_id IN (3, 4, 5);

-- IN with a subquery: employees who made a sale over 1000
SELECT name FROM employees
WHERE id IN (SELECT employee_id FROM sales WHERE amount > 1000);

-- the same question with EXISTS (stops at the first matching sale)
SELECT name FROM employees e
WHERE EXISTS (
    SELECT 1 FROM sales s
    WHERE s.employee_id = e.id AND s.amount > 1000
);

-- NOT EXISTS: sales people with no sales at all
SELECT name FROM employees e
WHERE department = 'Sales'
  AND NOT EXISTS (SELECT 1 FROM sales s WHERE s.employee_id = e.id);


-- ============================================================
-- 6. CASE
-- ============================================================
SELECT name, salary,
    CASE
        WHEN salary > 100000 THEN 'Senior'
        WHEN salary BETWEEN 60000 AND 100000 THEN 'Mid-Level'
        ELSE 'Junior'
    END AS employee_level
FROM employees
ORDER BY salary DESC;


-- ============================================================
-- 7. Common Table Expressions (WITH)
-- ============================================================
-- employees who earn more than the average of their own department
WITH department_averages AS (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
)
SELECT e.name, e.salary, e.department, ROUND(da.avg_salary, 2) AS avg_salary
FROM employees e
JOIN department_averages da ON e.department = da.department
WHERE e.salary > da.avg_salary;


-- ============================================================
-- clean up
-- ============================================================
DROP TABLE sales, employees, departments, products, customers, users;
