-- Week 3: Basic psql Commands
-- Connecting to PostgreSQL via psql:
--   psql -h localhost -p 1569 -U ulan -d ulan

-- Basic meta-commands used:
--   \l    list all databases
--   \dt   list tables in the current database
--   \du   list roles/users
--   \q    quit psql

-- Practicing basic commands: create a table, insert data, query it, drop it

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INT
);

INSERT INTO students (name, age) VALUES ('Alice', 21), ('Bob', 23);

SELECT * FROM students;

DROP TABLE students;
