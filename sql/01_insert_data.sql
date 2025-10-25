-- ====================================================
-- SHININOMORI BOOKSTORE - SAMPLE DATA
-- File: 01_insert_data.sql
-- Purpose: All INSERT statements for sample/initial data
-- Run this AFTER 00_schema_tables.sql
-- ====================================================

USE oldbookstore;

-- ====================================================
-- SECTION 1: USER DATA
-- Purpose: Sample user accounts (buyers)
-- ====================================================

INSERT INTO users (username, email, password, full_name, location, zip_code, status) VALUES
('admin', 'admin@example.com', '$2y$10$eHXuN8gzvB4pZnLg5YPQYuF.', 'Site Administrator', 'Headquarters', '00000', 'active'),
('alice', 'alice@example.com', '$2y$10$eHXuN8gzvB4pZnLg5YPQYuF.', 'Alice Smith', 'Townsville', '12345', 'active'),
('bob', 'bob.j@example.com', '$2y$10$eHXuN8gzvB4pZnLg5YPQYuF.', 'Bob Johnson', 'Village', '67890', 'active'),
('carol', 'carol_d@example.com', '$2y$10$eHXuN8gzvB4pZnLg5YPQYuF.', 'Carol Davis', 'City', '23456', 'active'),
('david', 'david@example.com', '$2y$10$eHXuN8gzvB4pZnLg5YPQYuF.', 'David Wilson', 'Metro', '34567', 'active')
ON DUPLICATE KEY UPDATE username=username;

-- ====================================================
-- SECTION 2: SELLER DATA
-- Purpose: Sample seller accounts
-- ====================================================

INSERT INTO sellers (username, email, password, full_name, phone, location, zip_code, description, status) VALUES
('seller1', 's1@example.com', '$2y$10$eHXuN8gzvB4pZnLg5YPQYuF.', 'Seller One', '01711111111', 'Dhaka', '1200', 'Specialist in classic literature and rare books', 'active'),
('seller2', 's2@example.com', '$2y$10$eHXuN8gzvB4pZnLg5YPQYuF.', 'Seller Two', '01722222222', 'Chittagong', '4000', 'Horror and thriller book expert', 'active'),
('seller3', 's3@example.com', '$2y$10$eHXuN8gzvB4pZnLg5YPQYuF.', 'Seller Three', '01733333333', 'Sylhet', '3100', 'Mystery and detective novels collection', 'active')
ON DUPLICATE KEY UPDATE username=username;

-- ====================================================
-- SECTION 3: AUTHOR DATA
-- Purpose: Book authors
-- ====================================================

INSERT INTO authors (name, bio) VALUES 
('J.K. Rowling', 'British author, best known for the Harry Potter series'),
('George R.R. Martin', 'American novelist and short story writer, creator of A Song of Ice and Fire'),
('Stephen King', 'American author of horror, supernatural fiction, suspense, crime, science-fiction'),
('Agatha Christie', 'English writer known for her detective novels'),
('Dan Brown', 'American author best known for his thriller novels'),
('Paulo Coelho', 'Brazilian lyricist and novelist, best known for The Alchemist'),
('Gabriel García Márquez', 'Colombian novelist, Nobel Prize winner'),
('Ernest Hemingway', 'American novelist, Nobel Prize winner'),
('Jane Austen', 'English novelist known for romantic fiction'),
('Mark Twain', 'American writer, humorist, entrepreneur'),
('Leo Tolstoy', 'Russian writer regarded as one of the greatest authors'),
('F. Scott Fitzgerald', 'American novelist and short story writer'),
('Harper Lee', 'American novelist known for To Kill a Mockingbird'),
('J.R.R. Tolkien', 'English writer, poet, and philologist, author of The Lord of the Rings'),
('C.S. Lewis', 'British writer and lay theologian, author of The Chronicles of Narnia')
ON DUPLICATE KEY UPDATE name=name;

-- ====================================================
-- SECTION 4: GENRE DATA
-- Purpose: Book categories/genres
-- ====================================================

INSERT INTO genres (name, description) VALUES
('Fiction', 'Fictional narrative books'),
('Non-Fiction', 'Educational and informational books'),
('Mystery', 'Mystery and detective stories'),
('Romance', 'Romantic fiction'),
('Science Fiction', 'Futuristic and sci-fi novels'),
('Fantasy', 'Fantasy and magical worlds'),
('Biography', 'Life stories and biographies'),
('History', 'Historical books and accounts'),
('Self-Help', 'Personal development books'),
('Business', 'Business and entrepreneurship'),
('Technology', 'Computer science and technology'),
('Science', 'Scientific books and research'),
('Children', 'Books for children'),
('Young Adult', 'Books for young adults'),
('Comics', 'Comic books and graphic novels'),
('Horror', 'Horror and thriller books'),
('Philosophy', 'Philosophical works'),
('Classic', 'Classic literature')
ON DUPLICATE KEY UPDATE name=name;

-- ====================================================
-- SECTION 5: BOOK DATA
-- Purpose: Sample book listings
-- ====================================================

INSERT INTO books (title, isbn, price, `condition`, `binding`, `language`, edition, publisher, product_type, seller_id, status, description) VALUES
('Harry Potter and the Philosopher\'s Stone', '978-0439708180', 450.00, 'Used', 'Paperback', 'English', '1st Edition', 'Bloomsbury', 'book', 1, 'approved', 'The first book in the Harry Potter series. Follow young Harry as he discovers his magical heritage.'),
('A Game of Thrones', '978-0553103540', 650.00, 'New', 'Hardcover', 'English', 'Special Edition', 'Bantam Books', 'book', 1, 'approved', 'The first book in A Song of Ice and Fire series. Epic fantasy with political intrigue.'),
('The Shining', '978-0385121675', 320.00, 'Used', 'Paperback', 'English', '2nd Edition', 'Doubleday', 'book', 2, 'approved', 'A classic horror novel by Stephen King about a haunted hotel.'),
('Murder on the Orient Express', '978-0062693662', 280.00, 'Used', 'Paperback', 'English', '1st Edition', 'William Morrow', 'book', 2, 'approved', 'An Hercule Poirot mystery set on a luxury train.'),
('The Da Vinci Code', '978-0307474278', 550.00, 'New', 'Hardcover', 'English', '1st Edition', 'Doubleday', 'book', 3, 'approved', 'A mystery thriller novel involving ancient secrets and symbology.'),
('The Alchemist', '978-0062315007', 380.00, 'Used', 'Paperback', 'English', '1st Edition', 'HarperOne', 'book', 3, 'approved', 'A philosophical novel about following your dreams and personal legend.'),
('One Hundred Years of Solitude', '978-0060883287', 420.00, 'New', 'Paperback', 'English', '1st Edition', 'Harper Perennial', 'book', 1, 'approved', 'A landmark novel of magical realism about the Buendía family.'),
('The Old Man and the Sea', '978-0684801223', 250.00, 'Used', 'Paperback', 'English', '1st Edition', 'Scribner', 'book', 2, 'approved', 'A short novel about an aging fisherman\'s epic struggle.'),
('Pride and Prejudice', '978-0141439518', 290.00, 'Used', 'Paperback', 'English', '1st Edition', 'Penguin Classics', 'book', 1, 'approved', 'Classic romantic novel by Jane Austen.'),
('The Adventures of Tom Sawyer', '978-0143107330', 310.00, 'New', 'Hardcover', 'English', '1st Edition', 'Penguin Classics', 'book', 2, 'approved', 'Mark Twain\'s classic American adventure story.'),
('War and Peace', '978-0199232765', 720.00, 'New', 'Hardcover', 'English', '1st Edition', 'Oxford University Press', 'book', 3, 'approved', 'Tolstoy\'s epic novel of Russian society during the Napoleonic era.'),
('The Great Gatsby', '978-0743273565', 340.00, 'Used', 'Paperback', 'English', '1st Edition', 'Scribner', 'book', 1, 'approved', 'F. Scott Fitzgerald\'s Jazz Age masterpiece.'),
('To Kill a Mockingbird', '978-0061120084', 360.00, 'Used', 'Paperback', 'English', '1st Edition', 'Harper Perennial', 'book', 2, 'approved', 'Harper Lee\'s Pulitzer Prize-winning novel about racial injustice.'),
('The Hobbit', '978-0547928227', 480.00, 'New', 'Hardcover', 'English', '1st Edition', 'Houghton Mifflin', 'book', 3, 'approved', 'Tolkien\'s prelude to The Lord of the Rings.'),
('The Chronicles of Narnia', '978-0066238500', 520.00, 'New', 'Hardcover', 'English', '1st Edition', 'HarperCollins', 'book', 1, 'approved', 'Complete collection of C.S. Lewis\'s magical series.')
ON DUPLICATE KEY UPDATE title=title;

-- ====================================================
-- SECTION 6: BOOK-AUTHOR RELATIONSHIPS
-- Purpose: Link books to their authors
-- ====================================================

INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1),   -- Harry Potter -> J.K. Rowling
(2, 2),   -- Game of Thrones -> George R.R. Martin
(3, 3),   -- The Shining -> Stephen King
(4, 4),   -- Murder on Orient Express -> Agatha Christie
(5, 5),   -- Da Vinci Code -> Dan Brown
(6, 6),   -- The Alchemist -> Paulo Coelho
(7, 7),   -- One Hundred Years -> Gabriel García Márquez
(8, 8),   -- Old Man and the Sea -> Ernest Hemingway
(9, 9),   -- Pride and Prejudice -> Jane Austen
(10, 10), -- Tom Sawyer -> Mark Twain
(11, 11), -- War and Peace -> Leo Tolstoy
(12, 12), -- Great Gatsby -> F. Scott Fitzgerald
(13, 13), -- To Kill a Mockingbird -> Harper Lee
(14, 14), -- The Hobbit -> J.R.R. Tolkien
(15, 15)  -- Chronicles of Narnia -> C.S. Lewis
ON DUPLICATE KEY UPDATE book_id=book_id;

-- ====================================================
-- SECTION 7: BOOK-GENRE RELATIONSHIPS
-- Purpose: Categorize books by genre
-- ====================================================

INSERT INTO book_genres (book_id, genre_id) VALUES
(1, 6),   -- Harry Potter -> Fantasy
(1, 14),  -- Harry Potter -> Young Adult
(2, 6),   -- Game of Thrones -> Fantasy
(3, 16),  -- The Shining -> Horror
(4, 3),   -- Murder on Orient Express -> Mystery
(5, 3),   -- Da Vinci Code -> Mystery
(6, 1),   -- The Alchemist -> Fiction
(6, 17),  -- The Alchemist -> Philosophy
(7, 1),   -- One Hundred Years -> Fiction
(7, 18),  -- One Hundred Years -> Classic
(8, 1),   -- Old Man and Sea -> Fiction
(8, 18),  -- Old Man and Sea -> Classic
(9, 4),   -- Pride and Prejudice -> Romance
(9, 18),  -- Pride and Prejudice -> Classic
(10, 1),  -- Tom Sawyer -> Fiction
(10, 18), -- Tom Sawyer -> Classic
(11, 8),  -- War and Peace -> History
(11, 18), -- War and Peace -> Classic
(12, 1),  -- Great Gatsby -> Fiction
(12, 18), -- Great Gatsby -> Classic
(13, 1),  -- To Kill a Mockingbird -> Fiction
(13, 18), -- To Kill a Mockingbird -> Classic
(14, 6),  -- The Hobbit -> Fantasy
(14, 14), -- The Hobbit -> Young Adult
(15, 6),  -- Chronicles of Narnia -> Fantasy
(15, 13)  -- Chronicles of Narnia -> Children
ON DUPLICATE KEY UPDATE book_id=book_id;

-- ====================================================
-- SECTION 8: QUOTES DATA
-- Purpose: Inspirational quotes for homepage
-- ====================================================

INSERT INTO quotes (quote_text, author, is_active) VALUES
('A reader lives a thousand lives before he dies. The man who never reads lives only one.', 'George R.R. Martin', 1),
('The only thing that you absolutely have to know, is the location of the library.', 'Albert Einstein', 1),
('There is no friend as loyal as a book.', 'Ernest Hemingway', 1),
('Books are a uniquely portable magic.', 'Stephen King', 1),
('Reading is to the mind what exercise is to the body.', 'Joseph Addison', 1),
('A room without books is like a body without a soul.', 'Marcus Tullius Cicero', 1),
('Good friends, good books, and a sleepy conscience: this is the ideal life.', 'Mark Twain', 1),
('The more that you read, the more things you will know.', 'Dr. Seuss', 1)
ON DUPLICATE KEY UPDATE quote_text=quote_text;

-- ====================================================
-- SECTION 9: SELLER TIPS DATA
-- Purpose: Helpful tips for sellers
-- ====================================================

INSERT INTO seller_tips (title, content, icon, is_active) VALUES
('Use Clear Photos', 'Take high-quality, well-lit photos of your books showing the cover and condition clearly. Books with photos sell 3x faster!', '📸', 1),
('Accurate Descriptions', 'Describe the condition honestly. Mention any damage, writing, or wear. Transparency builds trust with buyers.', '✍️', 1),
('Competitive Pricing', 'Research similar books to price competitively. Consider the edition, condition, and demand.', '💰', 1),
('Fast Response', 'Reply to buyer messages within 24 hours. Quick communication increases sales by 40%!', '⚡', 1),
('Quality Packaging', 'Package books securely to prevent damage during shipping. Use bubble wrap and sturdy boxes.', '📦', 1),
('Keep Inventory Updated', 'Remove sold books promptly and update your listings regularly to maintain credibility.', '🔄', 1)
ON DUPLICATE KEY UPDATE title=title;

-- ====================================================
-- SECTION 10: FAQ DATA
-- Purpose: Frequently asked questions for help page
-- Used in: help.php
-- ====================================================

INSERT INTO faqs (question, answer, category, is_active, display_order) VALUES
-- General FAQs
('What is ShiniNoMori Bookstore?', 'ShiniNoMori is an online marketplace for buying and selling used and new books. We connect book lovers with sellers offering a wide range of titles at affordable prices.', 'general', 1, 1),
('How do I create an account?', 'Click on "Sign Up" in the top menu, choose whether you want a buyer or seller account, and fill in your details. It\'s free and takes less than a minute!', 'general', 1, 2),
('Is it free to use ShiniNoMori?', 'Yes! Creating an account and browsing books is completely free. Sellers only pay a small commission on completed sales.', 'general', 1, 3),
('How do I contact customer support?', 'You can email us at mahhiamim@gmail.com or use the contact form on the Help page. We respond within 24 hours.', 'general', 1, 4),

-- Buyer FAQs
('How do I search for books?', 'Use the search bar at the top of the page or browse by category. You can filter by price, condition, genre, and more using the Advanced Search.', 'buyer', 1, 10),
('How do I place an order?', 'Find a book you like, click "Buy Now", review the details, and confirm your order. You\'ll receive a confirmation email with seller contact information.', 'buyer', 1, 11),
('What payment methods are accepted?', 'Payment is arranged directly with the seller. Common methods include cash on delivery, bank transfer, or mobile banking (bKash, Nagad, Rocket).', 'buyer', 1, 12),
('Can I cancel my order?', 'Yes, you can cancel an order before the seller confirms it. Go to "My Orders" and click "Cancel Order". Contact the seller directly for already-confirmed orders.', 'buyer', 1, 13),
('How do I track my order?', 'Check your order status in "My Dashboard". You\'ll receive notifications when the seller confirms, ships, or completes your order.', 'buyer', 1, 14),
('Can I return a book?', 'Return policies vary by seller. Contact the seller directly through our messaging system to discuss returns or exchanges.', 'buyer', 1, 15),

-- Seller FAQs
('How do I start selling books?', 'Sign up for a seller account, click "Start Selling", and add your first book listing with photos, description, price, and condition details.', 'seller', 1, 20),
('How do I add a book listing?', 'Go to your Seller Dashboard and click "Post New Book". Fill in the title, author, ISBN, price, condition, and upload a photo. Your listing will be reviewed and approved within 24 hours.', 'seller', 1, 21),
('What commission does ShiniNoMori charge?', 'We charge a small 5% commission on completed sales to maintain the platform and provide customer support.', 'seller', 1, 22),
('How do I receive payment from buyers?', 'Buyers contact you directly through our messaging system to arrange payment and delivery. We recommend cash on delivery or mobile banking.', 'seller', 1, 23),
('How do I manage my orders?', 'Go to "Seller Dashboard" > "Manage Orders". You can view pending orders, confirm them, and mark them as completed.', 'seller', 1, 24),
('Can I edit my book listings?', 'Yes! Go to "Seller Dashboard" > "My Books" and click "Edit" on any listing to update price, description, or photos.', 'seller', 1, 25),
('How do I improve my sales?', 'Use clear photos, write detailed descriptions, price competitively, and respond quickly to buyer messages. Check out our Seller Tips section for more advice!', 'seller', 1, 26)
ON DUPLICATE KEY UPDATE question=question;

-- ====================================================
-- SECTION 11: SAMPLE ORDERS
-- Purpose: Demo order history for testing
-- ====================================================

INSERT INTO orders (user_id, seller_id, book_id, quantity, total_amount, status, order_date, updated_at) VALUES
(2, 1, 1, 1, 450.00, 'completed', DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY)),
(2, 1, 2, 1, 650.00, 'completed', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
(3, 2, 3, 1, 320.00, 'completed', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(3, 2, 4, 1, 280.00, 'confirmed', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(4, 3, 5, 1, 550.00, 'completed', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
(2, 3, 6, 1, 380.00, 'pending', NOW(), NOW())
ON DUPLICATE KEY UPDATE order_id=order_id;

-- ====================================================
-- SECTION 12: SAMPLE BOOK RATINGS
-- Purpose: Demo ratings for testing
-- ====================================================

INSERT INTO book_ratings (user_id, book_id, rating, review) VALUES
(2, 1, 5.00, 'Amazing book! My kids loved it.'),
(2, 2, 4.50, 'Great fantasy series, highly recommend.'),
(3, 1, 5.00, 'Classic children\'s fantasy, never gets old.'),
(3, 3, 4.00, 'Scary but brilliant. Stephen King at his best.'),
(4, 5, 5.00, 'Couldn\'t put it down! Fantastic mystery thriller.')
ON DUPLICATE KEY UPDATE rating=rating;

-- ====================================================
-- SECTION 13: SAMPLE USER ACTIVITY (Book Views)
-- Purpose: Demo view history for recommendation engine
-- ====================================================

INSERT INTO user_book_views (user_id, book_id, viewed_at) VALUES
(2, 1, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
(2, 2, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(2, 3, DATE_SUB(NOW(), INTERVAL 3 HOUR)),
(3, 1, DATE_SUB(NOW(), INTERVAL 30 MINUTE)),
(3, 4, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
(4, 5, DATE_SUB(NOW(), INTERVAL 45 MINUTE)),
(4, 6, DATE_SUB(NOW(), INTERVAL 2 HOUR))
ON DUPLICATE KEY UPDATE view_id=view_id;

-- ====================================================
-- SECTION 14: SAMPLE WISHLIST
-- Purpose: Demo wishlist items
-- ====================================================

INSERT INTO wishlist (user_id, book_id) VALUES
(2, 7),  -- Alice wants One Hundred Years
(2, 8),  -- Alice wants Old Man and Sea
(3, 5),  -- Bob wants Da Vinci Code
(3, 6),  -- Bob wants The Alchemist
(4, 1),  -- Carol wants Harry Potter
(4, 2)   -- Carol wants Game of Thrones
ON DUPLICATE KEY UPDATE wishlist_id=wishlist_id;

-- ====================================================
-- END OF DATA INSERTION
-- Next: Run 02_stored_procedures.sql
-- ====================================================
