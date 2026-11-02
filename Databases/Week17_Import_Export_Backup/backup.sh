#!/bin/bash
# Week 17: Data Import/Export and Backup -- part 2, backups
# pg_dump (plain, custom, per table, schema-only, data-only, excluding
# tables), pg_restore (list, full, one table, parallel), pg_dumpall for the
# roles, pg_basebackup for a physical base backup, and validation.
#
# Needs the "company" database created by lab.sql. Run from this folder:
#   bash backup.sh
#
# Connection settings come from the environment (password from PGPASSWORD
# or the pgpass file):
export PGHOST=${PGHOST:-localhost} PGPORT=${PGPORT:-1569} PGUSER=${PGUSER:-ulan}

set -x
mkdir -p backups

# ---------------------------------------------------------------
# 1. pg_dump
# ---------------------------------------------------------------
# plain SQL -- a readable script of CREATE + COPY statements
pg_dump -d company > backups/company.sql

# custom format: compressed, restorable with pg_restore (recommended)
pg_dump -d company -Fc > backups/company.dump

# only two tables
pg_dump -d company -t employees -t departments > backups/tables_backup.sql

# verbose
pg_dump -d company -Fc -v -f backups/company_verbose.dump 2>&1 | head -8

# schema only / data only
pg_dump -d company -s > backups/schema_only.sql
pg_dump -d company -a > backups/data_only.sql

# everything except the log table
pg_dump -d company -T log_table > backups/backup_without_logs.sql

# without ownership (-O), handy when restoring as another user
pg_dump -d company -Fc -O > backups/backup_no_owner.dump

ls -l backups
grep -c 'log line' backups/company.sql backups/backup_without_logs.sql
head -40 backups/schema_only.sql | grep -v '^--' | grep -v '^$'

# ---------------------------------------------------------------
# 2. pg_restore
# ---------------------------------------------------------------
# what is inside the archive (also a quick integrity check)
pg_restore --list backups/company.dump | grep -v '^;'

# restore into a new database
dropdb --if-exists company_restored
createdb company_restored
pg_restore -d company_restored backups/company.dump

# restore a single table into yet another database
dropdb --if-exists company_one_table
createdb company_one_table
pg_restore -d company_one_table -t employees backups/company.dump
psql -d company_one_table -c '\dt'

# parallel restore with 4 jobs
dropdb --if-exists company_parallel
createdb company_parallel
pg_restore -d company_parallel -j 4 backups/company.dump

# ---------------------------------------------------------------
# 3. Validation: the copies have the same row counts as the source
# ---------------------------------------------------------------
for db in company company_restored company_parallel; do
  psql -d "$db" -Atc "SELECT '$db', (SELECT count(*) FROM employees), (SELECT count(*) FROM customers), (SELECT count(*) FROM log_table)"
done

# ---------------------------------------------------------------
# 4. Whole cluster: roles and other global objects
# ---------------------------------------------------------------
# --no-role-passwords keeps password hashes out of the file
pg_dumpall --globals-only --no-role-passwords > backups/globals.sql
grep -E '^(CREATE|ALTER) ROLE' backups/globals.sql

# ---------------------------------------------------------------
# 5. Physical base backup (the starting point for WAL replay / PITR)
# ---------------------------------------------------------------
BASE=$(mktemp -d)
pg_basebackup -D "$BASE" -Ft -z -P
ls -l "$BASE"
rm -rf "$BASE"          # several MB, not kept in the repository

# ---------------------------------------------------------------
# clean up the extra databases; keep the dump files
# ---------------------------------------------------------------
dropdb company_one_table
dropdb company_parallel
dropdb company_restored
dropdb company
rm backups/company_verbose.dump
