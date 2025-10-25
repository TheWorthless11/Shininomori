-- ====================================================
-- SHININOMORI BOOKSTORE - STORED PROCEDURES
-- File: 02_stored_procedures.sql
-- Purpose: All stored procedures used in the project
-- Run this AFTER 01_insert_data.sql
-- ====================================================

USE oldbookstore;
DELIMITER $$

-- ====================================================
-- SECTION 1: SEARCH & BROWSE PROCEDURES
-- SQL Topics: Dynamic SQL, PREPARE/EXECUTE, String Manipulation
-- ====================================================

-- Procedure: search_books
-- Purpose: Advanced search with multiple filter options
-- Used in: advance_search.php
-- SQL Topics: Dynamic SQL, CONCAT, IF/ELSE, PREPARE, EXECUTE
DROP PROCEDURE IF EXISTS search_books$$
CREATE PROCEDURE search_books(
    IN p_author VARCHAR(200),
    IN p_title VARCHAR(300),
    IN p_isbn VARCHAR(30),
    IN p_keywords VARCHAR(300),
    IN p_publisher VARCHAR(200),
    IN p_min_price DECIMAL(10,2),
    IN p_max_price DECIMAL(10,2),
    IN p_product_type VARCHAR(50),
    IN p_condition VARCHAR(50),
    IN p_binding VARCHAR(50),
    IN p_language VARCHAR(50),
    IN p_seller_name VARCHAR(200),
    IN p_sort_by VARCHAR(20)
)
BEGIN
    SET @sql = 'SELECT b.id, b.title, b.price, b.condition, b.binding, b.language,
                       b.product_type, b.isbn, b.publisher, b.created_at, b.cover_image,
                       s.full_name AS seller_name, s.location,
                       GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ", ") AS authors
                FROM books b
                INNER JOIN sellers s ON b.seller_id = s.seller_id
                LEFT JOIN book_authors ba ON b.id = ba.book_id
                LEFT JOIN authors a ON ba.author_id = a.id
                WHERE b.status = "approved" ';
    
    IF p_author IS NOT NULL AND p_author != '' THEN
        SET @sql = CONCAT(@sql, ' AND LOWER(a.name) LIKE CONCAT("%", LOWER("', p_author, '"), "%")');
    END IF;
    
    IF p_title IS NOT NULL AND p_title != '' THEN
        SET @sql = CONCAT(@sql, ' AND LOWER(b.title) LIKE CONCAT("%", LOWER("', p_title, '"), "%")');
    END IF;
    
    IF p_isbn IS NOT NULL AND p_isbn != '' THEN
        SET @sql = CONCAT(@sql, ' AND b.isbn REGEXP "', p_isbn, '"');
    END IF;
    
    IF p_publisher IS NOT NULL AND p_publisher != '' THEN
        SET @sql = CONCAT(@sql, ' AND LOWER(b.publisher) LIKE CONCAT("%", LOWER("', p_publisher, '"), "%")');
    END IF;
    
    IF p_min_price IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND b.price >= ', p_min_price);
    END IF;
    
    IF p_max_price IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND b.price <= ', p_max_price);
    END IF;
    
    IF p_condition IS NOT NULL AND p_condition != '' THEN
        SET @sql = CONCAT(@sql, ' AND b.condition = "', p_condition, '"');
    END IF;
    
    IF p_binding IS NOT NULL AND p_binding != '' THEN
        SET @sql = CONCAT(@sql, ' AND b.binding = "', p_binding, '"');
    END IF;
    
    SET @sql = CONCAT(@sql, ' GROUP BY b.id');
    
    SET @sql = CONCAT(@sql, ' ORDER BY ');
    IF p_sort_by = 'price_asc' THEN
        SET @sql = CONCAT(@sql, 'b.price ASC');
    ELSEIF p_sort_by = 'price_desc' THEN
        SET @sql = CONCAT(@sql, 'b.price DESC');
    ELSE
        SET @sql = CONCAT(@sql, 'b.created_at DESC');
    END IF;
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

-- Procedure: browse_books
-- Purpose: Browse books with category, price filters and pagination
-- Used in: browse.php
-- SQL Topics: Dynamic SQL, Pagination with LIMIT/OFFSET, AVG, COUNT
DROP PROCEDURE IF EXISTS browse_books$$
CREATE PROCEDURE browse_books(
    IN p_category VARCHAR(50),
    IN p_min_price DECIMAL(10,2),
    IN p_max_price DECIMAL(10,2),
    IN p_keywords VARCHAR(300),
    IN p_sort_by VARCHAR(20),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SET @sql = 'SELECT b.id, b.title, b.price, b.condition, b.binding, b.cover_image,
                       s.full_name AS seller_name, s.location,
                       GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ", ") AS authors,
                       AVG(br.rating) AS avg_rating,
                       COUNT(DISTINCT br.rating_id) AS rating_count
                FROM books b
                JOIN sellers s ON b.seller_id = s.seller_id
                LEFT JOIN book_authors ba ON b.id = ba.book_id
                LEFT JOIN authors a ON ba.author_id = a.id
                LEFT JOIN book_ratings br ON b.id = br.book_id
                WHERE b.status = "approved" ';
    
    IF p_category IS NOT NULL AND p_category != '' THEN
        SET @sql = CONCAT(@sql, ' AND b.product_type = "', p_category, '"');
    END IF;
    
    IF p_min_price IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND b.price >= ', p_min_price);
    END IF;
    
    IF p_max_price IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND b.price <= ', p_max_price);
    END IF;
    
    IF p_keywords IS NOT NULL AND p_keywords != '' THEN
        SET @sql = CONCAT(@sql, ' AND (LOWER(b.title) LIKE CONCAT("%", LOWER("', p_keywords, '"), "%") ',
                                  'OR LOWER(a.name) LIKE CONCAT("%", LOWER("', p_keywords, '"), "%"))');
    END IF;
    
    SET @sql = CONCAT(@sql, ' GROUP BY b.id');
    
    SET @sql = CONCAT(@sql, ' ORDER BY ');
    IF p_sort_by = 'price_asc' THEN
        SET @sql = CONCAT(@sql, 'b.price ASC');
    ELSEIF p_sort_by = 'price_desc' THEN
        SET @sql = CONCAT(@sql, 'b.price DESC');
    ELSEIF p_sort_by = 'rating_desc' THEN
        SET @sql = CONCAT(@sql, 'avg_rating DESC');
    ELSE
        SET @sql = CONCAT(@sql, 'b.created_at DESC');
    END IF;
    
    IF p_limit IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' LIMIT ', p_limit);
        IF p_offset IS NOT NULL THEN
            SET @sql = CONCAT(@sql, ' OFFSET ', p_offset);
        END IF;
    END IF;
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

-- Procedure: count_browse_books
-- Purpose: Count total books matching browse filters (for pagination)
-- Used in: browse.php
-- SQL Topics: COUNT with filters
DROP PROCEDURE IF EXISTS count_browse_books$$
CREATE PROCEDURE count_browse_books(
    IN p_category VARCHAR(50),
    IN p_min_price DECIMAL(10,2),
    IN p_max_price DECIMAL(10,2),
    IN p_keywords VARCHAR(300)
)
BEGIN
    SET @sql = 'SELECT COUNT(DISTINCT b.id) as total
                FROM books b
                LEFT JOIN book_authors ba ON b.id = ba.book_id
                LEFT JOIN authors a ON ba.author_id = a.id
                WHERE b.status = "approved" ';
    
    IF p_category IS NOT NULL AND p_category != '' THEN
        SET @sql = CONCAT(@sql, ' AND b.product_type = "', p_category, '"');
    END IF;
    
    IF p_min_price IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND b.price >= ', p_min_price);
    END IF;
    
    IF p_max_price IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND b.price <= ', p_max_price);
    END IF;
    
    IF p_keywords IS NOT NULL AND p_keywords != '' THEN
        SET @sql = CONCAT(@sql, ' AND (LOWER(b.title) LIKE CONCAT("%", LOWER("', p_keywords, '"), "%") ',
                                  'OR LOWER(a.name) LIKE CONCAT("%", LOWER("', p_keywords, '"), "%"))');
    END IF;
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

-- ====================================================
-- SECTION 2: HOMEPAGE PROCEDURES
-- SQL Topics: ORDER BY RAND(), LIMIT, Complex JOINs
-- ====================================================

-- Procedure: get_random_quote
-- Purpose: Get a random inspirational quote for homepage
-- Used in: index.php
-- SQL Topics: ORDER BY RAND(), LIMIT
DROP PROCEDURE IF EXISTS get_random_quote$$
CREATE PROCEDURE get_random_quote()
BEGIN
    SELECT quote_text, author
    FROM quotes
    WHERE is_active = 1
    ORDER BY RAND()
    LIMIT 1;
END$$

-- Procedure: get_best_sellers
-- Purpose: Get most rated/viewed books (bestsellers)
-- Used in: index.php
-- SQL Topics: LEFT JOIN, COUNT, AVG, GROUP BY, ORDER BY
DROP PROCEDURE IF EXISTS get_best_sellers$$
CREATE PROCEDURE get_best_sellers(IN p_limit INT)
BEGIN
    SELECT b.id, b.title, b.price, b.cover_image, b.condition,
           COUNT(br.rating_id) AS rating_count,
           ROUND(AVG(br.rating), 1) AS avg_rating,
           s.full_name AS seller_name,
           GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors
    FROM books b
    LEFT JOIN book_ratings br ON b.id = br.book_id
    LEFT JOIN sellers s ON b.seller_id = s.seller_id
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    WHERE b.status = 'approved'
    GROUP BY b.id
    ORDER BY rating_count DESC, avg_rating DESC
    LIMIT p_limit;
END$$

-- Procedure: get_new_arrivals
-- Purpose: Get recently added books
-- Used in: index.php
-- SQL Topics: ORDER BY created_at, LIMIT
DROP PROCEDURE IF EXISTS get_new_arrivals$$
CREATE PROCEDURE get_new_arrivals(IN p_limit INT)
BEGIN
    SELECT b.id, b.title, b.price, b.cover_image, b.created_at, b.condition,
           s.full_name AS seller_name,
           GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors
    FROM books b
    JOIN sellers s ON b.seller_id = s.seller_id
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    WHERE b.status = 'approved'
    GROUP BY b.id
    ORDER BY b.created_at DESC
    LIMIT p_limit;
END$$

-- Procedure: get_featured_categories
-- Purpose: Get featured book categories for homepage
-- Used in: index.php
-- SQL Topics: GROUP BY, COUNT
DROP PROCEDURE IF EXISTS get_featured_categories$$
CREATE PROCEDURE get_featured_categories()
BEGIN
    SELECT g.id, g.name, g.description, COUNT(bg.book_id) as book_count
    FROM genres g
    LEFT JOIN book_genres bg ON g.id = bg.genre_id
    LEFT JOIN books b ON bg.book_id = b.id AND b.status = 'approved'
    GROUP BY g.id
    HAVING book_count > 0
    ORDER BY book_count DESC
    LIMIT 6;
END$$

-- ====================================================
-- SECTION 3: RECOMMENDATION PROCEDURES
-- SQL Topics: Subqueries, DISTINCT, Date functions
-- ====================================================

-- Procedure: get_user_recommendations
-- Purpose: Get personalized book recommendations based on viewing history
-- Used in: index.php, inc/activity_tracker.php
-- SQL Topics: JOIN, DISTINCT, DATE_SUB, Derived Table
DROP PROCEDURE IF EXISTS get_user_recommendations$$
CREATE PROCEDURE get_user_recommendations(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    SELECT b.id, b.title, b.price, b.condition, b.cover_image,
           s.full_name AS seller_name,
           GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors,
           'Based on your browsing history' AS recommendation_reason
    FROM books b
    INNER JOIN sellers s ON b.seller_id = s.seller_id
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    INNER JOIN (
        SELECT DISTINCT b2.id
        FROM user_book_views ubv
        INNER JOIN books b1 ON ubv.book_id = b1.id
        INNER JOIN books b2 ON (b2.product_type = b1.product_type OR b2.condition = b1.condition)
        WHERE ubv.user_id = p_user_id
          AND b2.id != ubv.book_id
          AND ubv.viewed_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    ) AS recommended_books ON b.id = recommended_books.id
    WHERE b.status = 'approved'
    GROUP BY b.id, b.title, b.price, b.condition, b.cover_image, s.full_name
    ORDER BY b.created_at DESC
    LIMIT p_limit;
END$$

-- Procedure: get_seller_recommendations
-- Purpose: Get book recommendations for sellers based on their search history
-- Used in: inc/activity_tracker.php
-- SQL Topics: Subquery, DISTINCT
DROP PROCEDURE IF EXISTS get_seller_recommendations$$
CREATE PROCEDURE get_seller_recommendations(
    IN p_seller_id INT,
    IN p_limit INT
)
BEGIN
    SELECT DISTINCT b.id, b.title, b.price, b.condition, b.cover_image,
           s.full_name AS seller_name,
           GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors,
           'Similar to your searches' AS recommendation_reason
    FROM books b
    INNER JOIN sellers s ON b.seller_id = s.seller_id
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    WHERE b.seller_id != p_seller_id
      AND b.status = 'approved'
      AND b.product_type IN (
          SELECT DISTINCT b2.product_type
          FROM user_book_views ubv
          INNER JOIN books b2 ON ubv.book_id = b2.id
          WHERE ubv.seller_id = p_seller_id
            AND ubv.viewed_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
      )
    GROUP BY b.id
    ORDER BY b.created_at DESC
    LIMIT p_limit;
END$$

-- Procedure: get_user_recently_viewed
-- Purpose: Get user's recently viewed books
-- Used in: index.php
-- SQL Topics: JOIN, ORDER BY, LIMIT
DROP PROCEDURE IF EXISTS get_user_recently_viewed$$
CREATE PROCEDURE get_user_recently_viewed(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    SELECT DISTINCT b.id, b.title, b.price, b.cover_image, b.condition,
           ubv.viewed_at,
           s.full_name AS seller_name,
           GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS authors
    FROM user_book_views ubv
    JOIN books b ON ubv.book_id = b.id
    JOIN sellers s ON b.seller_id = s.seller_id
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    WHERE ubv.user_id = p_user_id
      AND b.status = 'approved'
    GROUP BY b.id, ubv.viewed_at
    ORDER BY ubv.viewed_at DESC
    LIMIT p_limit;
END$$

-- Procedure: get_user_recent_searches
-- Purpose: Get user's recent search queries
-- Used in: index.php
-- SQL Topics: DISTINCT, ORDER BY, LIMIT
DROP PROCEDURE IF EXISTS get_user_recent_searches$$
CREATE PROCEDURE get_user_recent_searches(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    SELECT DISTINCT search_term, search_type, searched_at
    FROM user_search_history
    WHERE user_id = p_user_id
    ORDER BY searched_at DESC
    LIMIT p_limit;
END$$

-- ====================================================
-- SECTION 4: SELLER DASHBOARD PROCEDURES
-- SQL Topics: Aggregate functions, CASE statements
-- ====================================================

-- Procedure: get_seller_dashboard_stats
-- Purpose: Get seller's statistics for dashboard
-- Used in: seller_dashboard.php
-- SQL Topics: COUNT, SUM, CASE, Aggregate functions
DROP PROCEDURE IF EXISTS get_seller_dashboard_stats$$
CREATE PROCEDURE get_seller_dashboard_stats(IN p_seller_id INT)
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM books WHERE seller_id = p_seller_id) AS total_books,
        (SELECT COUNT(*) FROM books WHERE seller_id = p_seller_id AND status = 'approved') AS approved_books,
        (SELECT COUNT(*) FROM books WHERE seller_id = p_seller_id AND status = 'pending') AS pending_books,
        (SELECT COUNT(*) FROM orders WHERE seller_id = p_seller_id) AS total_orders,
        (SELECT COUNT(*) FROM orders WHERE seller_id = p_seller_id AND status = 'pending') AS pending_orders,
        (SELECT COUNT(*) FROM orders WHERE seller_id = p_seller_id AND status = 'completed') AS completed_orders,
        (SELECT IFNULL(SUM(total_amount), 0) FROM orders WHERE seller_id = p_seller_id AND status = 'completed') AS total_revenue;
END$$

-- Procedure: get_seller_home_stats
-- Purpose: Get seller statistics for homepage when logged in as seller
-- Used in: index.php
-- SQL Topics: Subqueries, IFNULL, SUM
DROP PROCEDURE IF EXISTS get_seller_home_stats$$
CREATE PROCEDURE get_seller_home_stats(IN p_seller_id INT)
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM books WHERE seller_id = p_seller_id AND status = 'approved') AS total_books,
        (SELECT COUNT(*) FROM orders WHERE seller_id = p_seller_id AND status = 'pending') AS pending_orders,
        (SELECT IFNULL(SUM(total_amount), 0) FROM orders 
         WHERE seller_id = p_seller_id 
         AND status = 'completed'
         AND MONTH(order_date) = MONTH(CURDATE())) AS this_month_revenue,
        (SELECT IFNULL(AVG(rating), 0) FROM seller_ratings WHERE seller_id = p_seller_id) AS avg_rating,
        (SELECT COUNT(*) FROM seller_ratings WHERE seller_id = p_seller_id) AS total_ratings;
END$$

-- Procedure: get_seller_tips
-- Purpose: Get helpful tips for sellers
-- Used in: index.php
-- SQL Topics: Simple SELECT with filter
DROP PROCEDURE IF EXISTS get_seller_tips$$
CREATE PROCEDURE get_seller_tips(IN p_limit INT)
BEGIN
    SELECT tip_id, title, content, icon
    FROM seller_tips
    WHERE is_active = 1
    ORDER BY RAND()
    LIMIT p_limit;
END$$

-- Procedure: get_top_sellers
-- Purpose: Get top performing sellers by revenue
-- Used in: sellers.php (if implemented), admin_dashboard.php
-- SQL Topics: INNER JOIN, ORDER BY with multiple columns, LIMIT, REPEAT loop
DROP PROCEDURE IF EXISTS get_top_sellers$$
CREATE PROCEDURE get_top_sellers(IN p_limit INT)
BEGIN
    DECLARE v_validated_limit INT DEFAULT 10;
    
    -- Validate and set limit
    SET v_validated_limit = p_limit;
    
    REPEAT
        IF v_validated_limit <= 0 THEN
            SET v_validated_limit = 10;
        END IF;
        
        IF v_validated_limit > 100 THEN
            SET v_validated_limit = 100;
        END IF;
    UNTIL v_validated_limit > 0 AND v_validated_limit <= 100
    END REPEAT;
    
    SELECT 
        s.seller_id,
        s.username as seller_name,
        s.location,
        ss.total_books_listed,
        ss.total_orders,
        ss.completed_orders,
        ss.total_revenue,
        ss.completed_revenue,
        IFNULL(ss.average_rating, 0) as avg_rating,
        ss.total_ratings
    FROM sellers s
    INNER JOIN seller_statistics ss ON s.seller_id = ss.seller_id
    WHERE ss.total_revenue > 0
    ORDER BY ss.total_revenue DESC, ss.completed_orders DESC
    LIMIT v_validated_limit;
END$$

-- ====================================================
-- SECTION 5: RATING PROCEDURES
-- SQL Topics: INSERT ON DUPLICATE KEY UPDATE, Transactions
-- ====================================================

-- Procedure: add_or_update_rating
-- Purpose: Add or update a book rating by user
-- Used in: rate_book.php
-- SQL Topics: INSERT ON DUPLICATE KEY UPDATE
DROP PROCEDURE IF EXISTS add_or_update_rating$$
CREATE PROCEDURE add_or_update_rating(
    IN p_user_id INT,
    IN p_book_id INT,
    IN p_rating DECIMAL(3,2)
)
BEGIN
    INSERT INTO book_ratings (user_id, book_id, rating)
    VALUES (p_user_id, p_book_id, p_rating)
    ON DUPLICATE KEY UPDATE 
        rating = p_rating,
        updated_at = CURRENT_TIMESTAMP;
END$$

-- Procedure: get_book_rating_details
-- Purpose: Get book rating statistics and user's rating
-- Used in: rate_book.php, get_book_rating.php
-- SQL Topics: Aggregate functions, CASE, LEFT JOIN
DROP PROCEDURE IF EXISTS get_book_rating_details$$
CREATE PROCEDURE get_book_rating_details(
    IN p_book_id INT,
    IN p_user_id INT
)
BEGIN
    SELECT 
        COUNT(*) AS total_ratings,
        IFNULL(ROUND(AVG(rating), 2), 0) AS avg_rating,
        SUM(CASE WHEN rating >= 4.5 THEN 1 ELSE 0 END) AS rating_5_star,
        SUM(CASE WHEN rating >= 3.5 AND rating < 4.5 THEN 1 ELSE 0 END) AS rating_4_star,
        SUM(CASE WHEN rating >= 2.5 AND rating < 3.5 THEN 1 ELSE 0 END) AS rating_3_star,
        SUM(CASE WHEN rating >= 1.5 AND rating < 2.5 THEN 1 ELSE 0 END) AS rating_2_star,
        SUM(CASE WHEN rating < 1.5 THEN 1 ELSE 0 END) AS rating_1_star,
        (SELECT rating FROM book_ratings WHERE book_id = p_book_id AND user_id = p_user_id) AS user_rating
    FROM book_ratings
    WHERE book_id = p_book_id;
END$$

-- ====================================================
-- SECTION 6: MESSAGING PROCEDURES
-- SQL Topics: String concatenation, Conditional logic
-- ====================================================

-- Procedure: send_message
-- Purpose: Send a message between user and seller
-- Used in: api/send_message.php
-- SQL Topics: INSERT, CONCAT for conversation_id
DROP PROCEDURE IF EXISTS send_message$$
CREATE PROCEDURE send_message(
    IN p_sender_user_id INT,
    IN p_sender_seller_id INT,
    IN p_receiver_user_id INT,
    IN p_receiver_seller_id INT,
    IN p_message_text TEXT,
    IN p_conversation_id VARCHAR(100)
)
BEGIN
    INSERT INTO messages (
        conversation_id,
        sender_user_id,
        sender_seller_id,
        receiver_user_id,
        receiver_seller_id,
        message_text,
        is_read
    ) VALUES (
        p_conversation_id,
        p_sender_user_id,
        p_sender_seller_id,
        p_receiver_user_id,
        p_receiver_seller_id,
        p_message_text,
        0
    );
END$$

-- Procedure: mark_messages_read
-- Purpose: Mark messages as read in a conversation
-- Used in: api/get_messages.php
-- SQL Topics: UPDATE with multiple conditions
DROP PROCEDURE IF EXISTS mark_messages_read$$
CREATE PROCEDURE mark_messages_read(
    IN p_conversation_id VARCHAR(100),
    IN p_user_id INT,
    IN p_seller_id INT
)
BEGIN
    UPDATE messages
    SET is_read = 1
    WHERE conversation_id = p_conversation_id
      AND is_read = 0
      AND (
          (receiver_user_id = p_user_id AND p_user_id IS NOT NULL) OR
          (receiver_seller_id = p_seller_id AND p_seller_id IS NOT NULL)
      );
END$$

-- Procedure: mark_notification_read
-- Purpose: Mark a notification as read
-- Used in: api/mark_notification_read.php
-- SQL Topics: UPDATE with simple condition
DROP PROCEDURE IF EXISTS mark_notification_read$$
CREATE PROCEDURE mark_notification_read(IN p_notification_id INT)
BEGIN
    UPDATE notifications
    SET is_read = 1
    WHERE notification_id = p_notification_id;
END$$

-- ====================================================
-- SECTION 7: UTILITY/DEMO PROCEDURES
-- SQL Topics: Cursors, Loops, UPDATE
-- ====================================================

-- Procedure: proc_give_discount
-- Purpose: Apply percentage discount to all books by a seller (demo)
-- Used in: sql_demo_queries.php (educational demo)
-- SQL Topics: UPDATE with calculation
DROP PROCEDURE IF EXISTS proc_give_discount$$
CREATE PROCEDURE proc_give_discount(
    IN p_seller INT,
    IN p_percent DECIMAL(5,2)
)
BEGIN
    UPDATE books 
    SET price = ROUND(price * (1 - p_percent/100), 2) 
    WHERE seller_id = p_seller AND status = 'approved';
END$$

-- Procedure: proc_count_books_by_author
-- Purpose: Count books for each author using cursor (demo)
-- Used in: Educational purposes only
-- SQL Topics: CURSOR, LOOP, HANDLER, FETCH
DROP PROCEDURE IF EXISTS proc_count_books_by_author$$
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
        SELECT a_name AS author, COUNT(ba.book_id) AS book_count 
        FROM book_authors ba 
        WHERE ba.author_id = a_id 
        GROUP BY a_name;
    END LOOP;
    CLOSE cur;
END$$

-- Procedure: update_rating_statistics
-- Purpose: Update denormalized rating statistics table (uses cursor and loops)
-- Used in: Triggered automatically by rating triggers
-- SQL Topics: CURSOR, WHILE LOOP, CASE statement, INSERT ON DUPLICATE KEY UPDATE
DROP PROCEDURE IF EXISTS update_rating_statistics$$
CREATE PROCEDURE update_rating_statistics(IN p_book_id INT)
BEGIN
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_sum INT DEFAULT 0;
    DECLARE v_avg DECIMAL(3,2) DEFAULT 0.00;
    DECLARE v_count_1 INT DEFAULT 0;
    DECLARE v_count_2 INT DEFAULT 0;
    DECLARE v_count_3 INT DEFAULT 0;
    DECLARE v_count_4 INT DEFAULT 0;
    DECLARE v_count_5 INT DEFAULT 0;
    DECLARE v_rating INT;
    DECLARE v_done INT DEFAULT 0;
    
    -- Cursor to iterate through all ratings for this book
    DECLARE rating_cursor CURSOR FOR
        SELECT rating FROM book_ratings WHERE book_id = p_book_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    
    -- Open cursor and loop through ratings
    OPEN rating_cursor;
    
    rating_loop: WHILE v_done = 0 DO
        FETCH rating_cursor INTO v_rating;
        
        IF v_done = 1 THEN
            LEAVE rating_loop;
        END IF;
        
        -- Increment counters
        SET v_total = v_total + 1;
        SET v_sum = v_sum + v_rating;
        
        -- Count by rating value using CASE
        CASE v_rating
            WHEN 1 THEN SET v_count_1 = v_count_1 + 1;
            WHEN 2 THEN SET v_count_2 = v_count_2 + 1;
            WHEN 3 THEN SET v_count_3 = v_count_3 + 1;
            WHEN 4 THEN SET v_count_4 = v_count_4 + 1;
            WHEN 5 THEN SET v_count_5 = v_count_5 + 1;
        END CASE;
    END WHILE rating_loop;
    
    CLOSE rating_cursor;
    
    -- Calculate average
    IF v_total > 0 THEN
        SET v_avg = v_sum / v_total;
    END IF;
    
    -- Insert or update statistics
    INSERT INTO book_rating_stats 
        (book_id, total_ratings, sum_ratings, avg_rating, 
         rating_1_count, rating_2_count, rating_3_count, 
         rating_4_count, rating_5_count)
    VALUES 
        (p_book_id, v_total, v_sum, v_avg,
         v_count_1, v_count_2, v_count_3,
         v_count_4, v_count_5)
    ON DUPLICATE KEY UPDATE
        total_ratings = v_total,
        sum_ratings = v_sum,
        avg_rating = v_avg,
        rating_1_count = v_count_1,
        rating_2_count = v_count_2,
        rating_3_count = v_count_3,
        rating_4_count = v_count_4,
        rating_5_count = v_count_5;
END$$

-- Procedure: get_top_rated_books
-- Purpose: Get list of top-rated books with minimum rating count
-- Used in: index.php (Top Rated section)
-- SQL Topics: INNER JOIN, GROUP_CONCAT, ORDER BY, LIMIT, REPEAT loop
DROP PROCEDURE IF EXISTS get_top_rated_books$$
CREATE PROCEDURE get_top_rated_books(IN p_limit INT)
BEGIN
    DECLARE v_min_ratings INT DEFAULT 3;
    
    -- Using REPEAT loop to validate limit
    REPEAT
        SET p_limit = p_limit - 1;
    UNTIL p_limit <= 0 OR p_limit > 100
    END REPEAT;
    
    SET p_limit = p_limit + 1;
    IF p_limit <= 0 THEN
        SET p_limit = 10;
    END IF;
    
    SELECT 
        b.id,
        b.title,
        b.price,
        b.cover_image,
        s.username as seller_name,
        brs.avg_rating,
        brs.total_ratings,
        GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') as authors
    FROM books b
    INNER JOIN book_rating_stats brs ON b.id = brs.book_id
    LEFT JOIN sellers s ON b.seller_id = s.seller_id
    LEFT JOIN book_authors ba ON b.id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.id
    WHERE brs.total_ratings >= v_min_ratings
    GROUP BY b.id, b.title, b.price, b.cover_image, s.username, brs.avg_rating, brs.total_ratings
    ORDER BY brs.avg_rating DESC, brs.total_ratings DESC
    LIMIT p_limit;
END$$

-- Procedure: initialize_all_rating_stats
-- Purpose: Bulk initialize/recalculate rating statistics for all books
-- Used in: admin_dashboard.php (maintenance), run once after migration
-- SQL Topics: CURSOR, LOOP, Bulk processing
DROP PROCEDURE IF EXISTS initialize_all_rating_stats$$
CREATE PROCEDURE initialize_all_rating_stats()
BEGIN
    DECLARE v_book_id INT;
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_processed INT DEFAULT 0;
    
    DECLARE book_cursor CURSOR FOR
        SELECT DISTINCT id FROM books;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    
    OPEN book_cursor;
    
    book_loop: LOOP
        FETCH book_cursor INTO v_book_id;
        
        IF v_done = 1 THEN
            LEAVE book_loop;
        END IF;
        
        -- Update statistics for this book
        CALL update_rating_statistics(v_book_id);
        SET v_processed = v_processed + 1;
    END LOOP book_loop;
    
    CLOSE book_cursor;
    
    SELECT CONCAT('Initialized rating statistics for ', v_processed, ' books') as result;
END$$

-- Procedure: update_seller_statistics
-- Purpose: Update seller statistics (books, orders, revenue) using cursor
-- Used in: Triggered automatically or called manually
-- SQL Topics: CURSOR, WHILE LOOP, CASE statement, INSERT ON DUPLICATE KEY UPDATE
DROP PROCEDURE IF EXISTS update_seller_statistics$$
CREATE PROCEDURE update_seller_statistics(IN p_seller_id INT)
BEGIN
    DECLARE v_total_books INT DEFAULT 0;
    DECLARE v_total_orders INT DEFAULT 0;
    DECLARE v_pending_orders INT DEFAULT 0;
    DECLARE v_completed_orders INT DEFAULT 0;
    DECLARE v_cancelled_orders INT DEFAULT 0;
    DECLARE v_total_revenue DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_pending_revenue DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_completed_revenue DECIMAL(10,2) DEFAULT 0.00;
    
    DECLARE v_order_status VARCHAR(20);
    DECLARE v_order_amount DECIMAL(10,2);
    DECLARE v_done INT DEFAULT 0;
    
    -- Cursor to iterate through all orders for this seller
    DECLARE order_cursor CURSOR FOR
        SELECT status, total_amount
        FROM orders
        WHERE seller_id = p_seller_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    
    -- Count total books listed by seller
    SELECT COUNT(*) INTO v_total_books
    FROM books
    WHERE seller_id = p_seller_id;
    
    -- Open cursor and loop through orders
    OPEN order_cursor;
    
    order_loop: WHILE v_done = 0 DO
        FETCH order_cursor INTO v_order_status, v_order_amount;
        
        IF v_done = 1 THEN
            LEAVE order_loop;
        END IF;
        
        -- Increment counters
        SET v_total_orders = v_total_orders + 1;
        SET v_total_revenue = v_total_revenue + v_order_amount;
        
        -- Count by order status using CASE
        CASE v_order_status
            WHEN 'pending' THEN 
                SET v_pending_orders = v_pending_orders + 1;
                SET v_pending_revenue = v_pending_revenue + v_order_amount;
            WHEN 'completed' THEN 
                SET v_completed_orders = v_completed_orders + 1;
                SET v_completed_revenue = v_completed_revenue + v_order_amount;
            WHEN 'cancelled' THEN 
                SET v_cancelled_orders = v_cancelled_orders + 1;
            WHEN 'refunded' THEN 
                SET v_cancelled_orders = v_cancelled_orders + 1;
            ELSE 
                -- Default to pending for unknown statuses
                SET v_pending_orders = v_pending_orders + 1;
                SET v_pending_revenue = v_pending_revenue + v_order_amount;
        END CASE;
    END WHILE order_loop;
    
    CLOSE order_cursor;
    
    -- Insert or update statistics
    INSERT INTO seller_statistics 
        (seller_id, total_books_listed, total_orders, pending_orders, 
         completed_orders, cancelled_orders, total_revenue, 
         pending_revenue, completed_revenue)
    VALUES 
        (p_seller_id, v_total_books, v_total_orders, v_pending_orders,
         v_completed_orders, v_cancelled_orders, v_total_revenue,
         v_pending_revenue, v_completed_revenue)
    ON DUPLICATE KEY UPDATE
        total_books_listed = v_total_books,
        total_orders = v_total_orders,
        pending_orders = v_pending_orders,
        completed_orders = v_completed_orders,
        cancelled_orders = v_cancelled_orders,
        total_revenue = v_total_revenue,
        pending_revenue = v_pending_revenue,
        completed_revenue = v_completed_revenue;
END$$

-- Procedure: initialize_all_seller_stats
-- Purpose: Bulk initialize/recalculate statistics for all sellers
-- Used in: admin_dashboard.php (maintenance), run once after migration
-- SQL Topics: CURSOR, LOOP, Bulk processing
DROP PROCEDURE IF EXISTS initialize_all_seller_stats$$
CREATE PROCEDURE initialize_all_seller_stats()
BEGIN
    DECLARE v_seller_id INT;
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_processed INT DEFAULT 0;
    
    DECLARE seller_cursor CURSOR FOR
        SELECT DISTINCT seller_id FROM sellers;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    
    OPEN seller_cursor;
    
    seller_loop: LOOP
        FETCH seller_cursor INTO v_seller_id;
        
        IF v_done = 1 THEN
            LEAVE seller_loop;
        END IF;
        
        -- Update statistics for this seller
        CALL update_seller_statistics(v_seller_id);
        SET v_processed = v_processed + 1;
    END LOOP seller_loop;
    
    CLOSE seller_cursor;
    
    SELECT CONCAT('Initialized statistics for ', v_processed, ' sellers') as result;
END$$

DELIMITER ;

-- ====================================================
-- END OF STORED PROCEDURES
-- Next: Run 03_stored_functions.sql
-- ====================================================
