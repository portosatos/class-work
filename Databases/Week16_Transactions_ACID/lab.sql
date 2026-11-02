-- Week 16: Transactions and ACID Properties
-- Topics: BEGIN / COMMIT / ROLLBACK, the four ACID properties shown on a
--         bank transfer, isolation levels with a real second session,
--         savepoints, error handling in PL/pgSQL, and lock monitoring.
--
-- The isolation demos need two sessions at once. The second session is a
-- real separate connection opened with the dblink extension.
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


DROP TABLE IF EXISTS order_items, orders, customers, accounts, products, logs, inventory;
CREATE EXTENSION IF NOT EXISTS dblink;
SELECT dblink_disconnect(unnest(dblink_get_connections()));


CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    owner      VARCHAR(50),
    balance    NUMERIC(12,2) NOT NULL CHECK (balance >= 0)   -- no overdrafts
);
INSERT INTO accounts VALUES (1, 'Aibek', 1000.00), (2, 'Ainura', 500.00), (3, 'Bakyt', 2000.00);


-- ============================================================
-- 1. COMMIT and ROLLBACK
-- ============================================================
-- COMMIT: both updates are saved
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;
SELECT * FROM accounts ORDER BY account_id;

-- ROLLBACK: both updates are undone
BEGIN TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
SELECT * FROM accounts ORDER BY account_id;   -- inside: 800 / 700
ROLLBACK;
SELECT * FROM accounts ORDER BY account_id;   -- back to 900 / 600

-- a full transfer of 500 from account 1 to account 2
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 1;   -- 900, enough
UPDATE accounts SET balance = balance - 500 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 500 WHERE account_id = 2;
COMMIT;
SELECT * FROM accounts ORDER BY account_id;


-- ============================================================
-- 2. Atomicity: all or nothing
-- ============================================================
CREATE TABLE customers (customer_id SERIAL PRIMARY KEY, name VARCHAR(50), email VARCHAR(100));
CREATE TABLE orders    (id SERIAL PRIMARY KEY, customer_id INT REFERENCES customers(customer_id), total NUMERIC(10,2));
CREATE TABLE inventory (product_id INT PRIMARY KEY, stock INT CHECK (stock >= 0));
CREATE TABLE order_items (order_id INT REFERENCES orders(id), product_id INT REFERENCES inventory(product_id), quantity INT);
INSERT INTO customers (name, email) VALUES ('Aibek', 'aibek@mail.kg');
INSERT INTO inventory VALUES (101, 1);    -- only ONE item in stock

-- the order asks for 2 items: the stock update violates the CHECK,
-- so the order and its items, inserted before, disappear as well
BEGIN;
INSERT INTO orders (customer_id, total) VALUES (1, 250.00);
INSERT INTO order_items (order_id, product_id, quantity) VALUES (1, 101, 2);
UPDATE inventory SET stock = stock - 2 WHERE product_id = 101;     -- FAILS
SELECT * FROM orders;     -- FAILS too: the transaction is aborted
COMMIT;                   -- reported as ROLLBACK

SELECT count(*) AS orders_saved FROM orders;
SELECT * FROM inventory;

-- by contrast, in autocommit mode each statement commits on its own
INSERT INTO orders (customer_id, total) VALUES (1, 250.00);
INSERT INTO order_items (order_id, product_id, quantity) VALUES (currval('orders_id_seq'), 101, 2);
UPDATE inventory SET stock = stock - 2 WHERE product_id = 101;     -- FAILS
SELECT count(*) AS orders_saved_without_transaction FROM orders;   -- half an order is left behind
TRUNCATE order_items, orders RESTART IDENTITY;


-- ============================================================
-- 3. Consistency: constraints hold at every commit
-- ============================================================
-- an overdraft would break CHECK (balance >= 0): the whole transfer is refused
BEGIN;
UPDATE accounts SET balance = balance + 5000 WHERE account_id = 2;
UPDATE accounts SET balance = balance - 5000 WHERE account_id = 1;   -- FAILS
COMMIT;
SELECT * FROM accounts ORDER BY account_id;   -- account 2 did NOT get 5000

-- foreign keys too: the order points to the customer created just before it
BEGIN;
INSERT INTO customers (name, email) VALUES ('John Doe', 'john@email.com');
INSERT INTO orders (customer_id, total) VALUES (currval('customers_customer_id_seq'), 100.00);
COMMIT;
SELECT o.id, c.name, o.total FROM orders o JOIN customers c USING (customer_id);


-- ============================================================
-- 4. Isolation: a second, concurrent session
-- ============================================================
-- The connection string needs the password; it is taken from PGPASSWORD
-- and the statement is not echoed, so it never lands in a file.
\getenv pgpw PGPASSWORD
\if :{?pgpw}
\else
    \set pgpw ''
\endif
\set echo_saved :ECHO
\set ECHO none
SELECT dblink_connect('other', format('dbname=%s user=%s host=localhost port=%s password=%s',
                      current_database(), current_user, current_setting('port'), :'pgpw'));
SELECT dblink_connect('third', format('dbname=%s user=%s host=localhost port=%s password=%s',
                      current_database(), current_user, current_setting('port'), :'pgpw'));
\set ECHO :echo_saved
SELECT dblink_get_connections() AS open_sessions;

-- 4a. No dirty reads, even with READ UNCOMMITTED
--     (PostgreSQL treats READ UNCOMMITTED as READ COMMITTED)
SELECT dblink_exec('other', 'BEGIN');
SELECT dblink_exec('other', 'UPDATE accounts SET balance = 0 WHERE account_id = 3');  -- not committed

BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT balance AS we_still_see FROM accounts WHERE account_id = 3;   -- 2000, not 0
COMMIT;
SELECT dblink_exec('other', 'ROLLBACK');

-- 4b. READ COMMITTED (default): a non-repeatable read
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance AS first_read FROM accounts WHERE account_id = 3;
SELECT dblink_exec('other', 'UPDATE accounts SET balance = balance + 1 WHERE account_id = 3');  -- autocommit
SELECT balance AS second_read FROM accounts WHERE account_id = 3;    -- changed inside our transaction
COMMIT;

-- 4c. REPEATABLE READ: the same query gives the same answer
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT balance AS first_read FROM accounts WHERE account_id = 3;
SELECT dblink_exec('other', 'UPDATE accounts SET balance = balance + 1 WHERE account_id = 3');
SELECT balance AS second_read FROM accounts WHERE account_id = 3;    -- unchanged: our snapshot
-- writing the row the other session changed is refused
UPDATE accounts SET balance = balance - 10 WHERE account_id = 3;
ROLLBACK;
SELECT balance AS after_rollback FROM accounts WHERE account_id = 3;

-- 4d. Phantom rows: READ COMMITTED sees a new row, REPEATABLE READ does not
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT count(*) AS rich_accounts FROM accounts WHERE balance > 1000;
SELECT dblink_exec('other', 'INSERT INTO accounts VALUES (4, ''Gulzat'', 3000)');
SELECT count(*) AS rich_accounts FROM accounts WHERE balance > 1000;  -- a phantom appeared
COMMIT;
DELETE FROM accounts WHERE account_id = 4;

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) AS rich_accounts FROM accounts WHERE balance > 1000;
SELECT dblink_exec('other', 'INSERT INTO accounts VALUES (4, ''Gulzat'', 3000)');
SELECT count(*) AS rich_accounts FROM accounts WHERE balance > 1000;  -- no phantom
COMMIT;
DELETE FROM accounts WHERE account_id = 4;

-- 4e. SERIALIZABLE: two transactions that cannot both be right
--     Rule: accounts 1 and 2 together must keep at least 500 (now 400 + 1100).
--     Each session reads the sum (1500) and decides its withdrawal is safe:
--     we take 300 from account 1, the other session takes 900 from account 2.
--     Each alone leaves >= 500; both together leave 300 -- a "write skew".
SELECT * FROM accounts WHERE account_id IN (1, 2) ORDER BY account_id;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT sum(balance) AS seen_by_us FROM accounts WHERE account_id IN (1, 2);

SELECT dblink_exec('other', 'BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE');
SELECT * FROM dblink('other', 'SELECT sum(balance) FROM accounts WHERE account_id IN (1, 2)') AS t(seen_by_other numeric);
SELECT dblink_exec('other', 'UPDATE accounts SET balance = balance - 900 WHERE account_id = 2');
SELECT dblink_exec('other', 'COMMIT');      -- the other session wins

SELECT sum(balance) AS still_seen_by_us FROM accounts WHERE account_id IN (1, 2);
UPDATE accounts SET balance = balance - 300 WHERE account_id = 1;   -- FAILS: could not serialize
COMMIT;                                     -- turns into ROLLBACK
SELECT * FROM accounts WHERE account_id IN (1, 2) ORDER BY account_id;

-- put the money back for the rest of the lab
UPDATE accounts SET balance = balance + 900 WHERE account_id = 2;

-- session default instead of per transaction
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW default_transaction_isolation;
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- SET TRANSACTION must be the first statement inside the transaction
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW transaction_isolation;
COMMIT;


-- ============================================================
-- 5. Durability
-- ============================================================
-- A COMMIT returns only after the change is written to the WAL on disk.
SHOW synchronous_commit;
SHOW fsync;
SELECT pg_current_wal_lsn() AS wal_position_before;
BEGIN;
UPDATE accounts SET balance = balance + 0.01 WHERE account_id = 3;
COMMIT;
SELECT pg_current_wal_lsn() AS wal_position_after;
-- the WAL position moved: the commit record is on disk, so the change
-- would be replayed after a crash or restart
SELECT balance AS committed_balance FROM accounts WHERE account_id = 3;


-- ============================================================
-- 6. Savepoints
-- ============================================================
TRUNCATE customers, orders, order_items RESTART IDENTITY;

BEGIN;
INSERT INTO customers (name, email) VALUES ('Alice', 'alice@email.com');
SAVEPOINT after_customer_insert;
INSERT INTO orders (customer_id, total) VALUES (1, 500.00);
-- something was wrong with the order
ROLLBACK TO SAVEPOINT after_customer_insert;
INSERT INTO orders (customer_id, total) VALUES (1, 300.00);
COMMIT;
SELECT * FROM customers;
SELECT * FROM orders;      -- only the 300.00 order

-- several savepoints; a failed statement is undone without losing the rest
CREATE TABLE products (id SERIAL PRIMARY KEY, name VARCHAR(50), price NUMERIC(10,2) CHECK (price > 0));
BEGIN;
INSERT INTO products (name, price) VALUES ('Laptop', 999.99);
SAVEPOINT sp1;
INSERT INTO products (name, price) VALUES ('Mouse', 25.99);
SAVEPOINT sp2;
INSERT INTO products (name, price) VALUES ('Invalid Product', -50.00);   -- FAILS: CHECK
ROLLBACK TO SAVEPOINT sp2;
INSERT INTO products (name, price) VALUES ('Keyboard', 79.99);
COMMIT;
SELECT * FROM products ORDER BY id;

-- RELEASE SAVEPOINT: forget a savepoint that is no longer needed
CREATE TABLE logs (id SERIAL PRIMARY KEY, message TEXT, logged_at TIMESTAMPTZ DEFAULT now());
BEGIN;
INSERT INTO logs (message) VALUES ('Starting process');
SAVEPOINT process_start;
INSERT INTO logs (message) VALUES ('Process completed');
RELEASE SAVEPOINT process_start;
ROLLBACK TO SAVEPOINT process_start;     -- FAILS: it was released
ROLLBACK;
SELECT count(*) AS logs_after_rollback FROM logs;


-- ============================================================
-- 7. Error handling in PL/pgSQL
-- ============================================================
-- A DO block runs as one unit. RAISE EXCEPTION aborts it and undoes its
-- changes; an EXCEPTION section catches the error and rolls back only
-- what happened inside the block.
DO $$
DECLARE
    current_balance NUMERIC;
BEGIN
    SELECT balance INTO current_balance FROM accounts WHERE account_id = 2;
    IF current_balance < 5000 THEN
        RAISE EXCEPTION 'Insufficient funds: % < 5000', current_balance;
    END IF;
    UPDATE accounts SET balance = balance - 5000 WHERE account_id = 2;
    UPDATE accounts SET balance = balance + 5000 WHERE account_id = 1;
END $$;

DO $$
BEGIN
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 1;
    UPDATE accounts SET balance = balance - 99999 WHERE account_id = 2;   -- violates CHECK
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'Transfer failed, nothing was changed: %', SQLERRM;
END $$;

SELECT * FROM accounts ORDER BY account_id;


-- ============================================================
-- 8. Monitoring locks
-- ============================================================
-- the other session locks account 1 and keeps its transaction open;
-- our UPDATE would then wait, so it is sent asynchronously
SELECT dblink_exec('other', 'BEGIN');
SELECT dblink_exec('other', 'UPDATE accounts SET balance = balance WHERE account_id = 1');
SELECT dblink_send_query('third', 'UPDATE accounts SET balance = balance + 1 WHERE account_id = 1');
SELECT pg_sleep(0.5);

SELECT blocked_activity.pid             AS blocked_pid,
       blocked_activity.usename         AS blocked_user,
       blocking.pid                     AS blocking_pid,
       blocked_activity.query           AS blocked_statement
FROM pg_stat_activity blocked_activity
CROSS JOIN LATERAL unnest(pg_blocking_pids(blocked_activity.pid)) AS blocking(pid)
WHERE blocked_activity.datname = current_database();

SELECT dblink_exec('other', 'COMMIT');        -- releases the lock
SELECT * FROM dblink_get_result('third') AS t(result text);
SELECT dblink_disconnect('third');
SELECT dblink_disconnect('other');


-- ============================================================
-- clean up
-- ============================================================
DROP TABLE order_items, orders, customers, accounts, products, logs, inventory;
DROP EXTENSION dblink;
