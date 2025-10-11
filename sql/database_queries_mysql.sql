-- SQL script for Old Book Store (MySQL / XAMPP)
-- File: sql/database_queries_mysql.sql
-- Run this on your local XAMPP MySQL server (e.g., via phpMyAdmin, MySQL CLI, or MySQL Workbench).
-- This script demonstrates: pattern matching, REGEXP, MOD, aggregates, GROUP BY/HAVING/ORDER BY,
-- subqueries, set operations (UNION/INTERSECT/EXCEPT emulated), views, joins (inner/left/right/full via UNION),
-- self join, cross join, stored procedures/functions, cursors, handlers (exception-like), loops, IF/ELSE, user-defined array via JSON,
-- triggers, and sample data aligned with your book-management project structure.

-- WARNING: This script will create and drop tables in the current database. BACKUP if needed.

-- Use the database (create if doesn't exist)
CREATE DATABASE IF NOT EXISTS oldbookstore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE oldbookstore;

-- CLEANUP (DROP tables if exist)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS sellers;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

-- ====================================================
-- Create tables similar to your project: users, sellers, books, authors, book_authors
-- For simplicity we'll add minimal fields used in the examples
-- ====================================================
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  full_name VARCHAR(200),
  location VARCHAR(100),
  zip_code VARCHAR(20),
  status ENUM('active','suspended') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE sellers (
  seller_id INT AUTO_INCREMENT PRIMARY KEY,
  `id` INT GENERATED ALWAYS AS (seller_id) VIRTUAL,
  username VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  full_name VARCHAR(200),
  name VARCHAR(200) DEFAULT NULL,
  phone VARCHAR(40) DEFAULT NULL,
  profile_image VARCHAR(255) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  location VARCHAR(100),
  country VARCHAR(100) DEFAULT NULL,
  zip_code VARCHAR(20),
  status ENUM('active','suspended') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE books (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(300) NOT NULL,
  isbn VARCHAR(30),
  price DECIMAL(8,2) DEFAULT 0.00,
  `condition` VARCHAR(50),
  `binding` VARCHAR(50),
  `language` VARCHAR(50),
  is_active TINYINT(1) DEFAULT 1,
  product_type VARCHAR(50),
  seller_id INT,
  publisher VARCHAR(200),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE authors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE book_authors (
  book_id INT,
  author_id INT,
  PRIMARY KEY (book_id, author_id),
  FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
  FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Example enrollment/courses/teachers set to show joins & aggregates (optional)


-- Contacts table to demonstrate JSON array usage (phones) and object-like address
-- (contacts table removed; not used by PHP files)

-- ====================================================
-- Insert sample data for books, sellers, users, authors
-- ====================================================
INSERT INTO users (username,email,password,full_name,location,zip_code) VALUES
('alice','alice@example.com', 'hash','Alice Smith','Townsville','12345'),
('bob','bob.j@example.com','hash','Bob Johnson','Village','67890'),
('carol','carol_d@example.com','hash','Carol Davis','City','23456');

-- Sellers sample data - include password (use hashed values in production).
INSERT INTO sellers (username,email,password,full_name,name,location,zip_code) VALUES
('seller1','s1@example.com', 'hash','S1','Seller One','Townsville','12345'),
('seller2','s2@example.com', 'hash','S2','Seller Two','Village','67890');

INSERT INTO authors (name) VALUES ('Author A'), ('Author B'), ('Author C');

INSERT INTO books (title,isbn,price,`condition`,`binding`,`language`,product_type,seller_id,publisher) VALUES
('Intro to Computer Science','978-0001',49.99,'Used','Paperback','English','book',1,'ACME Publishing'),
('Data Structures','978-0002',69.50,'New','Hardcover','English','book',1,'ACME Publishing'),
('Calculus I','978-0003',39.99,'Used','Paperback','English','book',2,'MathBooks Inc'),
('Algorithms','978-0004',79.99,'New','Hardcover','English','book',2,'ACME Publishing');

INSERT INTO book_authors (book_id,author_id) VALUES (1,1),(2,1),(2,2),(3,3),(4,2);

-- (removed courses/teachers/enrollments demo inserts to keep script focused on books/sellers schema)

-- ====================================================
-- 1) Pattern matching, REGEXP, MOD examples
-- ====================================================
-- LIKE: books with title starting with 'Data'
SELECT * FROM books WHERE title LIKE 'Data%';

-- REGEXP: ISBNs containing only digits/dashes; extract via REGEXP
SELECT isbn, title FROM books WHERE isbn REGEXP '^[0-9-]+';

-- MySQL doesn't have REGEXP_SUBSTR before 8.0, but supports it in 8+ as REGEXP_SUBSTR
-- Example using REGEXP_SUBSTR (MySQL 8.0+):
SELECT isbn, REGEXP_SUBSTR(isbn, '[0-9]+') AS extracted_number FROM books;

-- MOD example: users with odd user_id (useful for small filters or samples)
SELECT * FROM users WHERE MOD(user_id,2) = 1;

-- ====================================================
-- 2) Aggregate functions, GROUP BY, HAVING, ORDER BY
-- ====================================================
-- Count books per seller
SELECT s.seller_id, s.username, COUNT(b.id) AS book_count, AVG(b.price) AS avg_price
FROM sellers s
LEFT JOIN books b ON s.seller_id = b.seller_id
GROUP BY s.seller_id, s.username
HAVING COUNT(b.id) > 0
ORDER BY book_count DESC;

-- BOOK MANAGEMENT ALIGNED EXAMPLES
-- Example A: Average book price per seller (useful for your project)
-- Finds sellers whose average listed price is >= 50
SELECT s.seller_id, s.username, COUNT(b.id) AS book_count, ROUND(AVG(b.price),2) AS avg_price
FROM sellers s
JOIN books b ON s.seller_id = b.seller_id
GROUP BY s.seller_id, s.username
HAVING AVG(b.price) >= 50
ORDER BY avg_price DESC;

-- Example B: Sellers with at least 2 books and average price ordered
SELECT s.seller_id, s.username, COUNT(b.id) AS book_count, ROUND(AVG(b.price),2) AS avg_price
FROM sellers s
LEFT JOIN books b ON s.seller_id = b.seller_id
GROUP BY s.seller_id, s.username
HAVING COUNT(b.id) >= 2
ORDER BY book_count DESC, avg_price DESC;

-- ====================================================
-- 3) Subqueries: scalar, correlated, EXISTS
-- ====================================================
-- Scalar subquery: find books sold by the same seller who sells book id=1
SELECT * FROM books WHERE seller_id = (SELECT seller_id FROM books WHERE id = 1 LIMIT 1);

-- Correlated subquery: sellers who sell a book cheaper than the average price
SELECT * FROM sellers s WHERE EXISTS (
  SELECT 1 FROM books b WHERE b.seller_id = s.seller_id AND b.price < (SELECT AVG(price) FROM books)
);

-- Subquery in SELECT
SELECT b.title, (SELECT GROUP_CONCAT(a.name SEPARATOR ', ') FROM book_authors ba JOIN authors a ON ba.author_id = a.id WHERE ba.book_id = b.id) AS authors
FROM books b;

-- ====================================================
-- 4) Set operations: UNION, INTERSECT (emulated), EXCEPT (emulated)
-- ====================================================
-- UNION: list all contact emails from users and sellers (UNION removes duplicates)
SELECT email FROM users
UNION
SELECT email FROM sellers;

-- INTERSECT emulation: common titles between two conditions
-- MySQL (pre-8.0) does not support INTERSECT — emulate with INNER JOIN on derived tables
SELECT t1.title FROM (SELECT title FROM books WHERE price >= 50) t1
INNER JOIN (SELECT title FROM books WHERE title LIKE 'Data%') t2 USING (title);

-- EXCEPT / MINUS emulation: books with price >=50 but not matching title pattern
SELECT title FROM books WHERE price >= 50
AND title NOT IN (SELECT title FROM books WHERE title LIKE 'Data%');

-- ====================================================
-- 5) Views
-- ====================================================
-- (views demo removed to keep script focused on books/sellers schema)

-- ====================================================
-- 6) JOIN examples: INNER, LEFT/RIGHT, CROSS, SELF JOIN
-- ====================================================
-- INNER JOIN: books with seller name
SELECT b.title, s.username AS seller_name FROM books b
JOIN sellers s ON b.seller_id = s.seller_id;

-- LEFT JOIN: all sellers and their books (if any)
SELECT s.username, b.title FROM sellers s LEFT JOIN books b ON s.seller_id = b.seller_id;

-- RIGHT JOIN: all books and their seller (if any) — equivalent to left with tables swapped
SELECT b.title, s.username FROM books b RIGHT JOIN sellers s ON b.seller_id = s.seller_id;

-- FULL OUTER JOIN emulation (MySQL doesn't support FULL JOIN) using UNION
SELECT s.seller_id, s.username, b.id AS book_id, b.title FROM sellers s LEFT JOIN books b ON s.seller_id = b.seller_id
UNION
SELECT s.seller_id, s.username, b.id AS book_id, b.title FROM sellers s RIGHT JOIN books b ON s.seller_id = b.seller_id;

-- CROSS JOIN (Cartesian product) — use with care
SELECT s.username, b.title FROM sellers s CROSS JOIN books b LIMIT 10;

-- SELF JOIN: find pairs of books by same seller
SELECT b1.id AS b1, b1.title AS title1, b2.id AS b2, b2.title AS title2
FROM books b1 JOIN books b2 ON b1.seller_id = b2.seller_id AND b1.id < b2.id;

-- NATURAL JOIN: rarely used; demonstrate with small temp tables if needed
-- (Omitted — generally discouraged in production)

-- ====================================================
-- 7) Stored routines: procedures, functions, cursors, handlers, loops, IF/ELSE
-- ====================================================
DELIMITER $$
CREATE PROCEDURE proc_give_discount(IN p_seller INT, IN p_percent DECIMAL(5,2))
BEGIN
  -- Give discount to all books of a seller by reducing price by p_percent percent
  UPDATE books SET price = ROUND(price * (1 - p_percent/100),2) WHERE seller_id = p_seller;
END$$

CREATE FUNCTION fn_avg_price_by_seller(p_seller INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE v_avg DECIMAL(10,2);
  SELECT AVG(price) INTO v_avg FROM books WHERE seller_id = p_seller;
  RETURN IFNULL(v_avg,0);
END$$

-- Example of a stored procedure using a cursor and loop to compute something and use handlers (exception-like)
CREATE PROCEDURE proc_count_books_by_author()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE a_id INT;
  DECLARE a_name VARCHAR(200);
  DECLARE cur CURSOR FOR SELECT id, name FROM authors;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO a_id, a_name;
    IF done THEN
      LEAVE read_loop;
    END IF;
    SELECT a_name AS author, COUNT(ba.book_id) AS book_count FROM book_authors ba WHERE ba.author_id = a_id GROUP BY a_name;
  END LOOP;
  CLOSE cur;
END$$

DELIMITER ;

-- Call examples (use in client):
-- CALL proc_give_discount(1,10);
-- SELECT fn_avg_price_by_seller(1);
-- CALL proc_count_books_by_author();

-- ====================================================
-- 8) Emulate user-defined types / arrays: use JSON and helper functions
-- ====================================================
-- (JSON/contacts examples removed; sellers/books/users schema is used by the PHP app)

-- ====================================================
-- 9) Trigger examples: validate data and auto-update timestamps
-- ====================================================
DELIMITER $$
CREATE TRIGGER trg_books_price_check BEFORE INSERT ON books
FOR EACH ROW
BEGIN
  IF NEW.price < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price must be non-negative';
  END IF;
END$$

CREATE TRIGGER trg_books_after_insert AFTER INSERT ON books
FOR EACH ROW
BEGIN
  -- Example: Insert into contacts table to demo trigger side-effect (not recommended in prod)
  -- INSERT INTO contacts (name, addr, phones) VALUES (CONCAT('Auto-',NEW.title), JSON_OBJECT('street','','city','','zip',''), JSON_ARRAY());
  -- For safety, we will just set a user variable
  SET @last_inserted_book = NEW.id;
END$$
DELIMITER ;

-- ====================================================
-- 10) Additional advanced examples: complex subquery, window functions (MySQL 8+), ranking
-- ====================================================
-- Window function example: rank sellers by average price (MySQL 8+)
SELECT seller_id, AVG(price) AS avg_price, RANK() OVER (ORDER BY AVG(price) DESC) AS seller_rank
FROM books GROUP BY seller_id;

-- ====================================================
-- 11) Clean up notes
-- ====================================================
-- To drop the database after testing:
-- DROP DATABASE oldbookstore;

-- End of script
