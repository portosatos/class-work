-- Week 11: Basic Data Operations
-- Topics: INSERT (one row, many rows, RETURNING, from SELECT), UPDATE,
--         DELETE, bulk import with COPY / \copy, bulk UPDATE and DELETE,
--         what happens without WHERE, TRUNCATE.
--
-- Run with (from this folder, students.csv is read from here):
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


DROP TABLE IF EXISTS students, students_archive;


-- ============================================================
-- 1. INSERT
-- ============================================================
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    birth_date DATE
);

-- one student
INSERT INTO students (first_name, last_name, birth_date)
VALUES ('Aibek', 'Sharshenov', '2002-05-12');

-- several students in one statement
INSERT INTO students (first_name, last_name, birth_date) VALUES
('Ainura', 'Toktomamatova', '2001-09-23'),
('Bakyt',  'Mamatov',       '2003-01-15'),
('Gulzat', 'Sultanova',     '2002-07-30');

-- RETURNING gives back the generated id without a second query
INSERT INTO students (first_name, last_name, birth_date)
VALUES ('Azamat', 'Uulu', '2000-12-01')
RETURNING student_id, first_name;

SELECT * FROM students ORDER BY student_id;


-- ============================================================
-- 2. UPDATE
-- ============================================================
UPDATE students
SET birth_date = '2002-05-15'
WHERE first_name = 'Aibek' AND last_name = 'Sharshenov';

-- several columns at once, and RETURNING the new values
UPDATE students
SET first_name = 'Bakytbek', birth_date = birth_date + 1
WHERE student_id = 3
RETURNING *;

-- a WHERE that matches nothing updates nothing
UPDATE students SET last_name = 'X' WHERE student_id = 999;

SELECT * FROM students ORDER BY student_id;


-- ============================================================
-- 3. DELETE
-- ============================================================
DELETE FROM students
WHERE first_name = 'Gulzat' AND last_name = 'Sultanova';

-- everyone born before 2002 -- Ainura and Azamat
DELETE FROM students
WHERE birth_date < '2002-01-01'
RETURNING student_id, first_name, birth_date;

SELECT * FROM students ORDER BY student_id;


-- ============================================================
-- 4. Bulk insert from a CSV file
-- ============================================================
-- \copy is the client-side twin of COPY: psql reads students.csv from this
-- folder and streams it to the server, so no superuser file access is needed.
\copy students(first_name, last_name, birth_date) FROM 'students.csv' DELIMITER ',' CSV HEADER

SELECT * FROM students ORDER BY student_id;

-- INSERT ... SELECT: copy rows from one table into another
CREATE TABLE students_archive (LIKE students);
INSERT INTO students_archive SELECT * FROM students WHERE birth_date < '2002-06-01';
SELECT * FROM students_archive;


-- ============================================================
-- 5. Bulk UPDATE and bulk DELETE
-- ============================================================
INSERT INTO students (first_name, last_name, birth_date) VALUES
('Ermek', 'Uulu', '2002-02-02');

UPDATE students
SET last_name = 'Bekov'
WHERE last_name IN ('Uulu', 'Isakov');

SELECT * FROM students ORDER BY student_id;

DELETE FROM students
WHERE student_id IN (2, 3, 5);

SELECT * FROM students ORDER BY student_id;


-- ============================================================
-- 6. Without WHERE every row is affected
-- ============================================================
BEGIN;
UPDATE students SET last_name = 'Oops';    -- every row
SELECT student_id, first_name, last_name FROM students ORDER BY student_id;
DELETE FROM students;                       -- every row
SELECT count(*) FROM students;
ROLLBACK;                                   -- undone, thanks to the transaction

SELECT count(*) FROM students;

-- TRUNCATE empties a table at once and can reset the SERIAL counter
TRUNCATE students_archive;
SELECT count(*) FROM students_archive;


-- ============================================================
-- clean up
-- ============================================================
DROP TABLE students, students_archive;
