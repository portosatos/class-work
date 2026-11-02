-- Week 9: Database Design Basics
-- Topics: ER modelling (university), the three normal forms with the
--         anomalies each one removes, and a full library management
--         system designed step by step.
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


DROP TABLE IF EXISTS
    -- university
    enrollments, courses, professors, students, departments,
    -- normalization
    students_bad, students_1nf, student_phones, enrollments_bad,
    enrollments_2nf, courses_2nf, students_3nf_bad, departments_3nf,
    students_3nf,
    -- library
    loans, book_authors, books, authors, members
CASCADE;
DROP VIEW IF EXISTS student_age;


-- ============================================================
-- 1. ER model -> tables: a small university
-- ============================================================
-- Entities:      Department, Student, Professor, Course
-- Relationships: Student ENROLLS in Course   (many-to-many -> enrollments)
--                Professor TEACHES Course    (one-to-many  -> courses.professor_id)
--                Department HAS Students     (one-to-many  -> students.department_id)

CREATE TABLE departments (
    department_id   INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_head VARCHAR(100)
);

CREATE TABLE students (
    student_id    INT PRIMARY KEY,                -- key attribute
    first_name    VARCHAR(50) NOT NULL,           -- simple attribute
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(100) UNIQUE,
    date_of_birth DATE,
    -- composite attribute "address" split into its parts
    street        VARCHAR(100),
    city          VARCHAR(50),
    zip_code      VARCHAR(10),
    department_id INT REFERENCES departments(department_id)
);

CREATE TABLE professors (
    professor_id  INT PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(100) UNIQUE,
    department_id INT REFERENCES departments(department_id)
);

CREATE TABLE courses (
    course_id    INT PRIMARY KEY,
    course_name  VARCHAR(100) NOT NULL,
    credits      INT CHECK (credits > 0),
    description  TEXT,
    professor_id INT REFERENCES professors(professor_id)
);

CREATE TABLE enrollments (
    student_id INT REFERENCES students(student_id),
    course_id  INT REFERENCES courses(course_id),
    grade      CHAR(2),
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO departments VALUES
(1, 'Computer Science', 'Dr. Brown'),
(2, 'Mathematics',      'Dr. Wilson');

INSERT INTO students VALUES
(1, 'Aibek',  'Sharshenov',    'aibek@alatoo.edu.kg',  '2002-05-12', 'Chui 1',  'Bishkek', '720001', 1),
(2, 'Ainura', 'Toktomamatova', 'ainura@alatoo.edu.kg', '2001-09-23', 'Manas 5', 'Bishkek', '720010', 1),
(3, 'Bakyt',  'Mamatov',       'bakyt@alatoo.edu.kg',  '2003-01-15', 'Lenin 9', 'Osh',     '723500', 2);

INSERT INTO professors VALUES
(1, 'John', 'Brown',  'brown@alatoo.edu.kg',  1),
(2, 'Anna', 'Wilson', 'wilson@alatoo.edu.kg', 2);

INSERT INTO courses VALUES
(101, 'Databases',  4, 'Relational databases and SQL', 1),
(102, 'Algorithms', 4, 'Sorting, searching, graphs',   1),
(201, 'Calculus I', 3, 'Limits and derivatives',       2);

INSERT INTO enrollments VALUES
(1, 101, 'A'), (1, 102, 'B+'), (2, 101, 'A-'), (3, 201, 'B'), (3, 101, 'A');

-- derived attribute: age is computed from date_of_birth, never stored
CREATE VIEW student_age AS
SELECT student_id, first_name, last_name,
       date_part('year', age(CURRENT_DATE, date_of_birth))::int AS age
FROM students;
SELECT * FROM student_age;

-- who teaches what, who takes what
SELECT c.course_name, p.last_name AS professor,
       string_agg(s.first_name, ', ' ORDER BY s.first_name) AS students
FROM courses c
JOIN professors p       ON p.professor_id = c.professor_id
LEFT JOIN enrollments e ON e.course_id = c.course_id
LEFT JOIN students s    ON s.student_id = e.student_id
GROUP BY c.course_name, p.last_name
ORDER BY c.course_name;


-- ============================================================
-- 2. First Normal Form (1NF): atomic values, no lists in a cell
-- ============================================================
-- BAD: several phone numbers in one column
CREATE TABLE students_bad (
    student_id    INT PRIMARY KEY,
    name          VARCHAR(100),
    phone_numbers TEXT          -- "0555-123456, 0700-654321"
);
INSERT INTO students_bad VALUES
(1, 'Aibek',  '0555-123456, 0700-654321'),
(2, 'Ainura', '0777-111222');

-- "who has phone 0700-654321?" needs string searching, and the
-- type of each phone (mobile / home) has nowhere to go
SELECT * FROM students_bad WHERE phone_numbers LIKE '%0700-654321%';

-- GOOD: one phone per row in its own table
CREATE TABLE students_1nf (
    student_id INT PRIMARY KEY,
    name       VARCHAR(100)
);
CREATE TABLE student_phones (
    student_id   INT REFERENCES students_1nf(student_id),
    phone_number VARCHAR(15),
    phone_type   VARCHAR(20),          -- 'mobile', 'home', ...
    PRIMARY KEY (student_id, phone_number)
);
INSERT INTO students_1nf VALUES (1, 'Aibek'), (2, 'Ainura');
INSERT INTO student_phones VALUES
(1, '0555-123456', 'mobile'),
(1, '0700-654321', 'home'),
(2, '0777-111222', 'mobile');

SELECT s.name, p.phone_number, p.phone_type
FROM students_1nf s JOIN student_phones p USING (student_id)
ORDER BY s.name;


-- ============================================================
-- 3. Second Normal Form (2NF): no partial dependency
-- ============================================================
-- BAD: key is (student_id, course_id) but course_name depends on
-- course_id alone
CREATE TABLE enrollments_bad (
    student_id  INT,
    course_id   INT,
    course_name VARCHAR(100),       -- partial dependency!
    grade       CHAR(2),
    PRIMARY KEY (student_id, course_id)
);
INSERT INTO enrollments_bad VALUES
(1, 101, 'Databases', 'A'),
(2, 101, 'Databases', 'A-'),
(3, 101, 'Databases', 'A');

-- update anomaly: rename the course in one row only -> data contradicts itself
UPDATE enrollments_bad SET course_name = 'Database Systems'
WHERE student_id = 1 AND course_id = 101;
SELECT DISTINCT course_id, course_name FROM enrollments_bad ORDER BY course_name;

-- GOOD: course facts live in the course table
CREATE TABLE courses_2nf (
    course_id   INT PRIMARY KEY,
    course_name VARCHAR(100),
    credits     INT
);
CREATE TABLE enrollments_2nf (
    student_id INT,
    course_id  INT REFERENCES courses_2nf(course_id),
    grade      CHAR(2),
    PRIMARY KEY (student_id, course_id)
);
INSERT INTO courses_2nf VALUES (101, 'Databases', 4);
INSERT INTO enrollments_2nf VALUES (1, 101, 'A'), (2, 101, 'A-'), (3, 101, 'A');

UPDATE courses_2nf SET course_name = 'Database Systems' WHERE course_id = 101;  -- one row
SELECT e.student_id, c.course_name, e.grade
FROM enrollments_2nf e JOIN courses_2nf c USING (course_id);


-- ============================================================
-- 4. Third Normal Form (3NF): no transitive dependency
-- ============================================================
-- BAD: department_name depends on department_id, which depends on student_id
CREATE TABLE students_3nf_bad (
    student_id      INT PRIMARY KEY,
    name            VARCHAR(100),
    department_id   INT,
    department_name VARCHAR(100)    -- transitive dependency!
);
INSERT INTO students_3nf_bad VALUES
(1, 'Aibek',  1, 'Computer Science'),
(2, 'Ainura', 1, 'Computer Science'),
(3, 'Bakyt',  2, 'Mathematics');

-- delete anomaly: Bakyt was the only Mathematics student; deleting him
-- also deletes the fact that the Mathematics department exists
DELETE FROM students_3nf_bad WHERE student_id = 3;
SELECT DISTINCT department_id, department_name FROM students_3nf_bad;

-- GOOD: departments in their own table
CREATE TABLE departments_3nf (
    department_id   INT PRIMARY KEY,
    department_name VARCHAR(100),
    department_head VARCHAR(100)
);
CREATE TABLE students_3nf (
    student_id    INT PRIMARY KEY,
    name          VARCHAR(100),
    department_id INT REFERENCES departments_3nf(department_id)
);
INSERT INTO departments_3nf VALUES (1, 'Computer Science', 'Dr. Brown'), (2, 'Mathematics', 'Dr. Wilson');
INSERT INTO students_3nf VALUES (1, 'Aibek', 1), (2, 'Ainura', 1), (3, 'Bakyt', 2);

DELETE FROM students_3nf WHERE student_id = 3;
SELECT * FROM departments_3nf;   -- Mathematics is still there


-- ============================================================
-- 5. Design process: library management system
-- ============================================================
-- Requirements:  track books, authors, members, borrowing history;
--                a member borrows many books; a book has many authors;
--                due dates and late fees.
-- Conceptual:    Book, Author, Member, Loan
--                Author WRITES Book       (many-to-many -> book_authors)
--                Member BORROWS via Loan  (one-to-many)
-- Logical + physical design:

CREATE TABLE authors (
    author_id  SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    birth_date DATE
);

CREATE TABLE books (
    book_id          SERIAL PRIMARY KEY,
    title            VARCHAR(200) NOT NULL,
    isbn             VARCHAR(13) UNIQUE,
    publication_year INTEGER,
    available_copies INTEGER DEFAULT 1 CHECK (available_copies >= 0)
);

CREATE TABLE book_authors (
    book_id   INTEGER,
    author_id INTEGER,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id)   REFERENCES books(book_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

CREATE TABLE members (
    member_id       SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    phone           VARCHAR(15),
    membership_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE loans (
    loan_id     SERIAL PRIMARY KEY,
    member_id   INTEGER NOT NULL,
    book_id     INTEGER NOT NULL,
    loan_date   DATE DEFAULT CURRENT_DATE,
    due_date    DATE NOT NULL,
    return_date DATE,
    late_fee    DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id)   REFERENCES books(book_id),
    CHECK (due_date >= loan_date)
);

-- physical design: index the foreign keys used for joins
CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_book   ON loans(book_id);

INSERT INTO authors (first_name, last_name, birth_date) VALUES
('Chingiz',   'Aitmatov',  '1928-12-12'),
('Abraham',   'Silberschatz', NULL),
('Henry',     'Korth',     NULL),
('S.',        'Sudarshan', NULL);

INSERT INTO books (title, isbn, publication_year, available_copies) VALUES
('Jamilia',                       '9780863160936', 1958, 3),
('The Day Lasts More Than a Hundred Years', '9780253206015', 1980, 2),
('Database System Concepts',      '9780078022159', 2019, 5);

INSERT INTO book_authors VALUES (1, 1), (2, 1), (3, 2), (3, 3), (3, 4);

INSERT INTO members (first_name, last_name, email, phone) VALUES
('Aibek',  'Sharshenov',    'aibek@mail.kg',  '0555123456'),
('Meerim', 'Bekova',        'meerim@mail.kg', '0700654321');

INSERT INTO loans (member_id, book_id, loan_date, due_date, return_date, late_fee) VALUES
(1, 3, '2026-10-01', '2026-10-15', '2026-10-20', 2.50),   -- returned 5 days late
(1, 1, '2026-10-25', '2026-11-08', NULL,          0.00),
(2, 2, '2026-10-28', '2026-11-11', NULL,          0.00);

\dt

-- a book with several authors (many-to-many)
SELECT b.title, string_agg(a.first_name || ' ' || a.last_name, ', ' ORDER BY a.last_name) AS authors
FROM books b
JOIN book_authors ba ON ba.book_id = b.book_id
JOIN authors a       ON a.author_id = ba.author_id
GROUP BY b.title ORDER BY b.title;

-- borrowing history of every member
SELECT m.first_name || ' ' || m.last_name AS member, b.title,
       l.loan_date, l.due_date, l.return_date, l.late_fee
FROM loans l
JOIN members m ON m.member_id = l.member_id
JOIN books b   ON b.book_id = l.book_id
ORDER BY member, l.loan_date;

-- a due date before the loan date is refused by the CHECK
INSERT INTO loans (member_id, book_id, loan_date, due_date) VALUES (2, 1, '2026-11-01', '2026-10-01');


-- ============================================================
-- clean up
-- ============================================================
DROP VIEW student_age;
DROP TABLE
    enrollments, courses, professors, students, departments,
    students_bad, student_phones, students_1nf, enrollments_bad,
    enrollments_2nf, courses_2nf, students_3nf_bad, students_3nf,
    departments_3nf,
    loans, book_authors, books, authors, members;
\dt
