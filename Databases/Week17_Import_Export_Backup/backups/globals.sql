--
-- PostgreSQL database cluster dump
--

\restrict O4VYLqKg4Ehrdz1uJRkQf7Kwo7C9BIRbGlQeJ1IMGKWKsOhxamfrfARFGDMV6R3

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;
CREATE ROLE ulan;
ALTER ROLE ulan WITH SUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;

--
-- User Configurations
--

--
-- User Config "ulan"
--

ALTER ROLE ulan SET lc_messages TO 'C';








\unrestrict O4VYLqKg4Ehrdz1uJRkQf7Kwo7C9BIRbGlQeJ1IMGKWKsOhxamfrfARFGDMV6R3

--
-- PostgreSQL database cluster dump complete
--

