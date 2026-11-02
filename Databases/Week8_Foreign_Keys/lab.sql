-- Week 8: Foreign Keys and Relationships
-- Topics: the four ways to declare a foreign key, referential integrity,
--         ON DELETE / ON UPDATE options, one-to-one, one-to-many and
--         many-to-many relationships.
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


DROP TABLE IF EXISTS student_enrollments, students, courses,
                     user_profiles, users, comments, blog_posts,
                     employees, departments CASCADE;


-- ============================================================
-- 1. Four ways to declare a foreign key
-- ============================================================
CREATE TABLE departments (
    dept_id   SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    location  VARCHAR(100)
);

-- Method 1: inline, right after the column
CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    dept_id    INTEGER REFERENCES departments(dept_id)
);
\d employees
DROP TABLE employees;

-- Method 2: table-level, after all the columns
CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    dept_id    INTEGER,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
DROP TABLE employees;

-- Method 3: added to a table that already exists
CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    dept_id    INTEGER
);
ALTER TABLE employees
ADD CONSTRAINT fk_employee_department
FOREIGN KEY (dept_id) REFERENCES departments(dept_id);
DROP TABLE employees;

-- Method 4: named, during creation -- the name is "fk_employee_department"
-- instead of the auto-generated "employees_dept_id_fkey"
CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    dept_id    INTEGER,
    CONSTRAINT fk_employee_department
        FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
\d employees


-- ============================================================
-- 2. Referential integrity
-- ============================================================
INSERT INTO departments (dept_name, location) VALUES
('Engineering', 'Building A'),
('Marketing',   'Building B'),
('HR',          'Building C');

-- works: department 1 exists
INSERT INTO employees (first_name, last_name, dept_id) VALUES ('John', 'Smith', 1);

-- Insert rule -- FAILS: department 99 does not exist
INSERT INTO employees (first_name, last_name, dept_id) VALUES ('Jane', 'Doe', 99);

-- Update rule -- FAILS: cannot point an employee at a missing department
UPDATE employees SET dept_id = 42 WHERE first_name = 'John';

-- Delete rule -- FAILS: department 1 still has an employee (default = NO ACTION)
DELETE FROM departments WHERE dept_id = 1;

-- a department nobody references can be deleted
DELETE FROM departments WHERE dept_id = 3;
SELECT * FROM departments;

DROP TABLE employees;


-- ============================================================
-- 3. ON DELETE / ON UPDATE options
-- ============================================================
-- reset the parent table for every option
TRUNCATE departments RESTART IDENTITY CASCADE;
INSERT INTO departments (dept_name, location) VALUES
('Engineering', 'Building A'),
('Marketing',   'Building B');

-- ON DELETE CASCADE: deleting the department deletes its employees
CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    dept_id    INTEGER REFERENCES departments(dept_id) ON DELETE CASCADE
);
INSERT INTO employees (first_name, last_name, dept_id) VALUES
('John', 'Smith', 1), ('Jane', 'Doe', 1), ('Sarah', 'Davis', 2);

SELECT * FROM employees;
DELETE FROM departments WHERE dept_id = 1;
SELECT * FROM employees;   -- John and Jane are gone

DROP TABLE employees;
TRUNCATE departments RESTART IDENTITY CASCADE;
INSERT INTO departments (dept_name, location) VALUES
('Engineering', 'Building A'),
('Marketing',   'Building B');

-- ON DELETE SET NULL: employees stay, their dept_id becomes NULL
CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    dept_id    INTEGER REFERENCES departments(dept_id) ON DELETE SET NULL
);
INSERT INTO employees (first_name, last_name, dept_id) VALUES
('John', 'Smith', 1), ('Jane', 'Doe', 1), ('Sarah', 'Davis', 2);

DELETE FROM departments WHERE dept_id = 1;
SELECT * FROM employees;   -- John and Jane: dept_id is NULL

DROP TABLE employees;
TRUNCATE departments RESTART IDENTITY CASCADE;

-- ON DELETE SET DEFAULT: dept_id falls back to its DEFAULT.
-- The default must itself exist in the parent, so department 0 is created.
INSERT INTO departments (dept_id, dept_name, location) VALUES (0, 'Unassigned', NULL);
INSERT INTO departments (dept_name, location) VALUES
('Engineering', 'Building A'),
('Marketing',   'Building B');

CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    dept_id    INTEGER DEFAULT 0 REFERENCES departments(dept_id) ON DELETE SET DEFAULT
);
INSERT INTO employees (first_name, last_name, dept_id) VALUES
('John', 'Smith', 1), ('Sarah', 'Davis', 2);

DELETE FROM departments WHERE dept_id = 1;
SELECT * FROM employees;   -- John moved to department 0

DROP TABLE employees;
TRUNCATE departments RESTART IDENTITY CASCADE;
INSERT INTO departments (dept_name, location) VALUES
('Engineering', 'Building A'),
('Marketing',   'Building B');

-- ON DELETE RESTRICT: deleting a referenced department is refused
CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    dept_id    INTEGER REFERENCES departments(dept_id) ON DELETE RESTRICT
);
INSERT INTO employees (first_name, last_name, dept_id) VALUES ('John', 'Smith', 1);

-- FAILS: still referenced
DELETE FROM departments WHERE dept_id = 1;

DROP TABLE employees;

-- ON UPDATE CASCADE: changing the department's key updates every employee
CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    dept_id    INTEGER REFERENCES departments(dept_id) ON UPDATE CASCADE
);
INSERT INTO employees (first_name, last_name, dept_id) VALUES
('John', 'Smith', 1), ('Jane', 'Doe', 1);

UPDATE departments SET dept_id = 100 WHERE dept_id = 1;
SELECT * FROM departments;
SELECT * FROM employees;   -- both now in department 100

DROP TABLE employees;

-- Combined: ON DELETE CASCADE + ON UPDATE CASCADE
CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    dept_id    INTEGER REFERENCES departments(dept_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
\d employees
DROP TABLE employees, departments;


-- ============================================================
-- 4. One-to-one
-- ============================================================
-- Approach 1: a separate key plus a UNIQUE foreign key
CREATE TABLE users (
    user_id    SERIAL PRIMARY KEY,
    username   VARCHAR(50)  UNIQUE NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_profiles (
    profile_id          SERIAL PRIMARY KEY,
    user_id             INTEGER UNIQUE NOT NULL,   -- UNIQUE makes it one-to-one
    first_name          VARCHAR(50),
    last_name           VARCHAR(50),
    bio                 TEXT,
    profile_picture_url VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

INSERT INTO users (username, email) VALUES ('johndoe', 'john@example.com');
INSERT INTO user_profiles (user_id, first_name, last_name, bio)
VALUES (1, 'John', 'Doe', 'Software developer passionate about databases');

-- FAILS: user 1 already has a profile
INSERT INTO user_profiles (user_id, first_name, last_name) VALUES (1, 'Jane', 'Smith');

SELECT u.username, p.first_name, p.last_name, p.bio
FROM users u JOIN user_profiles p ON p.user_id = u.user_id;

DROP TABLE user_profiles;

-- Approach 2: the child shares the parent's primary key
CREATE TABLE user_profiles (
    user_id             INTEGER PRIMARY KEY,   -- same as users.user_id
    first_name          VARCHAR(50),
    last_name           VARCHAR(50),
    bio                 TEXT,
    profile_picture_url VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
\d user_profiles


-- ============================================================
-- 5. One-to-many
-- ============================================================
CREATE TABLE departments (
    dept_id      SERIAL PRIMARY KEY,
    dept_name    VARCHAR(100) NOT NULL,
    manager_name VARCHAR(100),
    budget       DECIMAL(10,2)
);

CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    position   VARCHAR(100),
    salary     DECIMAL(10,2),
    hire_date  DATE DEFAULT CURRENT_DATE,
    dept_id    INTEGER NOT NULL,                  -- the "many" side
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE RESTRICT
);

INSERT INTO departments (dept_name, manager_name, budget) VALUES
('Engineering', 'Alice Johnson', 500000.00),
('Marketing',   'Bob Wilson',    200000.00);

INSERT INTO employees (first_name, last_name, position, salary, dept_id) VALUES
('John',  'Smith', 'Software Engineer',    75000.00, 1),
('Jane',  'Doe',   'Senior Developer',     85000.00, 1),
('Mike',  'Brown', 'DevOps Engineer',      80000.00, 1),
('Sarah', 'Davis', 'Marketing Specialist', 55000.00, 2);

SELECT d.dept_name, e.first_name, e.last_name, e.position
FROM departments d
JOIN employees e ON d.dept_id = e.dept_id
ORDER BY d.dept_name, e.last_name;

-- blog posts and their comments: another one-to-many
CREATE TABLE blog_posts (
    post_id        SERIAL PRIMARY KEY,
    title          VARCHAR(200) NOT NULL,
    content        TEXT,
    author         VARCHAR(100),
    published_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comments (
    comment_id     SERIAL PRIMARY KEY,
    post_id        INTEGER NOT NULL,              -- foreign key
    commenter_name VARCHAR(100),
    comment_text   TEXT NOT NULL,
    comment_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES blog_posts(post_id) ON DELETE CASCADE
);

INSERT INTO blog_posts (title, author) VALUES
('Why PostgreSQL', 'Alice'), ('Foreign keys explained', 'Bob');
INSERT INTO comments (post_id, commenter_name, comment_text) VALUES
(1, 'Carol', 'Great post!'),
(1, 'Dave',  'Agreed.'),
(2, 'Erin',  'Very clear, thanks.');

SELECT p.title, COUNT(c.comment_id) AS comments
FROM blog_posts p LEFT JOIN comments c ON c.post_id = p.post_id
GROUP BY p.title ORDER BY p.title;


-- ============================================================
-- 6. Many-to-many (junction table)
-- ============================================================
CREATE TABLE students (
    student_id      SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    enrollment_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE courses (
    course_id   SERIAL PRIMARY KEY,
    course_code VARCHAR(10) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    credits     INTEGER NOT NULL,
    instructor  VARCHAR(100)
);

CREATE TABLE student_enrollments (
    enrollment_id   SERIAL PRIMARY KEY,
    student_id      INTEGER NOT NULL,
    course_id       INTEGER NOT NULL,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    grade           CHAR(2),    -- an attribute of the relationship itself
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(course_id)   ON DELETE CASCADE,
    UNIQUE (student_id, course_id)   -- no duplicate enrollments
);

INSERT INTO students (first_name, last_name, email) VALUES
('Alice', 'Johnson', 'alice@university.edu'),
('Bob',   'Smith',   'bob@university.edu'),
('Carol', 'Wilson',  'carol@university.edu');

INSERT INTO courses (course_code, course_name, credits, instructor) VALUES
('CS101',   'Introduction to Programming', 3, 'Dr. Brown'),
('CS201',   'Data Structures',             4, 'Dr. Davis'),
('MATH101', 'Calculus I',                  4, 'Dr. Wilson');

INSERT INTO student_enrollments (student_id, course_id, grade) VALUES
(1, 1, 'A'),    -- Alice in CS101
(1, 2, 'B+'),   -- Alice in CS201
(2, 1, 'A-'),   -- Bob in CS101
(2, 3, 'B'),    -- Bob in MATH101
(3, 2, 'A'),    -- Carol in CS201
(3, 3, 'A-');   -- Carol in MATH101

-- FAILS: Alice is already in CS101
INSERT INTO student_enrollments (student_id, course_id, grade) VALUES (1, 1, 'C');

SELECT s.first_name || ' ' || s.last_name AS student_name,
       c.course_code, c.course_name, se.grade
FROM students s
JOIN student_enrollments se ON s.student_id = se.student_id
JOIN courses c              ON se.course_id = c.course_id
ORDER BY s.last_name, c.course_code;

-- all students in one course
SELECT s.first_name, s.last_name, se.grade
FROM students s
JOIN student_enrollments se ON s.student_id = se.student_id
JOIN courses c              ON se.course_id = c.course_id
WHERE c.course_code = 'CS101';

-- all courses of one student
SELECT c.course_code, c.course_name, c.credits, se.grade
FROM courses c
JOIN student_enrollments se ON c.course_id = se.course_id
JOIN students s             ON se.student_id = s.student_id
WHERE s.email = 'alice@university.edu';

-- every foreign key created above, read from the catalog
SELECT conrelid::regclass AS child, conname, confrelid::regclass AS parent,
       CASE confdeltype WHEN 'a' THEN 'NO ACTION' WHEN 'r' THEN 'RESTRICT'
                        WHEN 'c' THEN 'CASCADE'   WHEN 'n' THEN 'SET NULL'
                        WHEN 'd' THEN 'SET DEFAULT' END AS on_delete
FROM pg_constraint
WHERE contype = 'f' AND connamespace = 'public'::regnamespace
ORDER BY conrelid::regclass::text, conname;


-- ============================================================
-- clean up
-- ============================================================
DROP TABLE student_enrollments, students, courses,
           user_profiles, users, comments, blog_posts,
           employees, departments;
\dt
