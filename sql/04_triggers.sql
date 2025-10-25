-- ====================================================
-- SHININOMORI BOOKSTORE - TRIGGERS
-- File: 04_triggers.sql
-- Purpose: All triggers used in the project
-- Run this AFTER 03_stored_functions.sql
-- ====================================================

USE oldbookstore;
DELIMITER $$

-- ====================================================
-- SECTION 1: BOOK VALIDATION TRIGGERS
-- SQL Topics: BEFORE INSERT, SIGNAL (error handling)
-- ====================================================

-- Trigger: trg_books_price_check
-- Purpose: Validate book price is non-negative before insert
-- Fires on: BEFORE INSERT on books table
-- SQL Topics: BEFORE INSERT TRIGGER, SIGNAL, Error handling
DROP TRIGGER IF EXISTS trg_books_price_check$$
CREATE TRIGGER trg_books_price_check
BEFORE INSERT ON books
FOR EACH ROW
BEGIN
    IF NEW.price < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Book price must be non-negative';
    END IF;
END$$

-- Trigger: trg_books_after_insert
-- Purpose: Log or perform actions after new book is inserted
-- Fires on: AFTER INSERT on books table
-- SQL Topics: AFTER INSERT TRIGGER
DROP TRIGGER IF EXISTS trg_books_after_insert$$
CREATE TRIGGER trg_books_after_insert
AFTER INSERT ON books
FOR EACH ROW
BEGIN
    -- Set session variable to track last inserted book
    SET @last_inserted_book_id = NEW.id;
    SET @last_inserted_book_seller = NEW.seller_id;
END$$

-- ====================================================
-- SECTION 2: BOOK RATING TRIGGERS
-- SQL Topics: AFTER INSERT/UPDATE/DELETE, REPLACE INTO
-- ====================================================

-- Trigger: after_rating_insert
-- Purpose: Update rating statistics when new rating is added
-- Fires on: AFTER INSERT on book_ratings table
-- SQL Topics: AFTER INSERT TRIGGER, CALL stored procedure
DROP TRIGGER IF EXISTS after_rating_insert$$
CREATE TRIGGER after_rating_insert
AFTER INSERT ON book_ratings
FOR EACH ROW
BEGIN
    -- Update denormalized rating statistics table
    CALL update_rating_statistics(NEW.book_id);
    
    -- Track last rated book
    SET @last_rated_book = NEW.book_id;
    SET @last_rating_by_user = NEW.user_id;
END$$

-- Trigger: after_rating_update
-- Purpose: Update rating statistics when rating is modified
-- Fires on: AFTER UPDATE on book_ratings table
-- SQL Topics: AFTER UPDATE TRIGGER
DROP TRIGGER IF EXISTS after_rating_update$$
CREATE TRIGGER after_rating_update
AFTER UPDATE ON book_ratings
FOR EACH ROW
BEGIN
    -- Update denormalized rating statistics table
    CALL update_rating_statistics(NEW.book_id);
    
    -- Track rating update
    SET @last_updated_rating = NEW.rating_id;
END$$

-- Trigger: after_rating_delete
-- Purpose: Update rating statistics when rating is deleted
-- Fires on: AFTER DELETE on book_ratings table
-- SQL Topics: AFTER DELETE TRIGGER
DROP TRIGGER IF EXISTS after_rating_delete$$
CREATE TRIGGER after_rating_delete
AFTER DELETE ON book_ratings
FOR EACH ROW
BEGIN
    -- Update denormalized rating statistics table
    CALL update_rating_statistics(OLD.book_id);
    
    -- Track deleted rating
    SET @last_deleted_rating = OLD.rating_id;
    SET @deleted_rating_book = OLD.book_id;
END$$

-- ====================================================
-- SECTION 3: ORDER TRACKING TRIGGERS
-- SQL Topics: AFTER INSERT/UPDATE/DELETE, UPDATE with subquery
-- ====================================================

-- Trigger: after_order_insert
-- Purpose: Update seller statistics when new order is placed
-- Fires on: AFTER INSERT on orders table
-- SQL Topics: AFTER INSERT TRIGGER, Session variables
DROP TRIGGER IF EXISTS after_order_insert$$
CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    -- Track new order
    SET @last_order_id = NEW.order_id;
    SET @last_order_seller = NEW.seller_id;
    SET @last_order_amount = NEW.total_amount;
END$$

-- Trigger: after_order_update
-- Purpose: Update seller statistics when order status changes
-- Fires on: AFTER UPDATE on orders table
-- SQL Topics: AFTER UPDATE TRIGGER, IF condition
DROP TRIGGER IF EXISTS after_order_update$$
CREATE TRIGGER after_order_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Track status change
    IF OLD.status != NEW.status THEN
        SET @order_status_changed = NEW.order_id;
        SET @old_status = OLD.status;
        SET @new_status = NEW.status;
    END IF;
END$$

-- Trigger: after_order_delete
-- Purpose: Update seller statistics when order is deleted
-- Fires on: AFTER DELETE on orders table
-- SQL Topics: AFTER DELETE TRIGGER
DROP TRIGGER IF EXISTS after_order_delete$$
CREATE TRIGGER after_order_delete
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    -- Track deleted order
    SET @deleted_order_id = OLD.order_id;
    SET @deleted_order_seller = OLD.seller_id;
END$$

-- ====================================================
-- SECTION 4: SELLER BOOK TRACKING TRIGGERS
-- SQL Topics: AFTER INSERT/DELETE on books
-- ====================================================

-- Trigger: after_book_insert
-- Purpose: Update seller book count when new book is added
-- Fires on: AFTER INSERT on books table
-- SQL Topics: AFTER INSERT TRIGGER
DROP TRIGGER IF EXISTS after_book_insert$$
CREATE TRIGGER after_book_insert
AFTER INSERT ON books
FOR EACH ROW
BEGIN
    -- Track book addition for seller
    SET @seller_new_book = NEW.seller_id;
    SET @new_book_status = NEW.status;
END$$

-- Trigger: after_book_delete
-- Purpose: Update seller book count when book is deleted
-- Fires on: AFTER DELETE on books table
-- SQL Topics: AFTER DELETE TRIGGER
DROP TRIGGER IF EXISTS after_book_delete$$
CREATE TRIGGER after_book_delete
AFTER DELETE ON books
FOR EACH ROW
BEGIN
    -- Track book deletion for seller
    SET @seller_deleted_book = OLD.seller_id;
    SET @deleted_book_id = OLD.id;
END$$

-- ====================================================
-- SECTION 5: NOTIFICATION TRIGGERS
-- SQL Topics: AFTER INSERT/UPDATE, INSERT notification
-- ====================================================

-- Trigger: notify_seller_on_order
-- Purpose: Create notification for seller when new order is placed
-- Fires on: AFTER INSERT on orders table
-- SQL Topics: AFTER INSERT TRIGGER, INSERT INTO another table
DROP TRIGGER IF EXISTS notify_seller_on_order$$
CREATE TRIGGER notify_seller_on_order
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE v_book_title VARCHAR(300);
    DECLARE v_user_name VARCHAR(100);
    
    -- Get book title
    SELECT title INTO v_book_title FROM books WHERE id = NEW.book_id LIMIT 1;
    
    -- Get user name
    SELECT full_name INTO v_user_name FROM users WHERE user_id = NEW.user_id LIMIT 1;
    
    -- Create notification for seller
    INSERT INTO notifications (
        seller_id,
        title,
        message,
        type,
        related_id
    ) VALUES (
        NEW.seller_id,
        'New Order Received',
        CONCAT('You have a new order for "', v_book_title, '" from ', IFNULL(v_user_name, 'a customer')),
        'order',
        NEW.order_id
    );
END$$

-- Trigger: notify_user_on_status_change
-- Purpose: Notify user when their order status changes
-- Fires on: AFTER UPDATE on orders table
-- SQL Topics: AFTER UPDATE TRIGGER, IF condition, INSERT
DROP TRIGGER IF EXISTS notify_user_on_status_change$$
CREATE TRIGGER notify_user_on_status_change
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    DECLARE v_book_title VARCHAR(300);
    DECLARE v_message TEXT;
    
    -- Only notify if status changed
    IF OLD.status != NEW.status THEN
        -- Get book title
        SELECT title INTO v_book_title FROM books WHERE id = NEW.book_id LIMIT 1;
        
        -- Create appropriate message based on new status
        CASE NEW.status
            WHEN 'confirmed' THEN
                SET v_message = CONCAT('Your order for "', v_book_title, '" has been confirmed by the seller');
            WHEN 'completed' THEN
                SET v_message = CONCAT('Your order for "', v_book_title, '" has been completed');
            WHEN 'cancelled' THEN
                SET v_message = CONCAT('Your order for "', v_book_title, '" has been cancelled');
            ELSE
                SET v_message = CONCAT('Order status updated for "', v_book_title, '"');
        END CASE;
        
        -- Create notification for user
        INSERT INTO notifications (
            user_id,
            title,
            message,
            type,
            related_id
        ) VALUES (
            NEW.user_id,
            'Order Status Update',
            v_message,
            'order',
            NEW.order_id
        );
    END IF;
END$$

-- Trigger: notify_admin_new_user
-- Purpose: Notify admin when new user registers
-- Fires on: AFTER INSERT on users table
-- SQL Topics: AFTER INSERT TRIGGER, INSERT notification
DROP TRIGGER IF EXISTS notify_admin_new_user$$
CREATE TRIGGER notify_admin_new_user
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    -- Create notification for admin (user_id = 1 assumed as admin)
    INSERT INTO notifications (
        user_id,
        title,
        message,
        type
    ) VALUES (
        1,
        'New User Registration',
        CONCAT('New user registered: ', NEW.username, ' (', NEW.email, ')'),
        'admin'
    );
END$$

-- Trigger: notify_admin_new_seller
-- Purpose: Notify admin when new seller registers
-- Fires on: AFTER INSERT on sellers table
-- SQL Topics: AFTER INSERT TRIGGER
DROP TRIGGER IF EXISTS notify_admin_new_seller$$
CREATE TRIGGER notify_admin_new_seller
AFTER INSERT ON sellers
FOR EACH ROW
BEGIN
    -- Find admin user and notify (admin email = mahhiamim@gmail.com)
    INSERT INTO notifications (
        user_id,
        title,
        message,
        type
    )
    SELECT 
        user_id,
        'New Seller Registration',
        CONCAT('New seller registered: ', NEW.username, ' (', NEW.email, ')'),
        'admin'
    FROM users
    WHERE email = 'mahhiamim@gmail.com'
    LIMIT 1;
END$$

-- ====================================================
-- SECTION 6: USER ACTIVITY TRACKING TRIGGERS
-- SQL Topics: AFTER INSERT
-- ====================================================

-- Trigger: trg_log_book_view
-- Purpose: Set session variable after book view is logged
-- Fires on: AFTER INSERT on user_book_views table
-- SQL Topics: AFTER INSERT TRIGGER, Session variables
DROP TRIGGER IF EXISTS trg_log_book_view$$
CREATE TRIGGER trg_log_book_view
AFTER INSERT ON user_book_views
FOR EACH ROW
BEGIN
    SET @last_viewed_book = NEW.book_id;
    SET @last_viewed_at = NEW.viewed_at;
    SET @viewer_user_id = NEW.user_id;
    SET @viewer_seller_id = NEW.seller_id;
END$$

DELIMITER ;

-- ====================================================
-- END OF TRIGGERS
-- Next: Run 05_queries.sql
-- ====================================================
