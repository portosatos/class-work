-- Week 4: First SQL Query
-- Topics: SELECT structure, WHERE, ORDER BY, LIMIT, comments

-- Create the students table
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    faculty VARCHAR(50),
    phone_number VARCHAR(20),
    age INT
);

-- Insert sample data
INSERT INTO students (name, email, faculty, phone_number, age) VALUES
('Alymbek', 'alymbek@example.com', 'COMSEH', '+996700111222', 20),
('Timur', 'timur@example.com', 'MED', '+996700333444', 22),
('Beka', 'beka@example.com', 'MAT', '+996700555666', 21),
('Aidana', 'aidana@example.com', 'LAW', '+996700777888', 23),
('Nurlan', 'nurlan@example.com', 'ENG', '+996700999000', 19);

-- View all data
SELECT * FROM students;

-- SELECT specific columns
SELECT name, email FROM students;

-- WHERE clause: filtering
SELECT name, email FROM students WHERE name = 'Timur';
SELECT name, faculty FROM students WHERE faculty = 'MED';

-- ORDER BY: sorting
SELECT name, age FROM students ORDER BY age;
SELECT name, age FROM students ORDER BY age DESC;

-- LIMIT: restricting number of rows returned
SELECT name, email FROM students LIMIT 2;

-- Comments
-- This is a single-line comment
/* This is a
   multi-line comment */
SELECT name FROM students;
