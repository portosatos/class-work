-- Week 5: Databases -- the "Important Notes" from the lab, demonstrated
--
-- Every statement in this file is MEANT TO FAIL. The point is to see the
-- exact error PostgreSQL gives, so the rules are not just words.
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f errors_demo.sql


-- ------------------------------------------------------------
-- (1) Reserved keywords cannot be used as a database name
-- ------------------------------------------------------------
-- expected: ERROR: syntax error at or near "select"
CREATE DATABASE select;


-- ------------------------------------------------------------
-- (2) A name with a space is two tokens -> syntax error
-- ------------------------------------------------------------
-- expected: ERROR: syntax error at or near ";"
CREATE DATABASE course management;


-- ------------------------------------------------------------
-- (3) Unquoted names are folded to lowercase
-- ------------------------------------------------------------
CREATE DATABASE "StudentDB";

-- expected: ERROR: database "studentdb" does not exist
--           (the real name is "StudentDB" with capitals)
DROP DATABASE StudentDB;

-- this one works, because the name is quoted exactly as created
DROP DATABASE "StudentDB";


-- ------------------------------------------------------------
-- (4) You cannot drop the database you are connected to
-- ------------------------------------------------------------
CREATE DATABASE university;
\c university

-- expected: ERROR: cannot drop the currently open database
DROP DATABASE university;

-- the fix: switch somewhere else first, then drop
\c ulan
DROP DATABASE university;
