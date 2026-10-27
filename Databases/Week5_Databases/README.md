# Week 5: Databases

Lab on database-level operations in PostgreSQL: creating databases, dropping
them, naming conventions, and switching between them.

Done locally on PostgreSQL **18.6** (Postgres.app on macOS, port `1569`).

## Files

| File | What it is |
|---|---|
| `lab.sql` | The lab itself — `CREATE DATABASE`, `\c`, naming conventions, `DROP DATABASE`. Re-runnable: it cleans up after itself. |
| `errors_demo.sql` | The lab's "Important Notes", demonstrated. Every statement here is *meant* to fail, so the exact PostgreSQL error is visible. |
| `output.txt` | Real psql transcript of both scripts running on my machine. |
| `screenshots/` | Screenshots of the session. |

## How to run

```bash
# from this folder
psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql
psql -h localhost -p 1569 -U ulan -d ulan -f errors_demo.sql
```

Replace `-p 1569 -U ulan -d ulan` with your own port / role / starting
database. On a default install that is just:

```bash
psql -U postgres -f lab.sql
```

To follow along interactively instead:

```bash
psql -h localhost -p 1569 -U ulan -d ulan
```

## What the lab covers

### 1. `CREATE DATABASE`

```sql
CREATE DATABASE university;
```

`\l` lists all databases and confirms it exists.

### 2. Switching databases — `\c`

```
\c university
```

`\c` is a **psql meta-command**, not SQL: it closes the current connection and
opens a new one, so you are never connected to two databases at once — that is
what "you must disconnect from the current database before switching" means.
The same thing straight from the shell:

```bash
psql -d university -U ulan -h localhost -p 1569
```

A table created in `university` exists only there — `\dt` in another database
shows nothing.

### 3. Naming conventions

| Rule | Why |
|---|---|
| lowercase only | unquoted names are folded to lowercase, so `StudentDB` and `studentdb` stop matching |
| `snake_case` | `student_records` is readable, `student records` is a syntax error |
| no reserved keywords | `CREATE DATABASE select;` does not parse |
| short but descriptive | you type it on every connect |

Good: `student_db`, `course_management` — Avoid: `StudentDB`, `course management`, `select`

### 4. `DROP DATABASE`

```sql
DROP DATABASE university;
```

**This cannot be undone.** Two rules, both shown in `errors_demo.sql`:

* you cannot drop the database you are connected to — `\c` somewhere else first;
* you cannot drop a database another session is using.

## The errors, verbatim

```
CREATE DATABASE select;
ERROR:  syntax error at or near "select"

CREATE DATABASE course management;
ERROR:  syntax error at or near ";"

DROP DATABASE StudentDB;          -- real name is "StudentDB"
ERROR:  database "studentdb" does not exist

DROP DATABASE university;         -- while connected to university
ERROR:  cannot drop the currently open database
```

The "being accessed by other users" case needs two terminals, so it is not in
the `.sql` file:

```bash
# terminal 1 — hold a connection open for 12 seconds
psql -h localhost -p 1569 -U ulan -d ulan -c "CREATE DATABASE demo_busy;"
psql -h localhost -p 1569 -U ulan -d demo_busy -c "SELECT pg_sleep(12);"

# terminal 2 — meanwhile
psql -h localhost -p 1569 -U ulan -d ulan -c "DROP DATABASE demo_busy;"
```

```
ERROR:  database "demo_busy" is being accessed by other users
DETAIL:  There is 1 other session using the database.
```

Once terminal 1 disconnects, the same `DROP DATABASE` succeeds.
