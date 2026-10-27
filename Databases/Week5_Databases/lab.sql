-- Week 5: Databases
-- Topics: CREATE DATABASE, DROP DATABASE, naming conventions, switching databases
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


-- ============================================================
-- 0. Clean slate (so the script can be re-run safely)
-- ============================================================
DROP DATABASE IF EXISTS university;
DROP DATABASE IF EXISTS student_db;
DROP DATABASE IF EXISTS course_management;
DROP DATABASE IF EXISTS "StudentDB";


-- ============================================================
-- 1. Creating databases (CREATE DATABASE)
-- ============================================================
-- Syntax:
--   CREATE DATABASE database_name;

CREATE DATABASE university;

-- \l lists all databases, so we can confirm it was created
\l


-- ============================================================
-- 2. Switching between databases (\c)
-- ============================================================
-- Syntax:
--   \c database_name
--
-- \c is a psql meta-command: it closes the current connection and
-- opens a new one, so you never have two databases open at once.
-- The same thing from the shell:
--   psql -d university -U ulan -h localhost -p 1569

\c university

-- confirm where we are now
SELECT current_database() AS database, current_user AS "user";

-- put something inside the new database so it is not empty
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    title     VARCHAR(100),
    credits   INT
);

INSERT INTO courses (title, credits) VALUES
('Databases', 3),
('Algorithms', 4),
('Operating Systems', 3);

SELECT * FROM courses;

-- the table lives in `university` only; \dt in another database shows nothing


-- ============================================================
-- 3. Database naming conventions
-- ============================================================
-- Recommended:
--   * lowercase letters   -> avoids case-sensitivity issues
--   * snake_case          -> student_records
--   * no reserved keywords-> table, select, user
--   * short but descriptive
--
-- Good:  student_db, course_management
-- Avoid: StudentDB, "course management", select

CREATE DATABASE student_db;
CREATE DATABASE course_management;

-- A name that breaks the convention must be double-quoted every single
-- time, which is exactly why it is a bad name:
CREATE DATABASE "StudentDB";

\l

-- lowercase name -> connects unquoted
\c student_db
SELECT current_database() AS database;

-- mixed-case name -> only connects when quoted
\c "StudentDB"
SELECT current_database() AS database;

-- \c StudentDB   <-- would FAIL: the unquoted name is folded to
--                    lowercase "studentdb", which does not exist.
-- CREATE DATABASE select;  <-- would FAIL: `select` is a reserved keyword.


-- ============================================================
-- 4. Dropping databases (DROP DATABASE)
-- ============================================================
-- Syntax:
--   DROP DATABASE database_name;
--
-- WARNING: this cannot be undone.
-- Two rules:
--   * you cannot drop a database that is currently being accessed,
--   * so connect to another database first (here: the default `ulan`).

\c ulan

DROP DATABASE "StudentDB";
DROP DATABASE course_management;
DROP DATABASE student_db;
DROP DATABASE university;

-- confirm they are all gone
\l
