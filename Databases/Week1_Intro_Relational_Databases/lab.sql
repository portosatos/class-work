-- Week 1: Introduction to Relational Databases
-- Topics: database vs DBMS, tables / rows / columns, primary and foreign
--         keys, schema, query, index, the three relationship types,
--         PostgreSQL as a document store (JSONB), and a first look at ACID.
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


DROP TABLE IF EXISTS enrollments, student_cards, students, courses, faculties,
                     student_settings CASCADE;


-- ============================================================
-- 1. The DBMS we are talking to
-- ============================================================
SELECT version();
SELECT current_database(), current_user;


-- ============================================================
-- 2. Tables, rows, columns, primary and foreign keys
-- ============================================================
-- Table  = one kind of entity (faculties, students, courses)
-- Column = one attribute that every row has
-- Row    = one record (one student)

CREATE TABLE faculties (
    faculty_id   SERIAL PRIMARY KEY,           -- primary key: unique, not null
    faculty_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(100) UNIQUE,
    faculty_id INTEGER REFERENCES faculties(faculty_id)   -- foreign key
);

INSERT INTO faculties (faculty_name) VALUES
('Computer Science'), ('Mathematics'), ('Economics');

INSERT INTO students (full_name, email, faculty_id) VALUES
('Aibek Sharshenov',     'aibek@alatoo.edu.kg',   1),
('Ainura Toktomamatova', 'ainura@alatoo.edu.kg',  1),
('Bakyt Mamatov',        'bakyt@alatoo.edu.kg',   2),
('Gulzat Sultanova',     'gulzat@alatoo.edu.kg',  3);

-- the whole table: 4 rows, 4 columns
SELECT * FROM students;

-- the schema -- the blueprint of the table
\d students

-- a query: a question asked in SQL
SELECT s.full_name, f.faculty_name
FROM students s
JOIN faculties f ON f.faculty_id = s.faculty_id
ORDER BY f.faculty_name, s.full_name;

-- the foreign key refuses a faculty that does not exist
INSERT INTO students (full_name, faculty_id) VALUES ('Nobody', 99);


-- ============================================================
-- 3. Relationship types
-- ============================================================

-- One-to-many: one faculty has many students (built above)
SELECT f.faculty_name, COUNT(s.student_id) AS students
FROM faculties f LEFT JOIN students s ON s.faculty_id = f.faculty_id
GROUP BY f.faculty_name ORDER BY f.faculty_name;

-- One-to-one: one student has exactly one student card
CREATE TABLE student_cards (
    card_number VARCHAR(20) PRIMARY KEY,
    student_id  INTEGER UNIQUE NOT NULL REFERENCES students(student_id),
    issued_on   DATE DEFAULT CURRENT_DATE
);
INSERT INTO student_cards (card_number, student_id) VALUES
('AIU-2025-0001', 1), ('AIU-2025-0002', 2);

-- FAILS: student 1 already has a card -- UNIQUE keeps it one-to-one
INSERT INTO student_cards (card_number, student_id) VALUES ('AIU-2025-0003', 1);

-- Many-to-many: students take many courses, courses have many students.
-- Needs a third (junction) table.
CREATE TABLE courses (
    course_id   SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL
);
CREATE TABLE enrollments (
    student_id INTEGER REFERENCES students(student_id),
    course_id  INTEGER REFERENCES courses(course_id),
    PRIMARY KEY (student_id, course_id)
);
INSERT INTO courses (course_name) VALUES ('Databases'), ('Calculus'), ('Algorithms');
INSERT INTO enrollments VALUES (1, 1), (1, 3), (2, 1), (3, 2), (3, 1), (4, 2);

SELECT s.full_name, c.course_name
FROM enrollments e
JOIN students s ON s.student_id = e.student_id
JOIN courses  c ON c.course_id  = e.course_id
ORDER BY s.full_name, c.course_name;


-- ============================================================
-- 4. Index: makes lookups fast
-- ============================================================
-- PostgreSQL already made indexes for every PRIMARY KEY and UNIQUE column
SELECT tablename, indexname FROM pg_indexes
WHERE schemaname = 'public' AND tablename IN ('students', 'student_cards')
ORDER BY tablename, indexname;

CREATE INDEX idx_students_full_name ON students(full_name);
\di idx_students_full_name


-- ============================================================
-- 5. Normalization in one example
-- ============================================================
-- The faculty name is stored ONCE in faculties and referenced by id.
-- Renaming it is a single-row update, and every student sees the change.
UPDATE faculties SET faculty_name = 'Computer Science and Engineering'
WHERE faculty_id = 1;

SELECT s.full_name, f.faculty_name
FROM students s JOIN faculties f ON f.faculty_id = s.faculty_id
WHERE f.faculty_id = 1;


-- ============================================================
-- 6. PostgreSQL can also store documents (the NoSQL idea)
-- ============================================================
CREATE TABLE student_settings (
    student_id INTEGER PRIMARY KEY REFERENCES students(student_id),
    settings   JSONB
);
INSERT INTO student_settings VALUES
(1, '{"theme": "dark",  "language": "ky", "notifications": {"email": true,  "sms": false}}'),
(2, '{"theme": "light", "language": "ru", "notifications": {"email": false, "sms": true}}'),
(3, '{"theme": "dark",  "language": "en"}');

-- query inside the JSON document
SELECT s.full_name,
       st.settings ->> 'theme'                       AS theme,
       st.settings -> 'notifications' ->> 'email'    AS email_notifications
FROM student_settings st JOIN students s USING (student_id)
WHERE st.settings @> '{"theme": "dark"}';


-- ============================================================
-- 7. A first look at ACID: atomicity
-- ============================================================
-- Both inserts happen inside one transaction. The second one fails,
-- so the first one is undone too -- all or nothing.
BEGIN;
INSERT INTO courses (course_name) VALUES ('Physics');
INSERT INTO courses (course_id, course_name) VALUES (1, 'Duplicate id');   -- FAILS
COMMIT;   -- the transaction is aborted, so COMMIT turns into ROLLBACK

SELECT * FROM courses;   -- no 'Physics'


-- ============================================================
-- clean up
-- ============================================================
DROP TABLE student_settings, enrollments, courses, student_cards,
           students, faculties;
\dt
