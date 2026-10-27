-- Week 6: Tables, Data Types and Constraints
-- Topics: CREATE TABLE, data types, constraints, ALTER TABLE,
--         naming conventions, temporary tables, DROP TABLE
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


-- clean slate (child table first -- it has the foreign key)
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS student;


-- ============================================================
-- 1. CREATE TABLE
-- ============================================================
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50)  NOT NULL,
    last_name  VARCHAR(50)  NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    faculty    VARCHAR(100)
);

-- \d shows the structure: columns, types, constraints, indexes
\d students


-- ============================================================
-- 2. Data types and constraints
-- ============================================================
-- SERIAL     auto-incrementing integer (surrogate primary key)
-- INTEGER    whole numbers
-- VARCHAR(n) string, max n characters
-- TEXT       string, no limit
-- BOOLEAN    true / false
-- DATE       calendar date
--
-- PRIMARY KEY  unique + not null, identifies the row
-- NOT NULL     value is required
-- UNIQUE       no two rows may repeat the value
-- CHECK        the value must satisfy a condition
-- FOREIGN KEY  the value must exist in another table

CREATE TABLE enrollments (
    enrollment_id SERIAL  PRIMARY KEY,
    student_id    INTEGER NOT NULL REFERENCES students(student_id),  -- FOREIGN KEY
    course        VARCHAR(100) NOT NULL,
    grade         INTEGER CHECK (grade >= 0 AND grade <= 100),       -- CHECK
    enrolled_on   DATE    DEFAULT CURRENT_DATE,
    is_active     BOOLEAN DEFAULT TRUE,
    notes         TEXT
);

\d enrollments

INSERT INTO students (first_name, last_name, email, faculty) VALUES
('Alymbek', 'Osmonov',   'alymbek@example.com', 'COMSEH'),
('Aidana',  'Sultanova', 'aidana@example.com',  'LAW'),
('Timur',   'Beketov',   'timur@example.com',   'MED');

INSERT INTO enrollments (student_id, course, grade) VALUES
(1, 'Databases',  92),
(2, 'Algorithms', 78),
(3, 'Databases',  85);

SELECT * FROM students;
SELECT * FROM enrollments;


-- ------------------------------------------------------------
-- the constraints doing their job -- all four FAIL on purpose
-- ------------------------------------------------------------
-- UNIQUE: email already taken
INSERT INTO students (first_name, last_name, email)
VALUES ('Fake', 'Copy', 'alymbek@example.com');

-- NOT NULL: first_name is required
INSERT INTO students (first_name, last_name, email)
VALUES (NULL, 'Nameless', 'nobody@example.com');

-- CHECK: grade must be 0..100
INSERT INTO enrollments (student_id, course, grade)
VALUES (1, 'Databases', 150);

-- FOREIGN KEY: student 999 does not exist
INSERT INTO enrollments (student_id, course, grade)
VALUES (999, 'Ghost Course', 50);


-- ============================================================
-- 3. ALTER TABLE
-- ============================================================
-- add a column
ALTER TABLE students ADD COLUMN phone VARCHAR(20);
ALTER TABLE students ADD COLUMN age   INTEGER;

-- change a column's data type
ALTER TABLE students ALTER COLUMN phone TYPE VARCHAR(30);

-- add a constraint to an existing table
ALTER TABLE students ADD CONSTRAINT age_is_sane CHECK (age >= 16 AND age <= 100);

-- rename a column
ALTER TABLE students RENAME COLUMN faculty TO department;

-- rename the table (singular noun, per the naming convention below)
ALTER TABLE students RENAME TO student;

-- drop a column
ALTER TABLE student DROP COLUMN age;

\d student


-- ============================================================
-- 4. Naming conventions
-- ============================================================
-- descriptive names        student, course_enrollment, instructor
-- lowercase + underscores  course_id, not courseID or CourseId
-- singular table names     student rather than students (be consistent)
-- primary key              id or <table>_id  -> student_id
-- foreign key              same name as the key it points at -> student_id


-- ============================================================
-- 5. Temporary tables
-- ============================================================
-- A TEMP table lives in the pg_temp schema, is invisible to other
-- sessions, and is dropped automatically when this session ends.

CREATE TEMP TABLE top_grades AS
SELECT s.first_name, e.course, e.grade
FROM   student s
JOIN   enrollments e USING (student_id)
WHERE  e.grade >= 85;

SELECT * FROM top_grades;

-- note the Schema column: pg_temp_N, not public
\dt


-- ============================================================
-- 6. DROP TABLE
-- ============================================================
-- A table referenced by a foreign key cannot be dropped first.
-- This FAILS on purpose:
DROP TABLE student;

-- drop the child table, then the parent
DROP TABLE enrollments;
DROP TABLE student;

-- IF EXISTS turns the error into a harmless notice
DROP TABLE IF EXISTS student;

\dt
