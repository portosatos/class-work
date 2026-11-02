-- Week 15: Advanced Querying
-- Topics: scalar / row / table / correlated subqueries, CTEs, recursive
--         CTEs, UNION / UNION ALL / INTERSECT / EXCEPT, window functions
--         (ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, running totals),
--         pivot and unpivot, FILTER, custom sort order, EXPLAIN / ANALYZE.
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


DROP TABLE IF EXISTS employees, orders, warehouse_1, warehouse_2,
                     sales, pivoted_sales, tickets, big_orders;


-- ============================================================
-- data
-- ============================================================
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    department  VARCHAR(50),
    salary      NUMERIC(10,2),
    tenure      INT,                 -- years in the company
    manager_id  INT REFERENCES employees(employee_id)
);
INSERT INTO employees (first_name, last_name, department, salary, tenure, manager_id) VALUES
('Azamat', 'Uulu',          'Management',  150000, 12, NULL),   -- 1 CEO
('Ainura', 'Toktomamatova', 'Engineering', 110000,  8, 1),      -- 2
('Nurlan', 'Isakov',        'Sales',        90000,  6, 1),      -- 3
('Bakyt',  'Mamatov',       'Engineering',  85000,  4, 2),      -- 4
('Meerim', 'Bekova',        'Engineering',  85000,  3, 2),      -- 5
('Aibek',  'Sharshenov',    'Engineering',  70000,  1, 4),      -- 6
('Aidai',  'Kadyrova',      'Sales',        72000,  7, 3),      -- 7
('Tilek',  'Usubaliev',     'Sales',        48000,  1, 3),      -- 8
('Gulzat', 'Sultanova',     'Sales',        48000,  2, 7);      -- 9

CREATE TABLE orders (
    order_id  SERIAL PRIMARY KEY,
    region_id INT,
    amount    NUMERIC(12,2),
    status    VARCHAR(20),
    order_date DATE
);
INSERT INTO orders (region_id, amount, status, order_date) VALUES
(1, 600000, 'Low Priority',    '2026-10-01'),
(1, 550000, 'High Priority',   '2026-10-02'),
(2, 300000, 'Medium Priority', '2026-10-02'),
(2, 200000, 'Shipped',         '2026-10-03'),
(3, 900000, 'High Priority',   '2026-10-04'),
(3, 400000, 'Low Priority',    '2026-10-05'),
(4,  50000, 'Medium Priority', '2026-10-06');

CREATE TABLE warehouse_1 (product_id INT, product_name VARCHAR(50), quantity INT);
CREATE TABLE warehouse_2 (product_id INT, product_name VARCHAR(50), quantity INT);
INSERT INTO warehouse_1 VALUES (1, 'Laptop', 0), (2, 'Mouse', 15), (3, 'Monitor', 0), (4, 'Keyboard', 7);
INSERT INTO warehouse_2 VALUES (1, 'Laptop', 0), (3, 'Monitor', 4), (5, 'Webcam', 0), (4, 'Keyboard', 0);

CREATE TABLE sales (product_name VARCHAR(50), year INT, sales_amount NUMERIC(10,2));
INSERT INTO sales VALUES
('Laptop', 2022, 120), ('Laptop', 2023, 150), ('Laptop', 2024, 210),
('Mouse',  2022,  30), ('Mouse',  2023,  45),
('Monitor',2023,  80), ('Monitor',2024,  95), ('Monitor', 2024, 15);


-- ============================================================
-- 1. Subqueries
-- ============================================================
-- scalar: one value -- employees above the company average
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- row: one row with several columns -- same department AND salary as Bakyt
SELECT first_name, department, salary
FROM employees
WHERE (department, salary) = (SELECT department, salary FROM employees WHERE first_name = 'Bakyt')
  AND first_name <> 'Bakyt';

-- table: a whole result set, used in FROM
SELECT department, avg_salary
FROM (SELECT department, ROUND(AVG(salary), 2) AS avg_salary
      FROM employees GROUP BY department) AS dept
WHERE avg_salary > 70000
ORDER BY avg_salary DESC;

-- correlated: the inner query runs for every outer row
SELECT e.first_name, e.department, e.salary
FROM employees e
WHERE e.salary = (SELECT MAX(salary) FROM employees x WHERE x.department = e.department)
ORDER BY e.department;

-- in the SELECT list
SELECT first_name, salary,
       salary - (SELECT AVG(salary) FROM employees) AS diff_from_avg
FROM employees ORDER BY diff_from_avg DESC LIMIT 3;

-- a "scalar" subquery that returns more than one row is an error
SELECT first_name FROM employees
WHERE salary = (SELECT salary FROM employees WHERE department = 'Sales');


-- ============================================================
-- 2. Common Table Expressions
-- ============================================================
WITH regional_sales AS (
    SELECT region_id, SUM(amount) AS total_sales
    FROM orders
    GROUP BY region_id
)
SELECT region_id, total_sales
FROM regional_sales
WHERE total_sales > 1000000
ORDER BY region_id;

-- several CTEs, the second one uses the first
WITH regional_sales AS (
    SELECT region_id, SUM(amount) AS total_sales FROM orders GROUP BY region_id
), top_regions AS (
    SELECT region_id FROM regional_sales
    WHERE total_sales > (SELECT SUM(total_sales) / 10 FROM regional_sales)
)
SELECT region_id, COUNT(*) AS orders, SUM(amount) AS total
FROM orders
WHERE region_id IN (SELECT region_id FROM top_regions)
GROUP BY region_id ORDER BY region_id;


-- ============================================================
-- 3. Recursive queries
-- ============================================================
-- the whole org chart, top-down from the CEO
WITH RECURSIVE org_chart AS (
    -- anchor: the CEO
    SELECT employee_id, first_name, last_name, manager_id
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    -- recursive: everyone who reports to someone already found
    SELECT e.employee_id, e.first_name, e.last_name, e.manager_id
    FROM employees e
    INNER JOIN org_chart oc ON e.manager_id = oc.employee_id
)
SELECT * FROM org_chart;

-- the same with the depth and the chain of command
WITH RECURSIVE org_chart AS (
    SELECT employee_id, first_name, 1 AS level, first_name::text AS path
    FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.first_name, oc.level + 1, oc.path || ' > ' || e.first_name
    FROM employees e JOIN org_chart oc ON e.manager_id = oc.employee_id
)
SELECT repeat('    ', level - 1) || first_name AS employee, level, path
FROM org_chart
ORDER BY path;

-- recursion without a table: the numbers 1..10
WITH RECURSIVE n AS (
    SELECT 1 AS i
    UNION ALL
    SELECT i + 1 FROM n WHERE i < 10
)
SELECT string_agg(i::text, ' ') AS one_to_ten FROM n;


-- ============================================================
-- 4. Set operations
-- ============================================================
-- UNION removes duplicates
SELECT product_name FROM warehouse_1
UNION
SELECT product_name FROM warehouse_2
ORDER BY product_name;

-- UNION ALL keeps them (Laptop, Monitor, Keyboard appear twice)
SELECT product_name FROM warehouse_1
UNION ALL
SELECT product_name FROM warehouse_2
ORDER BY product_name;

-- INTERSECT: out of stock in BOTH warehouses
SELECT product_id FROM warehouse_1 WHERE quantity = 0
INTERSECT
SELECT product_id FROM warehouse_2 WHERE quantity = 0;

-- EXCEPT: in warehouse 1 but not in warehouse 2
SELECT product_name FROM warehouse_1
EXCEPT
SELECT product_name FROM warehouse_2;


-- ============================================================
-- 5. Window functions
-- ============================================================
-- ranking inside each department; note the tie between Bakyt and Meerim
SELECT first_name, department, salary,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS row_number,
       RANK()       OVER (PARTITION BY department ORDER BY salary DESC) AS rank,
       DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dense_rank
FROM employees
WHERE department <> 'Management'
ORDER BY department, salary DESC;

-- top earner per department via ROW_NUMBER
SELECT first_name, department, salary
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
      FROM employees) t
WHERE rn = 1
ORDER BY department;

-- LAG / LEAD: previous and next order, running total
SELECT order_id, order_date, amount,
       LAG(amount)  OVER (ORDER BY order_id) AS previous_amount,
       LEAD(amount) OVER (ORDER BY order_id) AS next_amount,
       SUM(amount)  OVER (ORDER BY order_id) AS running_total
FROM orders;

-- share of each employee in the department's payroll
SELECT first_name, department, salary,
       ROUND(100 * salary / SUM(salary) OVER (PARTITION BY department), 1) AS pct_of_dept
FROM employees
ORDER BY department, salary DESC;


-- ============================================================
-- 6. Pivot and unpivot
-- ============================================================
-- pivot with conditional aggregation: years become columns
SELECT product_name,
       SUM(CASE WHEN year = 2022 THEN sales_amount ELSE 0 END) AS year_2022,
       SUM(CASE WHEN year = 2023 THEN sales_amount ELSE 0 END) AS year_2023,
       SUM(CASE WHEN year = 2024 THEN sales_amount ELSE 0 END) AS year_2024
FROM sales
GROUP BY product_name
ORDER BY product_name;

-- the same with crosstab() from the tablefunc extension
CREATE EXTENSION IF NOT EXISTS tablefunc;
SELECT * FROM crosstab(
    $$ SELECT product_name, year, SUM(sales_amount) FROM sales
       GROUP BY 1, 2 ORDER BY 1, 2 $$,
    $$ VALUES (2022), (2023), (2024) $$
) AS ct(product_name VARCHAR, year_2022 NUMERIC, year_2023 NUMERIC, year_2024 NUMERIC);

-- unpivot with UNION ALL: columns become rows again
CREATE TABLE pivoted_sales AS
SELECT product_name,
       SUM(CASE WHEN year = 2022 THEN sales_amount ELSE 0 END) AS year_2022,
       SUM(CASE WHEN year = 2023 THEN sales_amount ELSE 0 END) AS year_2023,
       SUM(CASE WHEN year = 2024 THEN sales_amount ELSE 0 END) AS year_2024
FROM sales GROUP BY product_name;

SELECT product_name, '2022' AS year, year_2022 AS sales_amount FROM pivoted_sales
UNION ALL
SELECT product_name, '2023' AS year, year_2023 AS sales_amount FROM pivoted_sales
UNION ALL
SELECT product_name, '2024' AS year, year_2024 AS sales_amount FROM pivoted_sales
ORDER BY product_name, year;


-- ============================================================
-- 7. Complex filtering and sorting
-- ============================================================
-- FILTER: an aggregate over a subset, here inside a window
SELECT employee_id, first_name, department, salary,
       SUM(salary) OVER (PARTITION BY department)                       AS total_dept_salary,
       ROUND(AVG(salary) FILTER (WHERE tenure > 5) OVER (), 2)          AS avg_salary_senior
FROM employees
ORDER BY employee_id;

-- custom sort order with CASE
SELECT order_id, status
FROM orders
ORDER BY
    CASE status
        WHEN 'High Priority'   THEN 1
        WHEN 'Medium Priority' THEN 2
        WHEN 'Low Priority'    THEN 3
        ELSE 4
    END,
    order_id;


-- ============================================================
-- 8. Query optimization: EXPLAIN and EXPLAIN ANALYZE
-- ============================================================
CREATE TABLE big_orders AS
SELECT g AS order_id,
       (g % 1000) + 1 AS customer_id,
       (random() * 1000)::numeric(10,2) AS amount
FROM generate_series(1, 200000) AS g;
ANALYZE big_orders;

-- without an index: a sequential scan over all 200 000 rows
EXPLAIN ANALYZE
SELECT order_id, amount FROM big_orders WHERE customer_id = 42;

CREATE INDEX idx_big_orders_customer ON big_orders(customer_id);
ANALYZE big_orders;

-- with the index: a bitmap index scan touching only ~200 rows
EXPLAIN ANALYZE
SELECT order_id, amount FROM big_orders WHERE customer_id = 42;

-- EXPLAIN alone only shows the plan, nothing is executed
EXPLAIN
SELECT customer_id, SUM(amount) FROM big_orders GROUP BY customer_id ORDER BY 2 DESC LIMIT 10;


-- ============================================================
-- clean up
-- ============================================================
DROP TABLE employees, orders, warehouse_1, warehouse_2,
           sales, pivoted_sales, big_orders;
DROP EXTENSION tablefunc;
