-- ====================================================
-- SHININOMORI BOOKSTORE - USEFUL QUERIES
-- File: 05_queries.sql
-- Purpose: All standalone SELECT queries used in project pages
-- This file contains queries organized by page and SQL topics
-- ====================================================

USE oldbookstore;

-- ====================================================
-- SECTION 1: PATTERN MATCHING & FILTERING QUERIES
-- SQL Topics: LIKE, REGEXP, MOD, BETWEEN, IN
-- ====================================================

-- Query: Search books by title pattern
-- Used in: Search functionality, browse.php
-- Topics: LIKE operator, Pattern matching
SELECT * FROM books 
WHERE title LIKE '%Harry%' 
  AND status = 'approved';

-- Query: Find books with valid ISBN format
-- Used in: Data validation, admin panel
-- Topics: REGEXP, Regular expressions
SELECT isbn, title FROM books 
WHERE isbn REGEXP '^[0-9-]+$';

-- Query: Find books in specific price range
-- Used in: browse.php, price filters
-- Topics: BETWEEN operator, Range filtering
SELECT title, price, condition FROM books 
WHERE price BETWEEN 300 AND 500 
  AND status = 'approved'
ORDER BY price ASC;

-- Query: Find books by specific conditions
-- Used in: browse.php, condition filters
-- Topics: IN operator, Multiple value matching
SELECT title, `condition`, price FROM books 
WHERE `condition` IN ('New', 'Used') 
  AND status = 'approved';

-- ====================================================
-- SECTION 2: AGGREGATE FUNCTIONS & GROUP BY
-- SQL Topics: COUNT, AVG, SUM, MAX, MIN, GROUP BY, HAVING
-- ====================================================

-- Query: Count books per seller
-- Used in: seller_dashboard.php, admin dashboard
-- Topics: COUNT, GROUP BY, LEFT JOIN
SELECT s.seller_id, s.username, s.full_name,
       COUNT(b.id) AS total_books,
       COUNT(CASE WHEN b.status = 'approved' THEN 1 END) AS approved_books
FROM sellers s
LEFT JOIN books b ON s.seller_id = b.seller_id
GROUP BY s.seller_id, s.username, s.full_name;

-- Query: Average book price per seller
-- Used in: seller statistics, analytics
-- Topics: AVG, GROUP BY, HAVING, ORDER BY
SELECT s.seller_id, s.username, 
       COUNT(b.id) AS book_count, 
       ROUND(AVG(b.price), 2) AS avg_price
FROM sellers s
JOIN books b ON s.seller_id = b.seller_id
WHERE b.status = 'approved'
GROUP BY s.seller_id, s.username
HAVING AVG(b.price) >= 300
ORDER BY avg_price DESC;

-- Query: Total revenue per seller
-- Used in: seller_dashboard.php, revenue reports
-- Topics: SUM, COUNT, WHERE, GROUP BY
SELECT s.seller_id, s.username, s.full_name,
       COUNT(o.order_id) AS total_orders,
       COUNT(CASE WHEN o.status = 'completed' THEN 1 END) AS completed_orders,
       SUM(CASE WHEN o.status = 'completed' THEN o.total_amount ELSE 0 END) AS total_revenue
FROM sellers s
LEFT JOIN orders o ON s.seller_id = o.seller_id
GROUP BY s.seller_id, s.username, s.full_name
ORDER BY total_revenue DESC;

-- Query: Find highest and lowest priced books
-- Used in: Analytics, price analysis
-- Topics: MAX, MIN, Subqueries
SELECT 
    (SELECT title FROM books WHERE price = (SELECT MAX(price) FROM books WHERE status = 'approved')) AS highest_priced,
    (SELECT MAX(price) FROM books WHERE status = 'approved') AS max_price,
    (SELECT title FROM books WHERE price = (SELECT MIN(price) FROM books WHERE status = 'approved')) AS lowest_priced,
    (SELECT MIN(price) FROM books WHERE status = 'approved') AS min_price;

-- ====================================================
-- SECTION 3: JOIN QUERIES
-- SQL Topics: INNER JOIN, LEFT JOIN, Multiple JOINS
-- ====================================================

-- Query: Get books with seller information
-- Used in: browse.php, search results, book_detail.php
-- Topics: INNER JOIN, SELECT from multiple tables
SELECT b.id, b.title, b.price, b.condition, b.cover_image,
       s.seller_id, s.username, s.full_name AS seller_name, s.location
FROM books b
INNER JOIN sellers s ON b.seller_id = s.seller_id
WHERE b.status = 'approved';

-- Query: Get all sellers with their book count (including sellers with no books)
-- Used in: sellers.php, seller directory
-- Topics: LEFT JOIN, COUNT, GROUP BY
SELECT s.seller_id, s.username, s.full_name, s.location, s.description, s.profile_image,
       COUNT(b.id) AS book_count
FROM sellers s
LEFT JOIN books b ON s.seller_id = b.seller_id AND b.status = 'approved'
GROUP BY s.seller_id
ORDER BY book_count DESC;

-- Query: Get books with authors (multiple authors per book)
-- Used in: book_detail.php, browse.php, search results
-- Topics: Multiple INNER JOINs, GROUP_CONCAT
SELECT b.id, b.title, b.price, b.condition, b.cover_image,
       s.username AS seller,
       GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors
FROM books b
INNER JOIN sellers s ON b.seller_id = s.seller_id
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
WHERE b.status = 'approved'
GROUP BY b.id, b.title, b.price, b.condition, s.username;

-- Query: Get book with full details (seller, authors, rating)
-- Used in: book_detail.php
-- Topics: Multiple JOINs, AVG, COUNT, GROUP BY
SELECT b.*, 
       s.seller_id, s.username, s.full_name AS seller_name, s.location, s.profile_image,
       GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors,
       IFNULL(ROUND(AVG(br.rating), 2), 0) AS avg_rating,
       COUNT(DISTINCT br.rating_id) AS rating_count
FROM books b
INNER JOIN sellers s ON b.seller_id = s.seller_id
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
LEFT JOIN book_ratings br ON b.id = br.book_id
WHERE b.id = ? -- Parameter: book_id
GROUP BY b.id;

-- ====================================================
-- SECTION 4: USER DASHBOARD QUERIES
-- SQL Topics: WHERE, ORDER BY, LIMIT
-- ====================================================

-- Query: Get user's recent orders
-- Used in: user_dashboard.php, user_orders.php
-- Topics: JOIN, WHERE, ORDER BY
SELECT o.order_id, o.quantity, o.total_amount, o.status, o.order_date,
       b.title, b.cover_image, b.price,
       s.username AS seller_name, s.full_name AS seller_full_name
FROM orders o
JOIN books b ON o.book_id = b.id
JOIN sellers s ON o.seller_id = s.seller_id
WHERE o.user_id = ? -- Parameter: user_id
ORDER BY o.order_date DESC
LIMIT 10;

-- Query: Get user's wishlist
-- Used in: user_dashboard.php, user_wishlist.php
-- Topics: JOIN, WHERE, ORDER BY
SELECT w.wishlist_id, w.added_at,
       b.id, b.title, b.price, b.condition, b.cover_image,
       s.username AS seller_name,
       GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors
FROM wishlist w
JOIN books b ON w.book_id = b.id
JOIN sellers s ON b.seller_id = s.seller_id
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
WHERE w.user_id = ? -- Parameter: user_id
GROUP BY b.id
ORDER BY w.added_at DESC;

-- Query: Get user's recently viewed books
-- Used in: user_dashboard.php
-- Topics: JOIN, DISTINCT, ORDER BY, LIMIT
SELECT DISTINCT b.id, b.title, b.price, b.cover_image,
       ubv.viewed_at,
       s.username AS seller_name
FROM user_book_views ubv
JOIN books b ON ubv.book_id = b.id
JOIN sellers s ON b.seller_id = s.seller_id
WHERE ubv.user_id = ? -- Parameter: user_id
  AND b.status = 'approved'
ORDER BY ubv.viewed_at DESC
LIMIT 10;

-- ====================================================
-- SECTION 5: SELLER DASHBOARD QUERIES
-- SQL Topics: Subqueries, CASE, Aggregate functions
-- ====================================================

-- Query: Get seller's books
-- Used in: seller_dashboard.php, seller book management
-- Topics: WHERE, ORDER BY
SELECT b.id, b.title, b.price, b.condition, b.status, b.cover_image, b.created_at,
       GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
WHERE b.seller_id = ? -- Parameter: seller_id
GROUP BY b.id
ORDER BY b.created_at DESC;

-- Query: Get seller's pending orders
-- Used in: seller_dashboard.php, seller_orders.php
-- Topics: JOIN, WHERE, ORDER BY
SELECT o.order_id, o.quantity, o.total_amount, o.status, o.order_date,
       b.title, b.cover_image,
       u.username, u.full_name AS buyer_name, u.email, u.phone
FROM orders o
JOIN books b ON o.book_id = b.id
JOIN users u ON o.user_id = u.user_id
WHERE o.seller_id = ? -- Parameter: seller_id
  AND o.status = 'pending'
ORDER BY o.order_date DESC;

-- Query: Get seller's completed orders
-- Used in: seller_orders.php, revenue reports
-- Topics: JOIN, WHERE, DATE functions
SELECT o.order_id, o.quantity, o.total_amount, o.order_date, o.updated_at,
       b.title,
       u.username, u.full_name AS buyer_name
FROM orders o
JOIN books b ON o.book_id = b.id
JOIN users u ON o.user_id = u.user_id
WHERE o.seller_id = ? -- Parameter: seller_id
  AND o.status = 'completed'
ORDER BY o.updated_at DESC;

-- Query: Seller's revenue this month
-- Used in: seller_dashboard.php
-- Topics: SUM, WHERE, DATE functions
SELECT IFNULL(SUM(total_amount), 0) AS monthly_revenue
FROM orders
WHERE seller_id = ? -- Parameter: seller_id
  AND status = 'completed'
  AND MONTH(order_date) = MONTH(CURDATE())
  AND YEAR(order_date) = YEAR(CURDATE());

-- ====================================================
-- SECTION 6: SELLER PROFILE QUERIES
-- SQL Topics: JOIN, AVG, COUNT
-- ====================================================

-- Query: Get seller profile with statistics
-- Used in: seller_profile.php
-- Topics: Multiple JOINs, Aggregate functions
SELECT s.*,
       COUNT(DISTINCT b.id) AS total_books,
       IFNULL(ROUND(AVG(sr.rating), 2), 0) AS avg_rating,
       COUNT(DISTINCT sr.rating_id) AS rating_count
FROM sellers s
LEFT JOIN books b ON s.seller_id = b.seller_id AND b.status = 'approved'
LEFT JOIN seller_ratings sr ON s.seller_id = sr.seller_id
WHERE s.seller_id = ? -- Parameter: seller_id
GROUP BY s.seller_id;

-- Query: Get seller's ratings and reviews
-- Used in: seller_profile.php
-- Topics: JOIN, ORDER BY
SELECT sr.rating, sr.review, sr.created_at,
       u.username, u.full_name
FROM seller_ratings sr
JOIN users u ON sr.user_id = u.user_id
WHERE sr.seller_id = ? -- Parameter: seller_id
ORDER BY sr.created_at DESC
LIMIT 10;

-- Query: Check if user can rate seller (has completed purchase)
-- Used in: seller_profile.php
-- Topics: EXISTS, Subquery
SELECT EXISTS(
    SELECT 1
    FROM orders
    WHERE user_id = ? -- Parameter: user_id
      AND seller_id = ? -- Parameter: seller_id
      AND status = 'completed'
) AS can_rate;

-- ====================================================
-- SECTION 7: ADMIN DASHBOARD QUERIES
-- SQL Topics: COUNT, DATE functions, Status filters
-- ====================================================

-- Query: Count today's new users
-- Used in: admin_dashboard.php
-- Topics: COUNT, DATE function
SELECT COUNT(*) as new_users_today
FROM users
WHERE DATE(created_at) = CURDATE();

-- Query: Count today's new sellers
-- Used in: admin_dashboard.php
-- Topics: COUNT, DATE function
SELECT COUNT(*) as new_sellers_today
FROM sellers
WHERE DATE(created_at) = CURDATE();

-- Query: Count pending book approvals
-- Used in: admin_dashboard.php
-- Topics: COUNT, WHERE
SELECT COUNT(*) as pending_books
FROM books
WHERE status = 'pending';

-- Query: Get all pending books for approval
-- Used in: admin_dashboard.php, admin book approval
-- Topics: JOIN, WHERE, ORDER BY
SELECT b.id, b.title, b.price, b.condition, b.cover_image, b.created_at,
       s.username AS seller_name, s.full_name,
       GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors
FROM books b
JOIN sellers s ON b.seller_id = s.seller_id
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
WHERE b.status = 'pending'
GROUP BY b.id
ORDER BY b.created_at DESC;

-- Query: Get all users with status
-- Used in: admin_dashboard.php, user management
-- Topics: SELECT, ORDER BY
SELECT user_id, username, email, full_name, status, created_at
FROM users
ORDER BY created_at DESC;

-- Query: Get all sellers with status
-- Used in: admin_dashboard.php, seller management
-- Topics: SELECT, ORDER BY
SELECT seller_id, username, email, full_name, status, created_at
FROM sellers
ORDER BY created_at DESC;

-- ====================================================
-- SECTION 8: SEARCH & AUTOCOMPLETE QUERIES
-- SQL Topics: LIKE, DISTINCT, LIMIT
-- ====================================================

-- Query: Search authors by name
-- Used in: Autocomplete, search suggestions
-- Topics: LIKE, DISTINCT, LIMIT
SELECT DISTINCT name
FROM authors
WHERE LOWER(name) LIKE CONCAT('%', LOWER(?), '%') -- Parameter: search_term
ORDER BY name
LIMIT 10;

-- Query: Search sellers by name/location
-- Used in: sellers.php, seller search
-- Topics: LIKE, OR, ORDER BY
SELECT seller_id, username, full_name, location, profile_image, description
FROM sellers
WHERE status = 'active'
  AND (
      LOWER(username) LIKE CONCAT('%', LOWER(?), '%') OR
      LOWER(full_name) LIKE CONCAT('%', LOWER(?), '%') OR
      LOWER(location) LIKE CONCAT('%', LOWER(?), '%')
  )
ORDER BY username
LIMIT 20;

-- ====================================================
-- SECTION 9: NOTIFICATION QUERIES
-- SQL Topics: WHERE, ORDER BY, UPDATE
-- ====================================================

-- Query: Get user notifications
-- Used in: user_notifications.php, api/get_notifications.php
-- Topics: WHERE, ORDER BY, LIMIT
SELECT notification_id, title, message, type, is_read, related_id, created_at
FROM notifications
WHERE user_id = ? -- Parameter: user_id
ORDER BY created_at DESC, is_read ASC
LIMIT 50;

-- Query: Get seller notifications
-- Used in: seller_notifications.php, api/get_notifications.php
-- Topics: WHERE, ORDER BY, LIMIT
SELECT notification_id, title, message, type, is_read, related_id, created_at
FROM notifications
WHERE seller_id = ? -- Parameter: seller_id
ORDER BY created_at DESC, is_read ASC
LIMIT 50;

-- Query: Count unread notifications for user
-- Used in: Navigation, notification badge
-- Topics: COUNT, WHERE
SELECT COUNT(*) AS unread_count
FROM notifications
WHERE user_id = ? -- Parameter: user_id
  AND is_read = 0;

-- ====================================================
-- SECTION 10: MESSAGING QUERIES
-- SQL Topics: WHERE, GROUP BY, MAX
-- ====================================================

-- Query: Get user's conversations
-- Used in: Messaging system, conversation list
-- Topics: Subquery, MAX, GROUP BY
SELECT conversation_id,
       MAX(sent_at) AS last_message_time,
       SUM(CASE WHEN is_read = 0 AND receiver_user_id = ? THEN 1 ELSE 0 END) AS unread_count
FROM messages
WHERE sender_user_id = ? OR receiver_user_id = ?
GROUP BY conversation_id
ORDER BY last_message_time DESC;

-- Query: Get messages in a conversation
-- Used in: Message thread display
-- Topics: WHERE, ORDER BY
SELECT message_id, sender_user_id, sender_seller_id, 
       receiver_user_id, receiver_seller_id,
       message_text, is_read, sent_at
FROM messages
WHERE conversation_id = ? -- Parameter: conversation_id
ORDER BY sent_at ASC;

-- ====================================================
-- SECTION 11: WISHLIST CHECK QUERY
-- SQL Topics: EXISTS
-- ====================================================

-- Query: Check if book is in user's wishlist
-- Used in: book_detail.php, wishlist toggle
-- Topics: EXISTS, Subquery
SELECT EXISTS(
    SELECT 1
    FROM wishlist
    WHERE user_id = ? -- Parameter: user_id
      AND book_id = ? -- Parameter: book_id
) AS in_wishlist;

-- ====================================================
-- SECTION 12: ORDER DETAIL QUERIES
-- SQL Topics: Complex JOIN with full details
-- ====================================================

-- Query: Get complete order details
-- Used in: order_detail.php, user_order_detail.php
-- Topics: Multiple JOINs, All related information
SELECT o.*,
       b.title, b.cover_image, b.condition,
       s.seller_id, s.username AS seller_name, s.full_name AS seller_full_name, 
       s.email AS seller_email, s.phone AS seller_phone,
       u.username AS buyer_name, u.full_name AS buyer_full_name,
       u.email AS buyer_email, u.phone AS buyer_phone,
       GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors
FROM orders o
JOIN books b ON o.book_id = b.id
JOIN sellers s ON o.seller_id = s.seller_id
JOIN users u ON o.user_id = u.user_id
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
WHERE o.order_id = ? -- Parameter: order_id
GROUP BY o.order_id;

-- ====================================================
-- END OF QUERIES
-- All queries are documented with:
-- - Purpose/Use case
-- - File where used
-- - SQL topics covered
-- ====================================================
