# Week 6: Tables, Data Types and Constraints

`CREATE TABLE`, data types, constraints, `ALTER TABLE`, naming conventions,
temporary tables, `DROP TABLE`.

Run on PostgreSQL 18.6 (Postgres.app, macOS, port `1569`).

## How to run

```bash
psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql
```

Everything is in [`lab.sql`](lab.sql); the script cleans up after itself, so it
can be run again.

## What it does

Two tables — `students` and `enrollments` — covering `SERIAL`, `INTEGER`,
`VARCHAR(n)`, `TEXT`, `BOOLEAN`, `DATE`, and all five constraints:
`PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `CHECK`, `FOREIGN KEY`.

Then four inserts that **fail on purpose**, one per constraint, so the rules
are visible and not just declared:

```
duplicate key value violates unique constraint "students_email_key"
null value in column "first_name" ... violates not-null constraint
new row for relation "enrollments" violates check constraint "enrollments_grade_check"
insert or update on table "enrollments" violates foreign key constraint
```

`ALTER TABLE` is shown in all five forms: add a column, change a column's
type, add a constraint, rename a column, rename the table, drop a column.

A `TEMP TABLE` is built from a join — `\dt` shows it in schema `pg_temp_40`
instead of `public`, and it disappears when the session ends.

Finally `DROP TABLE student` fails while `enrollments` still points at it:

```
ERROR:  cannot drop table student because other objects depend on it
DETAIL:  constraint enrollments_student_id_fkey on table enrollments depends on table student
```

Child table first, then the parent — and `DROP TABLE IF EXISTS` turns the
second attempt into a notice instead of an error.

## Naming conventions

| Rule | Example |
|---|---|
| descriptive names | `student`, `course_enrollment`, `instructor` |
| lowercase + underscores | `course_id`, not `courseID` or `CourseId` |
| singular table names | `student` rather than `students` (be consistent) |
| primary key | `id` or `<table>_id` → `student_id` |
| foreign key | same name as the key it points at → `student_id` |

The lab renames `students` → `student` with `ALTER TABLE ... RENAME TO` to
show the convention in practice.
