-- Week 13: Aggregate Functions
-- Topics: COUNT / SUM / AVG / MIN / MAX, STRING_AGG, ARRAY_AGG,
--         STDDEV / VARIANCE / CORR, GROUP BY (one column, several columns,
--         expressions), HAVING, window functions vs aggregates, NULL
--         handling, conditional aggregation, FILTER, percentages.
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


DROP TABLE IF EXISTS employees, employee_skills, products, product_reviews, sales;


-- ============================================================
-- data
-- ============================================================
CREATE TABLE employees (
    employee_id      SERIAL PRIMARY KEY,
    first_name       VARCHAR(50),
    last_name        VARCHAR(50),
    department       VARCHAR(50),
    salary           NUMERIC(10,2),
    bonus            NUMERIC(10,2),
    age              INT,
    experience_years INT,
    hire_date        DATE,
    email            VARCHAR(100)
);
INSERT INTO employees (first_name, last_name, department, salary, bonus, age, experience_years, hire_date, email) VALUES
('Aibek',  'Sharshenov',    'Engineering', 95000, 5000, 34, 10, '2018-03-01', 'aibek@corp.kg'),
('Ainura', 'Toktomamatova', 'Engineering', 82000, NULL, 29,  6, '2021-06-15', 'ainura@corp.kg'),
('Bakyt',  'Mamatov',       'Engineering', 64000, 2000, 25,  2, '2023-08-01', NULL),
('Azamat', 'Uulu',          'Engineering', 120000, 9000, 45, 20, '2015-01-10', 'azamat@corp.kg'),
('Bermet', 'Asanova',       'Marketing',   58000, NULL, 31,  7, '2020-02-20', 'bermet@corp.kg'),
('Gulzat', 'Sultanova',     'Marketing',   47000, 1000, 24,  1, '2024-04-04', NULL),
('Meerim', 'Bekova',        'HR',          52000, NULL, 38, 12, '2019-09-09', 'meerim@corp.kg'),
('Nurlan', 'Isakov',        'Sales',       45000, 3000, 27,  3, '2023-02-01', 'nurlan@corp.kg'),
('Aidai',  'Kadyrova',      'Sales',       71000, 6000, 41, 15, '2016-11-11', 'aidai@corp.kg'),
('Tilek',  'Usubaliev',     'Sales',       39000, NULL, 23,  1, '2024-07-01', NULL),
('Erlan',  'Abdyldaev',     'Sales',       56000, 2500, 52, 25, '2012-05-05', 'erlan@corp.kg'),
('Kanykei','Osmonova',      'Sales',       48000, 1500, 30,  5, '2022-10-10', 'kanykei@corp.kg');

CREATE TABLE employee_skills (
    employee_id INT REFERENCES employees(employee_id),
    skill_name  VARCHAR(50)
);
INSERT INTO employee_skills VALUES
(1, 'SQL'), (1, 'Python'), (1, 'Docker'), (2, 'Java'), (2, 'SQL'),
(4, 'Go'), (4, 'Kubernetes'), (4, 'SQL'), (8, 'Negotiation');

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name       VARCHAR(50),
    category   VARCHAR(30),
    price      NUMERIC(8,2)
);
INSERT INTO products (name, category, price) VALUES
('Laptop', 'Electronics', 1200), ('Phone', 'Electronics', 800), ('Headphones', 'Electronics', 150),
('Desk', 'Furniture', 300), ('Chair', 'Furniture', 180),
('Notebook', 'Stationery', 3), ('Pen', 'Stationery', 1.5), ('Stapler', 'Stationery', 12);

CREATE TABLE product_reviews (
    product_id INT REFERENCES products(product_id),
    rating     INT CHECK (rating BETWEEN 1 AND 5)
);
-- Laptop: 12 reviews averaging > 4; Phone: 10 reviews ~3.9; Desk: 3 reviews of 5
INSERT INTO product_reviews
SELECT 1, r FROM unnest(ARRAY[5,5,4,5,4,5,4,4,5,5,4,5]) AS r;
INSERT INTO product_reviews
SELECT 2, r FROM unnest(ARRAY[4,4,3,5,4,3,4,4,4,4]) AS r;
INSERT INTO product_reviews VALUES (4, 5), (4, 5), (4, 5);

CREATE TABLE sales (
    sale_id    SERIAL PRIMARY KEY,
    department VARCHAR(50),
    sale_date  DATE,
    amount     NUMERIC(10,2)
);
INSERT INTO sales (department, sale_date, amount) VALUES
('Retail', '2025-02-10', 1200), ('Retail', '2025-05-03',  800), ('Online', '2025-05-20', 2500),
('Online', '2025-08-14', 3100), ('Retail', '2025-11-30', 1900), ('Online', '2025-12-24', 4200),
('Retail', '2026-01-15', 1100), ('Online', '2026-03-03', 2800), ('Online', '2026-04-18', 3600),
('Retail', '2026-07-07', 1500), ('Online', '2026-09-09', 5100);


-- ============================================================
-- 1. COUNT
-- ============================================================
SELECT COUNT(*)                   AS total_employees,
       COUNT(email)               AS employees_with_email,
       COUNT(DISTINCT department) AS unique_departments
FROM employees;


-- ============================================================
-- 2. SUM, AVG, MIN, MAX
-- ============================================================
SELECT SUM(salary)           AS total_salaries,
       ROUND(AVG(salary), 2) AS average_salary,
       MAX(salary)           AS highest_salary,
       MIN(salary)           AS lowest_salary
FROM employees;

SELECT department, SUM(amount) AS total_sales
FROM sales GROUP BY department;

SELECT department, ROUND(AVG(age), 1) AS avg_age, MAX(hire_date) AS latest_hire
FROM employees GROUP BY department ORDER BY department;


-- ============================================================
-- 3. STRING_AGG and ARRAY_AGG
-- ============================================================
SELECT department, STRING_AGG(first_name, ', ') AS employee_names
FROM employees GROUP BY department ORDER BY department;

SELECT employee_id, STRING_AGG(skill_name, ', ' ORDER BY skill_name) AS skills
FROM employee_skills GROUP BY employee_id ORDER BY employee_id;

SELECT department, ARRAY_AGG(salary ORDER BY salary) AS salary_array
FROM employees GROUP BY department ORDER BY department;

SELECT department, ARRAY_AGG(first_name ORDER BY last_name) AS employees
FROM employees GROUP BY department ORDER BY department;


-- ============================================================
-- 4. Statistical aggregates
-- ============================================================
SELECT department,
       ROUND(STDDEV(salary), 2)   AS salary_std_dev,
       ROUND(VARIANCE(salary), 2) AS salary_variance
FROM employees GROUP BY department ORDER BY department;

-- -1 .. 1: a positive value means salary tends to grow with experience
SELECT ROUND(CORR(experience_years, salary)::numeric, 3) AS experience_salary_correlation
FROM employees;


-- ============================================================
-- 5. GROUP BY
-- ============================================================
SELECT category,
       COUNT(*)             AS number_of_products,
       SUM(price)           AS total_value,
       ROUND(AVG(price), 2) AS average_price
FROM products GROUP BY category ORDER BY category;

-- several columns: year and quarter
SELECT EXTRACT(YEAR FROM sale_date)    AS year,
       EXTRACT(QUARTER FROM sale_date) AS quarter,
       COUNT(*)    AS total_sales,
       SUM(amount) AS total_revenue
FROM sales
GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(QUARTER FROM sale_date)
ORDER BY year, quarter;

-- by an expression
SELECT CASE
           WHEN age < 30 THEN 'Under 30'
           WHEN age BETWEEN 30 AND 50 THEN '30-50'
           ELSE 'Over 50'
       END AS age_group,
       COUNT(*)              AS employee_count,
       ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY 1
ORDER BY 1;

-- a column that is neither grouped nor aggregated is an error
SELECT department, first_name, COUNT(*) FROM employees GROUP BY department;


-- ============================================================
-- 6. HAVING: filtering groups
-- ============================================================
-- WHERE filters rows before grouping, HAVING filters groups after
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 3;

SELECT product_id, ROUND(AVG(rating), 2) AS avg_rating, COUNT(*) AS review_count
FROM product_reviews
GROUP BY product_id
HAVING AVG(rating) > 4.0 AND COUNT(*) >= 10;

-- both together
SELECT department, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
WHERE hire_date >= '2018-01-01'
GROUP BY department
HAVING AVG(salary) > 50000
ORDER BY avg_salary DESC;


-- ============================================================
-- 7. Window functions vs aggregate functions
-- ============================================================
-- aggregate: one row per department
SELECT department, ROUND(AVG(salary), 2) AS dept_avg_salary
FROM employees GROUP BY department ORDER BY department;

-- window: every employee keeps its row and gets the department average
SELECT employee_id, first_name, department, salary,
       ROUND(AVG(salary) OVER (PARTITION BY department), 2) AS dept_avg_salary
FROM employees
ORDER BY department, salary DESC;


-- ============================================================
-- 8. NULL handling
-- ============================================================
SELECT COUNT(*)                AS total_rows,
       COUNT(email)            AS non_null_emails,
       COUNT(*) - COUNT(email) AS null_emails
FROM employees;

-- SUM / AVG skip NULLs: AVG(bonus) divides by 8, not by 12
SELECT SUM(bonus)                        AS total_bonus,
       ROUND(AVG(bonus), 2)              AS avg_bonus,
       COUNT(bonus)                      AS employees_with_bonus,
       ROUND(AVG(COALESCE(bonus, 0)), 2) AS avg_bonus_counting_nulls_as_0
FROM employees;


-- ============================================================
-- 9. Common patterns
-- ============================================================
-- several aggregations at once
SELECT department,
       COUNT(*)                 AS employee_count,
       MIN(salary)              AS min_salary,
       MAX(salary)              AS max_salary,
       ROUND(AVG(salary), 2)    AS avg_salary,
       ROUND(STDDEV(salary), 2) AS salary_std_dev
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;

-- conditional aggregation: CASE inside COUNT, and the FILTER clause
SELECT department,
       COUNT(*)                                       AS total_employees,
       COUNT(CASE WHEN salary > 50000 THEN 1 END)     AS high_earners,
       COUNT(*) FILTER (WHERE hire_date > '2023-01-01') AS recent_hires
FROM employees
GROUP BY department ORDER BY department;

-- percentage of the total
SELECT department,
       COUNT(*) AS dept_count,
       ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM employees) * 100, 1) AS percentage
FROM employees
GROUP BY department
ORDER BY percentage DESC;


-- ============================================================
-- clean up
-- ============================================================
DROP TABLE employee_skills, employees, product_reviews, products, sales;
