-- Week 10: the "coffee" database explored in lab.sql
-- (the same six tables as in the lecture example)

CREATE TABLE suppliers (
    sup_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sup_name VARCHAR(255) NOT NULL,
    street   VARCHAR(255),
    city     VARCHAR(255),
    state    VARCHAR(255),
    zip      VARCHAR(255)
);

CREATE TABLE coffees (
    cof_name VARCHAR(32) PRIMARY KEY,
    sup_id   INTEGER NOT NULL REFERENCES suppliers(sup_id),
    price    REAL CHECK (price >= 0),
    sales    INTEGER DEFAULT 0,
    total    INTEGER DEFAULT 0
);

CREATE TABLE coffee_houses (
    store_id INTEGER PRIMARY KEY,
    city     VARCHAR(255),
    coffee   INTEGER,
    merch    INTEGER,
    total    INTEGER
);

CREATE TABLE cof_inventory (
    warehouse_id INTEGER,
    cof_name     VARCHAR(32) REFERENCES coffees(cof_name),
    sup_id       INTEGER REFERENCES suppliers(sup_id),
    quan         INTEGER,
    date_val     DATE,
    PRIMARY KEY (warehouse_id, cof_name, sup_id)
);

CREATE TABLE merch_inventory (
    item_id   INTEGER PRIMARY KEY,
    item_name VARCHAR(255),
    sup_id    INTEGER REFERENCES suppliers(sup_id),
    quan      INTEGER,
    date      DATE
);

CREATE TABLE university_students (
    student_id    INTEGER PRIMARY KEY,
    first_name    TEXT NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email_address VARCHAR(100) UNIQUE,
    date_of_birth DATE
);

CREATE INDEX idx_coffees_sup ON coffees(sup_id);
CREATE VIEW coffee_sales AS
SELECT c.cof_name, s.sup_name, c.price, c.sales, c.price * c.sales AS revenue
FROM coffees c JOIN suppliers s USING (sup_id);

INSERT INTO suppliers (sup_name, street, city, state, zip) VALUES
('Acme, Inc.',       '99 Market Street', 'Groundsville', 'CA', '95199'),
('Superior Coffee',  '1 Party Place',    'Mendocino',    'CA', '95460'),
('The High Ground',  '100 Coffee Lane',  'Meadows',      'CA', '93966');

INSERT INTO coffees VALUES
('Colombian',          1, 7.99, 175, 1240),
('French_Roast',       2, 8.99, 150,  980),
('Espresso',           3, 9.99,  60,  410),
('Colombian_Decaf',    1, 8.99, 155,  700),
('French_Roast_Decaf', 2, 9.99,  90,  520);

INSERT INTO coffee_houses VALUES
(10023, 'Mendocino', 3450, 2005, 5455),
(33002, 'Seattle',   4699, 3109, 7808),
(10040, 'SF',        5386, 2841, 8227);

INSERT INTO cof_inventory VALUES
(1234, 'Colombian',    1, 500, '2026-10-01'),
(1234, 'French_Roast', 2, 300, '2026-10-01'),
(1234, 'Espresso',     3, 120, '2026-10-01');

INSERT INTO merch_inventory VALUES
(1, 'Cup_Large', 1, 28, '2026-10-01'),
(2, 'Cup_Small', 1, 36, '2026-10-01'),
(3, 'Saucer',    2, 64, '2026-10-01');

INSERT INTO university_students VALUES
(1, 'Aibek',  'Sharshenov',    'aibek@alatoo.edu.kg',  '2002-05-12'),
(2, 'Ainura', 'Toktomamatova', 'ainura@alatoo.edu.kg', '2001-09-23');
