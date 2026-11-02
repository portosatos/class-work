-- Week 2: Installing PostgreSQL and pgAdmin
-- Checks that the freshly installed server works: version, connection,
-- where the data lives, roles and databases, and a password change.
--
-- Run with:
--   psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql


-- ============================================================
-- 1. Which server is running
-- ============================================================
SELECT version();
SHOW server_version;
\conninfo


-- ============================================================
-- 2. Where it lives and how it is configured
-- ============================================================
SHOW port;
SHOW data_directory;
SHOW config_file;
SHOW hba_file;
SHOW server_encoding;
SHOW listen_addresses;
SHOW max_connections;

SELECT pg_postmaster_start_time() AS server_started,
       now() - pg_postmaster_start_time() AS uptime;


-- ============================================================
-- 3. Roles and databases created by the installer
-- ============================================================
-- "postgres" is the superuser the installer creates;
-- "ulan" is the working role created right after installation.
\du
\l

SELECT rolname, rolsuper, rolcreatedb, rolcanlogin
FROM pg_roles
WHERE rolname IN ('postgres', 'ulan');


-- ============================================================
-- 4. Setting a password
-- ============================================================
-- The docs' step "ALTER USER ... WITH PASSWORD". A throwaway role is used so
-- the real password of ulan stays out of the repository.
DROP ROLE IF EXISTS week2_demo;
CREATE ROLE week2_demo LOGIN;
ALTER USER week2_demo WITH PASSWORD 'your_password';

-- the password is stored as a SCRAM-SHA-256 hash, never as plain text
SELECT rolname, left(rolpassword, 14) AS stored_as
FROM pg_authid WHERE rolname = 'week2_demo';

DROP ROLE week2_demo;


-- ============================================================
-- 5. Smoke test: the server stores and returns data
-- ============================================================
CREATE TABLE install_check (
    id         SERIAL PRIMARY KEY,
    note       TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);
INSERT INTO install_check (note) VALUES ('PostgreSQL 18 is installed and running');
SELECT id, note FROM install_check;
DROP TABLE install_check;
