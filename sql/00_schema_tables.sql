-- ====================================================
-- SHININOMORI BOOKSTORE - DATABASE SCHEMA
-- File: 00_schema_tables.sql
-- Purpose: All CREATE TABLE and ALTER TABLE statements
-- Run this FIRST to set up your database structure
-- ====================================================

-- Create database
CREATE DATABASE IF NOT EXISTS oldbookstore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE oldbookstore;

-- ====================================================
-- SECTION 1: CORE USER TABLES
-- Purpose: Manage user accounts and seller accounts
-- ====================================================

-- Table: users (Buyers/General Users)
-- Purpose: Store buyer/customer account information
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) DEFAULT NULL,
    phone VARCHAR(20) DEFAULT NULL,
    address TEXT DEFAULT NULL,
    location VARCHAR(100) DEFAULT NULL,
    zip_code VARCHAR(20) DEFAULT NULL,
    profile_image VARCHAR(255) DEFAULT NULL,
    status ENUM('active','inactive','suspended') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_location (location),
    INDEX idx_user_zip (zip_code),
    INDEX idx_user_status (status),
    INDEX idx_user_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: sellers (Book Sellers)
-- Purpose: Store seller account information and business details
CREATE TABLE IF NOT EXISTS sellers (
    seller_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) DEFAULT NULL,
    phone VARCHAR(20) DEFAULT NULL,
    address TEXT DEFAULT NULL,
    location VARCHAR(100) DEFAULT NULL,
    zip_code VARCHAR(20) DEFAULT NULL,
    profile_image VARCHAR(255) DEFAULT NULL,
    description TEXT DEFAULT NULL,
    status ENUM('active','inactive','suspended') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_seller_location (location),
    INDEX idx_seller_zip (zip_code),
    INDEX idx_seller_status (status),
    INDEX idx_seller_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- SECTION 2: BOOK CATALOG TABLES
-- Purpose: Manage books, authors, genres
-- ====================================================

-- Table: authors
-- Purpose: Store author information
CREATE TABLE IF NOT EXISTS authors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    bio TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_author_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: books
-- Purpose: Store book listings with details
-- Foreign Keys: seller_id -> sellers(seller_id)
CREATE TABLE IF NOT EXISTS books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    isbn VARCHAR(30) DEFAULT NULL,
    price DECIMAL(10,2) DEFAULT 0.00,
    `condition` VARCHAR(50) DEFAULT NULL,
    `binding` VARCHAR(50) DEFAULT NULL,
    `language` VARCHAR(50) DEFAULT 'English',
    edition VARCHAR(50) DEFAULT NULL,
    publisher VARCHAR(200) DEFAULT NULL,
    cover_image VARCHAR(255) DEFAULT NULL,
    description TEXT DEFAULT NULL,
    book_condition VARCHAR(50) DEFAULT NULL,
    product_type VARCHAR(50) DEFAULT 'book',
    status ENUM('pending','approved','rejected') DEFAULT 'pending',
    is_active TINYINT(1) DEFAULT 1,
    seller_id INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_book_seller (seller_id),
    INDEX idx_book_price (price),
    INDEX idx_book_created (created_at),
    INDEX idx_book_isbn (isbn),
    INDEX idx_book_title (title),
    INDEX idx_book_status (status),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: book_authors (Junction Table)
-- Purpose: Many-to-Many relationship between books and authors
-- Foreign Keys: book_id -> books(id), author_id -> authors(id)
CREATE TABLE IF NOT EXISTS book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    INDEX idx_ba_book (book_id),
    INDEX idx_ba_author (author_id),
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: genres
-- Purpose: Store book genres/categories
CREATE TABLE IF NOT EXISTS genres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: book_genres (Junction Table)
-- Purpose: Many-to-Many relationship between books and genres
-- Foreign Keys: book_id -> books(id), genre_id -> genres(id)
CREATE TABLE IF NOT EXISTS book_genres (
    book_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (book_id, genre_id),
    INDEX idx_bg_book (book_id),
    INDEX idx_bg_genre (genre_id),
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- SECTION 3: E-COMMERCE TABLES
-- Purpose: Orders, wishlist, shopping cart
-- ====================================================

-- Table: orders
-- Purpose: Store customer orders
-- Foreign Keys: user_id -> users(user_id), seller_id -> sellers(seller_id), book_id -> books(id)
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    seller_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT DEFAULT 1,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending','confirmed','completed','cancelled') DEFAULT 'pending',
    payment_method VARCHAR(50) DEFAULT NULL,
    shipping_address TEXT DEFAULT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_user (user_id),
    INDEX idx_order_seller (seller_id),
    INDEX idx_order_book (book_id),
    INDEX idx_order_status (status),
    INDEX idx_order_date (order_date),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: user_wishlist
-- Purpose: Store user's wishlist items
-- Foreign Keys: user_id -> users(user_id), book_id -> books(id)
CREATE TABLE IF NOT EXISTS user_wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_book (user_id, book_id),
    INDEX idx_wishlist_user (user_id),
    INDEX idx_wishlist_book (book_id),
    INDEX idx_wishlist_added (added_date),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- SECTION 4: RATING & REVIEW TABLES
-- Purpose: Book ratings, seller ratings
-- ====================================================

-- Table: book_ratings
-- Purpose: Store book ratings and reviews by users
-- Foreign Keys: book_id -> books(id), user_id -> users(user_id)
CREATE TABLE IF NOT EXISTS book_ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    rating DECIMAL(3,2) NOT NULL CHECK (rating >= 0 AND rating <= 5),
    review TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_book_rating (user_id, book_id),
    INDEX idx_br_book (book_id),
    INDEX idx_br_user (user_id),
    INDEX idx_br_rating (rating),
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: book_rating_stats
-- Purpose: Aggregate rating statistics for each book (denormalized for performance)
-- Foreign Keys: book_id -> books(id)
CREATE TABLE IF NOT EXISTS book_rating_stats (
    book_id INT PRIMARY KEY,
    total_ratings INT DEFAULT 0,
    sum_ratings INT DEFAULT 0,
    avg_rating DECIMAL(3,2) DEFAULT 0.00,
    rating_1_count INT DEFAULT 0,
    rating_2_count INT DEFAULT 0,
    rating_3_count INT DEFAULT 0,
    rating_4_count INT DEFAULT 0,
    rating_5_count INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: seller_ratings
-- Purpose: Store seller ratings by users
-- Foreign Keys: seller_id -> sellers(seller_id), user_id -> users(user_id)
CREATE TABLE IF NOT EXISTS seller_ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    user_id INT NOT NULL,
    rating DECIMAL(3,2) NOT NULL CHECK (rating >= 0 AND rating <= 5),
    review TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_seller_rating (user_id, seller_id),
    INDEX idx_sr_seller (seller_id),
    INDEX idx_sr_user (user_id),
    INDEX idx_sr_rating (rating),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- SECTION 5: STATISTICS TABLES
-- Purpose: Track seller performance and revenue
-- ====================================================

-- Table: seller_statistics
-- Purpose: Aggregate statistics for each seller
-- Foreign Keys: seller_id -> sellers(seller_id)
CREATE TABLE IF NOT EXISTS seller_statistics (
    seller_id INT PRIMARY KEY,
    total_books_listed INT DEFAULT 0,
    total_orders INT DEFAULT 0,
    completed_orders INT DEFAULT 0,
    cancelled_orders INT DEFAULT 0,
    pending_orders INT DEFAULT 0,
    total_revenue DECIMAL(10,2) DEFAULT 0.00,
    completed_revenue DECIMAL(10,2) DEFAULT 0.00,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_ratings INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- SECTION 6: USER ACTIVITY TRACKING TABLES
-- Purpose: Track user behavior for recommendations
-- ====================================================

-- Table: user_book_views
-- Purpose: Track which books users have viewed
-- Foreign Keys: user_id -> users(user_id), book_id -> books(id), seller_id -> sellers(seller_id)
CREATE TABLE IF NOT EXISTS user_book_views (
    view_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    seller_id INT DEFAULT NULL,
    book_id INT NOT NULL,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ubv_user (user_id),
    INDEX idx_ubv_seller (seller_id),
    INDEX idx_ubv_book (book_id),
    INDEX idx_ubv_viewed (viewed_at),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: user_search_history
-- Purpose: Track user search queries for recommendations
-- Foreign Keys: user_id -> users(user_id), seller_id -> sellers(seller_id)
CREATE TABLE IF NOT EXISTS user_search_history (
    search_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    seller_id INT DEFAULT NULL,
    search_query TEXT NOT NULL,
    filters JSON DEFAULT NULL,
    result_count INT DEFAULT 0,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ush_user (user_id),
    INDEX idx_ush_seller (seller_id),
    INDEX idx_ush_searched (searched_at),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: user_preferences
-- Purpose: Store user/seller preferences for personalized recommendations
-- Foreign Keys: user_id -> users(user_id), seller_id -> sellers(seller_id)
CREATE TABLE IF NOT EXISTS user_preferences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    seller_id INT DEFAULT NULL,
    preferred_categories TEXT DEFAULT NULL, -- JSON array
    preferred_price_range VARCHAR(50) DEFAULT NULL,
    preferred_condition VARCHAR(50) DEFAULT NULL,
    preferred_binding VARCHAR(50) DEFAULT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_prefs (user_id),
    UNIQUE KEY unique_seller_prefs (seller_id),
    INDEX idx_up_user (user_id),
    INDEX idx_up_seller (seller_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- SECTION 7: NOTIFICATION & MESSAGING TABLES
-- Purpose: User notifications and inter-user messaging
-- ====================================================

-- Table: notifications
-- Purpose: Store user/seller notifications
-- Foreign Keys: user_id -> users(user_id), seller_id -> sellers(seller_id)
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    seller_id INT DEFAULT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('order','message','system','admin') DEFAULT 'system',
    is_read TINYINT(1) DEFAULT 0,
    related_id INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_notif_user (user_id),
    INDEX idx_notif_seller (seller_id),
    INDEX idx_notif_read (is_read),
    INDEX idx_notif_type (type),
    INDEX idx_notif_created (created_at),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: messages
-- Purpose: Direct messages between users and sellers
-- Foreign Keys: sender_user_id/receiver_user_id -> users(user_id), sender_seller_id/receiver_seller_id -> sellers(seller_id)
CREATE TABLE IF NOT EXISTS messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id VARCHAR(100) NOT NULL,
    sender_user_id INT DEFAULT NULL,
    sender_seller_id INT DEFAULT NULL,
    receiver_user_id INT DEFAULT NULL,
    receiver_seller_id INT DEFAULT NULL,
    message_text TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_msg_conversation (conversation_id),
    INDEX idx_msg_sender_user (sender_user_id),
    INDEX idx_msg_sender_seller (sender_seller_id),
    INDEX idx_msg_receiver_user (receiver_user_id),
    INDEX idx_msg_receiver_seller (receiver_seller_id),
    INDEX idx_msg_sent (sent_at),
    FOREIGN KEY (sender_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (sender_seller_id) REFERENCES sellers(seller_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_seller_id) REFERENCES sellers(seller_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- SECTION 8: CMS TABLES
-- Purpose: Quotes, tips, FAQs for homepage
-- ====================================================

-- Table: quotes
-- Purpose: Inspirational quotes for homepage
CREATE TABLE IF NOT EXISTS quotes (
    quote_id INT AUTO_INCREMENT PRIMARY KEY,
    quote_text TEXT NOT NULL,
    author VARCHAR(200) DEFAULT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_quote_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: seller_tips
-- Purpose: Tips and advice for sellers
CREATE TABLE IF NOT EXISTS seller_tips (
    tip_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    icon VARCHAR(50) DEFAULT '💡',
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tip_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: faqs
-- Purpose: Frequently asked questions for help page
CREATE TABLE IF NOT EXISTS faqs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question VARCHAR(500) NOT NULL,
    answer TEXT NOT NULL,
    category ENUM('general','buyer','seller') DEFAULT 'general',
    is_active TINYINT(1) DEFAULT 1,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_faq_category (category),
    INDEX idx_faq_active (is_active),
    INDEX idx_faq_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- END OF SCHEMA CREATION
-- Next: Run 01_insert_data.sql
-- ====================================================
