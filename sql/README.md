# ShiniNoMori Bookstore - SQL Files Organization

## ✅ NEW ORGANIZED SQL FILES (Run in this order)

### 1. **00_schema_tables.sql** (CREATE TABLE & ALTER TABLE)
- All database schema definitions
- All table structures
- All indexes and foreign keys
- Run this FIRST

### 2. **01_insert_data.sql** (INSERT statements)
- Sample data for all tables
- Users, sellers, books, authors
- Orders, ratings, quotes, FAQs, seller tips
- Run this SECOND

### 3. **02_stored_procedures.sql** (All stored procedures)
- Search & browse procedures (search_books, browse_books)
- Homepage procedures (get_random_quote, get_best_sellers, get_new_arrivals)
- Recommendation procedures (get_user_recommendations, get_seller_recommendations)
- Seller dashboard procedures (get_seller_dashboard_stats)
- Rating procedures (add_or_update_rating, get_book_rating_details)
- **Advanced rating procedures** (update_rating_statistics, get_top_rated_books, initialize_all_rating_stats)
- Messaging procedures (send_message, mark_messages_read)
- Utility procedures (proc_give_discount, proc_count_books_by_author)
- Run this THIRD

### 4. **03_stored_functions.sql** (All stored functions)
- Book rating functions (calculate_book_avg_rating, get_rating_stars)
- Seller statistics functions (fn_avg_price_by_seller, calculate_seller_revenue)
- Seller rating functions (get_seller_average_rating, can_user_rate_seller)
- Messaging functions (generate_conversation_id, count_unread_messages)
- Run this FOURTH

### 5. **04_triggers.sql** (All triggers)
- Book validation triggers (trg_books_price_check)
- Rating triggers (after_rating_insert, after_rating_update, after_rating_delete)
  - **Now includes calls to update_rating_statistics procedure**
- Order tracking triggers (after_order_insert, after_order_update)
- Notification triggers (notify_seller_on_order, notify_user_on_status_change)
- Run this FIFTH

### 6. **05_queries.sql** (Standalone SELECT queries)
- Pattern matching queries (LIKE, REGEXP, BETWEEN)
- Aggregate queries (COUNT, AVG, SUM)
- JOIN queries (book listings, seller info)
- Dashboard queries (user, seller, admin)
- Search queries
- Notification & messaging queries
- This is REFERENCE ONLY (queries are used in PHP files)

---

## ❌ OLD/REDUNDANT FILES TO DELETE

### Files with duplicate content (already merged into new files):

1. **02_queries_and_procedures.sql**
   - REDUNDANT: Content split into 02_stored_procedures.sql, 03_stored_functions.sql, 04_triggers.sql, and 05_queries.sql
   - ❌ DELETE THIS

2. **database_queries_mysql.sql**
   - REDUNDANT: Duplicate of 02_queries_and_procedures.sql
   - ❌ DELETE THIS

3. **fix_browse_procedures.sql**
   - REDUNDANT: browse_books procedure already in 02_stored_procedures.sql
   - ❌ DELETE THIS

4. **fix_missing_procedures.sql**
   - REDUNDANT: All procedures (get_user_recommendations, get_random_quote, etc.) already in 02_stored_procedures.sql
   - ❌ DELETE THIS

5. **fix_search_procedure.sql**
   - REDUNDANT: search_books procedure already in 02_stored_procedures.sql
   - ❌ DELETE THIS

6. **home_page_procedures.sql**
   - REDUNDANT: All homepage procedures already in 02_stored_procedures.sql
   - ❌ DELETE THIS

7. **user_activity_tracking.sql**
   - REDUNDANT: Recommendation procedures already in 02_stored_procedures.sql
   - ❌ DELETE THIS

8. **sellers.sql**
   - REDUNDANT: Sellers table already in 00_schema_tables.sql
   - ❌ DELETE THIS

9. **users.sql**
   - REDUNDANT: Users table already in 00_schema_tables.sql
   - ❌ DELETE THIS

### Feature-specific files (now fully merged):

10. **advanced_rating_system.sql**
    - ✅ ALL CONTENT NOW MERGED into organized files:
      - Table `book_rating_statistics` → 00_schema_tables.sql
      - Functions (calculate_book_avg_rating, get_rating_stars) → 03_stored_functions.sql
      - Procedures (update_rating_statistics, get_top_rated_books, initialize_all_rating_stats, add_or_update_rating, get_book_rating_details) → 02_stored_procedures.sql
      - Triggers (after_rating_insert/update/delete) → 04_triggers.sql (now call update_rating_statistics)
    - ❌ DELETE THIS

11. **notification_messaging_system.sql**
    - ✅ ALL CONTENT NOW MERGED into organized files:
      - Tables (notifications, messages) → 00_schema_tables.sql
      - Functions (generate_conversation_id, count_unread_notifications, count_unread_messages) → 03_stored_functions.sql
      - Procedures (send_message, mark_messages_read, mark_notification_read) → 02_stored_procedures.sql
      - Triggers (notify_seller_on_order, notify_user_on_status_change, notify_admin_new_user, notify_admin_new_seller) → 04_triggers.sql
    - ❌ DELETE THIS

12. **01_create_tables_and_data.sql**
    - REDUNDANT: Old combined file, replaced by 00_schema_tables.sql and 01_insert_data.sql
    - ❌ DELETE THIS
    - Note: Tables already in 00_schema_tables.sql, but functions/procedures are here

12. **seller_ratings_system.sql**
    - Contains: Seller rating functions
    - Status: Functions already in 03_stored_functions.sql
    - ❌ DELETE THIS (redundant)

13. **seller_revenue_system.sql**
    - Contains: Seller statistics tracking
    - Status: Functions already in 03_stored_functions.sql
    - Status: seller_statistics table already in 00_schema_tables.sql
    - ❌ DELETE THIS (redundant)

14. **seller_tips.sql**
    - Contains: Seller tips table
    - Status: Table already in 00_schema_tables.sql
    - ❌ DELETE THIS (redundant)

15. **user_wishlist.sql**
    - Contains: Wishlist table
    - Status: Table already in 00_schema_tables.sql
    - ❌ DELETE THIS (redundant)

### Admin/utility files (optional - keep for manual operations):

16. **update_admin.sql**
    - Contains: Manual admin email update
    - Status: KEEP for manual admin changes

17. **add_book_cover_column.sql**
    - Contains: ALTER TABLE to add cover_image column
    - Status: Column already in 00_schema_tables.sql
    - ❌ DELETE THIS (redundant)

---

## 📋 SUMMARY OF FILES TO DELETE

**Delete these 17 files (safe to remove - all content is in new organized files):**

```bash
# Navigate to sql folder
cd c:\xampp\htdocs\shininomori\sql

# Delete redundant files
del 02_queries_and_procedures.sql
del database_queries_mysql.sql
del fix_browse_procedures.sql
del fix_missing_procedures.sql
del fix_search_procedure.sql
del home_page_procedures.sql
del user_activity_tracking.sql
del sellers.sql
del users.sql
del seller_ratings_system.sql
del seller_revenue_system.sql
del seller_tips.sql
del user_wishlist.sql
del add_book_cover_column.sql
del advanced_rating_system.sql
del notification_messaging_system.sql
del 01_create_tables_and_data.sql
```

**Keep these files (ONLY these 6 + optional update_admin.sql):**
- ✅ **00_schema_tables.sql** (NEW - all table definitions including book_rating_statistics, notifications, messages)
- ✅ **01_insert_data.sql** (NEW - all sample data)
- ✅ **02_stored_procedures.sql** (NEW - all procedures including rating stats, messaging, notifications)
- ✅ **03_stored_functions.sql** (NEW - all functions including rating, messaging, seller stats)
- ✅ **04_triggers.sql** (NEW - all triggers including rating updates, notifications)
- ✅ **05_queries.sql** (NEW - reference queries)
- ✅ **update_admin.sql** (OPTIONAL - utility file for manual admin updates)


---

## 🚀 HOW TO USE THE NEW SQL FILES

### Fresh Database Setup:
```sql
-- 1. Create database and tables
mysql -u root -p oldbookstore < 00_schema_tables.sql

-- 2. Insert sample data
mysql -u root -p oldbookstore < 01_insert_data.sql

-- 3. Create stored procedures
mysql -u root -p oldbookstore < 02_stored_procedures.sql

-- 4. Create stored functions
mysql -u root -p oldbookstore < 03_stored_functions.sql

-- 5. Create triggers
mysql -u root -p oldbookstore < 04_triggers.sql

-- 6. (Optional) Review queries in 05_queries.sql
```

### Via phpMyAdmin:
1. Open phpMyAdmin
2. Select `oldbookstore` database (or create it)
3. Go to SQL tab
4. Import each file in order:
   - 00_schema_tables.sql
   - 01_insert_data.sql
   - 02_stored_procedures.sql
   - 03_stored_functions.sql
   - 04_triggers.sql

---

## 📝 WHAT EACH NEW FILE CONTAINS

### 00_schema_tables.sql
- Section 1: Core user tables (users, sellers)
- Section 2: Book catalog tables (books, authors, genres)
- Section 3: E-commerce tables (orders, wishlist)
- Section 4: Rating tables (book_ratings, seller_ratings, statistics)
- Section 5: Statistics tables (seller_statistics)
- Section 6: Activity tracking (user_book_views, search_history)
- Section 7: Notification & messaging (notifications, messages)
- Section 8: CMS tables (quotes, seller_tips, faqs)

### 01_insert_data.sql
- Section 1: User data (5 sample users)
- Section 2: Seller data (3 sample sellers)
- Section 3: Author data (15 authors)
- Section 4: Genre data (18 genres)
- Section 5: Book data (15 books)
- Section 6-7: Book relationships (authors, genres)
- Section 8: Quotes (8 quotes)
- Section 9: Seller tips (6 tips)
- Section 10: FAQs (17 FAQs for help page)
- Section 11-14: Sample orders, ratings, views, wishlist

### 02_stored_procedures.sql
- Section 1: Search & browse (search_books, browse_books, count_browse_books)
- Section 2: Homepage (get_random_quote, get_best_sellers, get_new_arrivals, get_featured_categories)
- Section 3: Recommendations (get_user_recommendations, get_seller_recommendations, get_user_recently_viewed, get_user_recent_searches)
- Section 4: Seller dashboard (get_seller_dashboard_stats, get_seller_home_stats, get_seller_tips)
- Section 5: Ratings (add_or_update_rating, get_book_rating_details)
- Section 6: Messaging (send_message, mark_messages_read, mark_notification_read)
- Section 7: Utility (proc_give_discount, proc_count_books_by_author)

### 03_stored_functions.sql
- Section 1: Book ratings (calculate_book_avg_rating, get_rating_stars)
- Section 2: Seller statistics (fn_avg_price_by_seller, fn_seller_total_revenue, calculate_seller_revenue, count_seller_orders, calculate_commission)
- Section 3: Seller ratings (get_seller_average_rating, get_seller_rating_count, can_user_rate_seller)
- Section 4: Messaging (generate_conversation_id, count_unread_notifications, count_unread_messages, get_latest_message_text)

### 04_triggers.sql
- Section 1: Book validation (trg_books_price_check, trg_books_after_insert)
- Section 2: Rating tracking (after_rating_insert, after_rating_update, after_rating_delete)
- Section 3: Order tracking (after_order_insert, after_order_update, after_order_delete)
- Section 4: Book tracking (after_book_insert, after_book_delete)
- Section 5: Notifications (notify_seller_on_order, notify_user_on_status_change, notify_admin_new_user, notify_admin_new_seller)
- Section 6: Activity tracking (trg_log_book_view)

### 05_queries.sql
- Section 1: Pattern matching (LIKE, REGEXP, BETWEEN, IN)
- Section 2: Aggregate functions (COUNT, AVG, SUM, MAX, MIN)
- Section 3: Joins (INNER, LEFT, multiple)
- Section 4: User dashboard queries
- Section 5: Seller dashboard queries
- Section 6: Seller profile queries
- Section 7: Admin dashboard queries
- Section 8: Search & autocomplete
- Section 9: Notifications
- Section 10: Messaging
- Section 11: Wishlist check
- Section 12: Order details

---

**Created by:** GitHub Copilot for ShiniNoMori Bookstore
**Date:** October 25, 2025
**Purpose:** Clean, organized, well-commented SQL structure for easy learning and maintenance
