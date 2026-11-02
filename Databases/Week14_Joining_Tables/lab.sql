-- Week 14: Joining Tables
-- Topics: INNER, LEFT, RIGHT, FULL OUTER and CROSS JOIN, joining many
--         tables, self joins, extra join conditions, joins over 1:1, 1:N
--         and M:N relationships, indexes on join columns, and the common
--         pitfalls (Cartesian product, NULLs in outer joins).
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


DROP TABLE IF EXISTS order_items, orders, customers, products, employees,
                     user_profiles, users, books, authors,
                     enrollments, students, courses;


-- ============================================================
-- data
-- ============================================================
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name        VARCHAR(100),
    email       VARCHAR(100)
);

-- customer_id is nullable on purpose: an order whose customer record was
-- lost shows up in RIGHT / FULL joins
CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INTEGER REFERENCES customers(customer_id),
    order_date   DATE,
    total_amount DECIMAL(10,2)
);

CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    price        DECIMAL(10,2)
);

CREATE TABLE order_items (
    order_id   INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity   INTEGER,
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO customers (name, email) VALUES
('Aibek',  'aibek@mail.kg'),
('Ainura', 'ainura@mail.kg'),
('Bakyt',  'bakyt@mail.kg'),
('Gulzat', 'gulzat@mail.kg');        -- never ordered

INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1,    '2023-12-20',   80.00),
(1,    '2024-02-11',  250.00),
(2,    '2024-03-05',   45.50),
(3,    '2024-06-18',  730.00),
(NULL, '2024-07-01',   99.99);       -- no customer

INSERT INTO products (product_name, price) VALUES
('Keyboard', 40.00), ('Mouse', 20.00), ('Monitor', 350.00);

INSERT INTO order_items VALUES
(1, 2, 4), (2, 1, 2), (2, 3, 1), (3, 1, 1), (4, 3, 2), (4, 1, 1);


-- ============================================================
-- 1. INNER JOIN: only matching rows
-- ============================================================
SELECT c.name, c.email, o.order_date, o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date;


-- ============================================================
-- 2. LEFT JOIN: every customer, orders where they exist
-- ============================================================
SELECT c.name, c.email, o.order_date, o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.name, o.order_date;


-- ============================================================
-- 3. RIGHT JOIN: every order, customer where it exists
-- ============================================================
SELECT c.name, c.email, o.order_date, o.total_amount
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date;


-- ============================================================
-- 4. FULL OUTER JOIN: everything from both sides
-- ============================================================
SELECT c.name, c.email, o.order_date, o.total_amount
FROM customers c
FULL OUTER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date NULLS LAST;


-- ============================================================
-- 5. CROSS JOIN: every customer with every product (4 x 3 = 12 rows)
-- ============================================================
SELECT c.name, p.product_name
FROM customers c
CROSS JOIN products p
ORDER BY c.name, p.product_name;


-- ============================================================
-- 6. Several tables in one query
-- ============================================================
SELECT c.name, o.order_date, oi.quantity, p.product_name, p.price,
       oi.quantity * p.price AS line_total
FROM customers c
INNER JOIN orders o       ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p     ON oi.product_id = p.product_id
ORDER BY o.order_date, p.product_name;


-- ============================================================
-- 7. Self join: employees and their managers
-- ============================================================
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name        VARCHAR(50),
    manager_id  INTEGER REFERENCES employees(employee_id)
);
INSERT INTO employees (name, manager_id) VALUES
('Azamat', NULL),     -- CEO
('Ainura', 1),
('Nurlan', 1),
('Bakyt',  2),
('Meerim', 2),
('Tilek',  3);

SELECT e1.name AS employee, e2.name AS manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.employee_id
ORDER BY e1.employee_id;


-- ============================================================
-- 8. Join with extra conditions
-- ============================================================
SELECT c.name, o.order_date, o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= '2024-01-01'
  AND o.total_amount > 100;

-- a condition in ON vs in WHERE gives different results with LEFT JOIN
SELECT c.name, o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.total_amount > 100
ORDER BY c.name;                     -- all 4 customers are kept

SELECT c.name, o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.total_amount > 100
ORDER BY c.name;                     -- the WHERE throws the NULL rows away


-- ============================================================
-- 9. Joins over the three relationship types
-- ============================================================
-- one-to-one
CREATE TABLE users (
    user_id  SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE
);
CREATE TABLE user_profiles (
    user_id    INTEGER PRIMARY KEY REFERENCES users(user_id),
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    phone      VARCHAR(20)
);
INSERT INTO users (username) VALUES ('aibek01'), ('ainura_t'), ('bakyt.m');
INSERT INTO user_profiles VALUES
(1, 'Aibek', 'Sharshenov', '0555-123456'),
(2, 'Ainura', 'Toktomamatova', NULL);

SELECT u.username, up.first_name, up.last_name, up.phone
FROM users u
LEFT JOIN user_profiles up ON u.user_id = up.user_id
ORDER BY u.user_id;

-- one-to-many: the "one" side repeats
CREATE TABLE authors (
    author_id   SERIAL PRIMARY KEY,
    author_name VARCHAR(100)
);
CREATE TABLE books (
    book_id          SERIAL PRIMARY KEY,
    title            VARCHAR(200),
    publication_year INTEGER,
    author_id        INTEGER REFERENCES authors(author_id)
);
INSERT INTO authors (author_name) VALUES ('Chingiz Aitmatov'), ('Toktogul Satylganov');
INSERT INTO books (title, publication_year, author_id) VALUES
('Jamilia', 1958, 1), ('The White Ship', 1970, 1),
('The Day Lasts More Than a Hundred Years', 1980, 1);

SELECT a.author_name, b.title, b.publication_year
FROM authors a
INNER JOIN books b ON a.author_id = b.author_id
ORDER BY a.author_name, b.publication_year;

-- many-to-many: through the junction table
CREATE TABLE students (
    student_id   SERIAL PRIMARY KEY,
    student_name VARCHAR(100)
);
CREATE TABLE courses (
    course_id   SERIAL PRIMARY KEY,
    course_name VARCHAR(100)
);
CREATE TABLE enrollments (
    student_id      INTEGER REFERENCES students(student_id),
    course_id       INTEGER REFERENCES courses(course_id),
    enrollment_date DATE DEFAULT '2026-09-01',
    grade           CHAR(2),
    PRIMARY KEY (student_id, course_id)
);
INSERT INTO students (student_name) VALUES ('Aibek'), ('Ainura'), ('Bakyt');
INSERT INTO courses (course_name) VALUES ('Databases'), ('Algorithms'), ('Calculus');
INSERT INTO enrollments (student_id, course_id, grade) VALUES
(1, 1, 'A'), (1, 2, 'B+'), (2, 1, 'A-'), (2, 3, NULL), (3, 3, 'B');

SELECT s.student_name, c.course_name, e.enrollment_date, e.grade
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c     ON e.course_id = c.course_id
WHERE e.grade IS NOT NULL
ORDER BY s.student_name, c.course_name;


-- ============================================================
-- 10. Indexes on join columns
-- ============================================================
CREATE INDEX idx_orders_customer_id      ON orders(customer_id);
CREATE INDEX idx_order_items_order_id    ON order_items(order_id);
CREATE INDEX idx_order_items_product_id  ON order_items(product_id);
\d orders

-- with so few rows the planner still prefers a sequential scan;
-- forcing it off shows the index being used for the join
SET enable_seqscan = off;
EXPLAIN (COSTS OFF)
SELECT c.name, o.order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id = 1;
RESET enable_seqscan;


-- ============================================================
-- 11. Pitfalls
-- ============================================================
-- Cartesian product: no join condition -> 4 customers x 5 orders = 20 rows
SELECT count(*) AS rows_without_condition FROM customers c, orders o;

-- correct: 4 rows
SELECT count(*) AS rows_with_condition
FROM customers c INNER JOIN orders o ON c.customer_id = o.customer_id;

-- NULLs in outer joins: customers without orders (anti-join)
SELECT c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;


-- ============================================================
-- clean up
-- ============================================================
DROP TABLE order_items, orders, customers, products, employees,
           user_profiles, users, books, authors,
           enrollments, students, courses;
