-- Week 10: Viewing Database and Table Structure
-- Topics: \l, \dt, \d, \d+, \dn, \di, \dv, \ds, \df, \x, information_schema
--         and pg_catalog queries, and an ER diagram of the database.
--
-- Run with (from this folder, schema.sql is included):
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


DROP DATABASE IF EXISTS coffee;
CREATE DATABASE coffee;
\c coffee
\i schema.sql


-- ============================================================
-- 1. Databases and schemas
-- ============================================================
\l coffee
\dn
SELECT current_database(), current_schema();


-- ============================================================
-- 2. \dt -- all tables in the current database
-- ============================================================
\dt

-- with size and description
\dt+


-- ============================================================
-- 3. \d table_name -- the structure of one table
-- ============================================================
\d coffee_houses

-- columns, types, nullability, defaults, indexes, constraints, and the
-- tables that point at it ("Referenced by")
\d suppliers
\d coffees
\d cof_inventory

-- \d+ adds storage, compression, stats target and description
COMMENT ON TABLE coffees IS 'Coffee blends sold, one row per blend';
COMMENT ON COLUMN coffees.total IS 'Total pounds sold to date';
\d+ coffees


-- ============================================================
-- 4. Other objects
-- ============================================================
-- \d with no name: every relation -- tables, views, sequences
\d
-- indexes
\di
-- views, and the definition of one
\dv
\d+ coffee_sales
-- sequences (the IDENTITY column of suppliers has one)
\ds
-- functions (a built-in one as an example)
\df pg_catalog.lower


-- ============================================================
-- 5. The same information with SQL (information_schema)
-- ============================================================
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT column_name, data_type, character_maximum_length AS max_len,
       is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'suppliers'
ORDER BY ordinal_position;

-- every relationship in the database: the edges of the ER diagram
SELECT tc.table_name  AS child_table,
       kcu.column_name AS child_column,
       ccu.table_name  AS parent_table,
       ccu.column_name AS parent_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
     ON kcu.constraint_name = tc.constraint_name
JOIN information_schema.constraint_column_usage ccu
     ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY child_table, child_column;

-- row counts and on-disk size per table
SELECT relname AS table_name, n_live_tup AS rows,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
ORDER BY relname;


-- ============================================================
-- 6. Expanded display for wide rows
-- ============================================================
\x on
SELECT * FROM suppliers WHERE sup_id = 1;
\x off


-- ============================================================
-- clean up
-- ============================================================
\c ulan
DROP DATABASE coffee;
