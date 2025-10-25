-- ====================================================
-- SHININOMORI BOOKSTORE - STORED FUNCTIONS
-- File: 03_stored_functions.sql
-- Purpose: All stored functions used in the project
-- Run this AFTER 02_stored_procedures.sql
-- ====================================================

USE oldbookstore;
DELIMITER $$

-- ====================================================
-- SECTION 1: BOOK RATING FUNCTIONS
-- SQL Topics: FUNCTION, RETURNS, DETERMINISTIC, AVG, IFNULL
-- ====================================================

-- Function: calculate_book_avg_rating
-- Purpose: Calculate average rating for a book
-- Used in: Advanced rating system
-- SQL Topics: FUNCTION, AVG, IFNULL, DECIMAL
DROP FUNCTION IF EXISTS calculate_book_avg_rating$$
CREATE FUNCTION calculate_book_avg_rating(p_book_id INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(3,2);
    SELECT IFNULL(ROUND(AVG(rating), 2), 0.00)
    INTO v_avg
    FROM book_ratings
    WHERE book_id = p_book_id;
    RETURN v_avg;
END$$

-- Function: get_rating_stars
-- Purpose: Convert numeric rating to star display string
-- Used in: Display purposes
-- SQL Topics: FUNCTION, CASE, String manipulation
DROP FUNCTION IF EXISTS get_rating_stars$$
CREATE FUNCTION get_rating_stars(p_rating DECIMAL(3,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE stars VARCHAR(20);
    
    CASE
        WHEN p_rating >= 4.5 THEN SET stars = '★★★★★';
        WHEN p_rating >= 3.5 THEN SET stars = '★★★★☆';
        WHEN p_rating >= 2.5 THEN SET stars = '★★★☆☆';
        WHEN p_rating >= 1.5 THEN SET stars = '★★☆☆☆';
        WHEN p_rating >= 0.5 THEN SET stars = '★☆☆☆☆';
        ELSE SET stars = '☆☆☆☆☆';
    END CASE;
    
    RETURN stars;
END$$

-- ====================================================
-- SECTION 2: SELLER STATISTICS FUNCTIONS
-- SQL Topics: SUM, COUNT with conditions
-- ====================================================

-- Function: fn_avg_price_by_seller
-- Purpose: Calculate average book price for a seller
-- Used in: sql_demo_queries.php (educational demo)
-- SQL Topics: FUNCTION, AVG, IFNULL
DROP FUNCTION IF EXISTS fn_avg_price_by_seller$$
CREATE FUNCTION fn_avg_price_by_seller(p_seller INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(10,2);
    SELECT IFNULL(ROUND(AVG(price), 2), 0.00) 
    INTO v_avg 
    FROM books 
    WHERE seller_id = p_seller AND status = 'approved';
    RETURN v_avg;
END$$

-- Function: fn_seller_total_revenue
-- Purpose: Get seller's total completed revenue
-- Used in: Educational purposes
-- SQL Topics: FUNCTION, SUM, Subquery
DROP FUNCTION IF EXISTS fn_seller_total_revenue$$
CREATE FUNCTION fn_seller_total_revenue(p_seller INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_revenue DECIMAL(10,2);
    SELECT IFNULL(SUM(total_amount), 0.00) 
    INTO v_revenue 
    FROM orders 
    WHERE seller_id = p_seller AND status = 'completed';
    RETURN v_revenue;
END$$

-- Function: calculate_seller_revenue
-- Purpose: Calculate seller revenue by status
-- Used in: Seller revenue tracking system
-- SQL Topics: FUNCTION, SUM with WHERE condition
DROP FUNCTION IF EXISTS calculate_seller_revenue$$
CREATE FUNCTION calculate_seller_revenue(
    p_seller_id INT,
    p_status VARCHAR(20)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_revenue DECIMAL(10,2);
    
    IF p_status = 'all' THEN
        SELECT IFNULL(SUM(total_amount), 0.00)
        INTO v_revenue
        FROM orders
        WHERE seller_id = p_seller_id;
    ELSE
        SELECT IFNULL(SUM(total_amount), 0.00)
        INTO v_revenue
        FROM orders
        WHERE seller_id = p_seller_id AND status = p_status;
    END IF;
    
    RETURN v_revenue;
END$$

-- Function: count_seller_orders
-- Purpose: Count seller orders by status
-- Used in: Seller statistics
-- SQL Topics: FUNCTION, COUNT with condition
DROP FUNCTION IF EXISTS count_seller_orders$$
CREATE FUNCTION count_seller_orders(
    p_seller_id INT,
    p_status VARCHAR(20)
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    
    IF p_status = 'all' THEN
        SELECT COUNT(*)
        INTO v_count
        FROM orders
        WHERE seller_id = p_seller_id;
    ELSE
        SELECT COUNT(*)
        INTO v_count
        FROM orders
        WHERE seller_id = p_seller_id AND status = p_status;
    END IF;
    
    RETURN v_count;
END$$

-- Function: calculate_commission
-- Purpose: Calculate platform commission on revenue
-- Used in: Revenue calculations
-- SQL Topics: FUNCTION, Simple calculation
DROP FUNCTION IF EXISTS calculate_commission$$
CREATE FUNCTION calculate_commission(
    p_revenue DECIMAL(10,2),
    p_commission_rate DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN ROUND(p_revenue * (p_commission_rate / 100), 2);
END$$

-- ====================================================
-- SECTION 3: SELLER RATING FUNCTIONS
-- SQL Topics: AVG, COUNT, EXISTS
-- ====================================================

-- Function: get_seller_average_rating
-- Purpose: Get seller's average rating
-- Used in: seller_profile.php, seller ratings system
-- SQL Topics: FUNCTION, AVG, IFNULL
DROP FUNCTION IF EXISTS get_seller_average_rating$$
CREATE FUNCTION get_seller_average_rating(p_seller_id INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(3,2);
    SELECT IFNULL(ROUND(AVG(rating), 2), 0.00)
    INTO v_avg
    FROM seller_ratings
    WHERE seller_id = p_seller_id;
    RETURN v_avg;
END$$

-- Function: get_seller_rating_count
-- Purpose: Get total number of ratings for a seller
-- Used in: seller_profile.php
-- SQL Topics: FUNCTION, COUNT
DROP FUNCTION IF EXISTS get_seller_rating_count$$
CREATE FUNCTION get_seller_rating_count(p_seller_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*)
    INTO v_count
    FROM seller_ratings
    WHERE seller_id = p_seller_id;
    RETURN v_count;
END$$

-- Function: can_user_rate_seller
-- Purpose: Check if user can rate a seller (must have completed purchase)
-- Used in: seller_profile.php
-- SQL Topics: FUNCTION, EXISTS, Boolean return
DROP FUNCTION IF EXISTS can_user_rate_seller$$
CREATE FUNCTION can_user_rate_seller(
    p_user_id INT,
    p_seller_id INT
)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE can_rate BOOLEAN;
    
    SELECT EXISTS(
        SELECT 1
        FROM orders
        WHERE user_id = p_user_id
          AND seller_id = p_seller_id
          AND status = 'completed'
    ) INTO can_rate;
    
    RETURN can_rate;
END$$

-- ====================================================
-- SECTION 4: MESSAGING FUNCTIONS
-- SQL Topics: String functions, CONCAT, IF
-- ====================================================

-- Function: generate_conversation_id
-- Purpose: Generate unique conversation ID between user and seller
-- Used in: Messaging system
-- SQL Topics: FUNCTION, CONCAT, IF, LEAST, GREATEST
DROP FUNCTION IF EXISTS generate_conversation_id$$
CREATE FUNCTION generate_conversation_id(
    p_user_id INT,
    p_seller_id INT
)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    RETURN CONCAT('user_', p_user_id, '_seller_', p_seller_id);
END$$

-- Function: count_unread_notifications
-- Purpose: Count unread notifications for user or seller
-- Used in: Notification system
-- SQL Topics: FUNCTION, COUNT with condition
DROP FUNCTION IF EXISTS count_unread_notifications$$
CREATE FUNCTION count_unread_notifications(
    p_user_id INT,
    p_seller_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    
    IF p_user_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_count
        FROM notifications
        WHERE user_id = p_user_id AND is_read = 0;
    ELSEIF p_seller_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_count
        FROM notifications
        WHERE seller_id = p_seller_id AND is_read = 0;
    ELSE
        SET v_count = 0;
    END IF;
    
    RETURN v_count;
END$$

-- Function: count_unread_messages
-- Purpose: Count unread messages for user or seller
-- Used in: Messaging system
-- SQL Topics: FUNCTION, COUNT with OR conditions
DROP FUNCTION IF EXISTS count_unread_messages$$
CREATE FUNCTION count_unread_messages(
    p_user_id INT,
    p_seller_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    
    SELECT COUNT(*)
    INTO v_count
    FROM messages
    WHERE is_read = 0
      AND (
          (receiver_user_id = p_user_id AND p_user_id IS NOT NULL) OR
          (receiver_seller_id = p_seller_id AND p_seller_id IS NOT NULL)
      );
    
    RETURN v_count;
END$$

-- Function: get_latest_message_text
-- Purpose: Get the latest message text in a conversation
-- Used in: Conversation list display
-- SQL Topics: FUNCTION, Subquery, LIMIT
DROP FUNCTION IF EXISTS get_latest_message_text$$
CREATE FUNCTION get_latest_message_text(p_conversation_id VARCHAR(100))
RETURNS TEXT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_message TEXT;
    
    SELECT message_text
    INTO v_message
    FROM messages
    WHERE conversation_id = p_conversation_id
    ORDER BY sent_at DESC
    LIMIT 1;
    
    RETURN v_message;
END$$

DELIMITER ;

-- ====================================================
-- END OF STORED FUNCTIONS
-- Next: Run 04_triggers.sql
-- ====================================================
