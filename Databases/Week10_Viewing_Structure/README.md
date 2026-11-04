# Week 10: Viewing Database and Table Structure

`\l`, `\dt`, `\d`, `\d+`, `\di`, `\dv`, `\ds`, `\dn`, `\x`, the same
information through `information_schema` and `pg_catalog`, and an ER diagram
of the database.

Run on PostgreSQL 18.6 (Windows 10, EDB installer, port `1569`).

## How to run

```bash
psql -h localhost -p 1569 -U ulan -d ulan -f lab.sql
```

[`lab.sql`](lab.sql) creates a database `coffee`, loads
[`schema.sql`](schema.sql) into it (the six tables of the lecture example:
`suppliers`, `coffees`, `coffee_houses`, `cof_inventory`, `merch_inventory`,
`university_students`), explores it, and drops it at the end.
Transcript: [`output.txt`](output.txt), screenshots: [`screenshots/`](screenshots).

## `\dt` — the tables

![\l coffee, \dt and \dt+](screenshots/01-list-tables.png)

`\dt+` adds the size and the description.

## `\d table` — one table

Columns with type, collation, nullability and default, then indexes,
check constraints, foreign keys, and — on the parent side — `Referenced by`:

![\d coffee_houses and \d suppliers](screenshots/02-describe-table.png)

![\d coffees and \d cof_inventory: foreign keys](screenshots/03-foreign-keys-in-d.png)

`\d+` shows storage, compression and the comments set with `COMMENT ON`:

![\d+ coffees](screenshots/04-d-plus.png)

## The other `\d` commands

| Command | Lists |
|---|---|
| `\l` | databases |
| `\dn` | schemas |
| `\dt` | tables |
| `\di` | indexes |
| `\dv` | views |
| `\ds` | sequences |
| `\df` | functions |
| `\d` | all relations |

![\di, \dv, \ds, \dn](screenshots/05-other-objects.png)

## The same with SQL

`\d` is just a front-end for catalog queries. `information_schema` is the
SQL-standard way to ask the same questions, which also works from programs:

![columns of suppliers, and every foreign key in the database](screenshots/06-information-schema.png)

`\x on` turns wide rows into a vertical list; `pg_stat_user_tables` gives row
counts and sizes:

![\x and table sizes](screenshots/07-expanded-display.png)

## ER diagram

The foreign keys above, drawn as a diagram. In pgAdmin the same picture is
*database → Schemas → Tables → right click → ERD for database*; here it is
written in Mermaid so GitHub renders it:

```mermaid
erDiagram
    SUPPLIERS ||--o{ COFFEES : supplies
    SUPPLIERS ||--o{ COF_INVENTORY : "stocked from"
    SUPPLIERS ||--o{ MERCH_INVENTORY : supplies
    COFFEES ||--o{ COF_INVENTORY : "stored as"
    SUPPLIERS {
        integer sup_id PK "IDENTITY"
        varchar sup_name
        varchar street
        varchar city
        varchar state
        varchar zip
    }
    COFFEES {
        varchar cof_name PK
        integer sup_id FK
        real price
        integer sales
        integer total
    }
    COF_INVENTORY {
        integer warehouse_id PK
        varchar cof_name PK, FK
        integer sup_id PK, FK
        integer quan
        date date_val
    }
    MERCH_INVENTORY {
        integer item_id PK
        varchar item_name
        integer sup_id FK
        integer quan
        date date
    }
    COFFEE_HOUSES {
        integer store_id PK
        varchar city
        integer coffee
        integer merch
        integer total
    }
    UNIVERSITY_STUDENTS {
        integer student_id PK
        text first_name
        varchar last_name
        varchar email_address UK
        date date_of_birth
    }
```
