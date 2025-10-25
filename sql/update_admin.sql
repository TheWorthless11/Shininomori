-- Update Admin Account
-- This script will update the existing admin account or create a new one with your email

-- Option 1: Update existing admin account
-- Find the admin account and update the email
UPDATE users 
SET email = 'mahhiamim@gmail.com',
    username = 'mahhiamim'
WHERE email = 'admin@example.com';

-- If no rows were affected, it means the dummy admin doesn't exist
-- You can create a new admin account by running this:

-- Option 2: Create new admin account (only if update above didn't work)
-- Note: Password is hashed. Default password is 'admin123'
-- You should change this after first login!

INSERT INTO users (username, email, password, user_type, created_at)
VALUES (
    'mahhiamim',
    'mahhiamim@gmail.com',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- Password: 'password'
    'user',
    NOW()
)
ON DUPLICATE KEY UPDATE 
    email = 'mahhiamim@gmail.com',
    username = 'mahhiamim';

-- Check if the update was successful
SELECT user_id, username, email, user_type, created_at 
FROM users 
WHERE email = 'mahhiamim@gmail.com';

-- Note: The system identifies admin by email in config.php ($ADMIN_EMAIL)
-- So make sure the email in the database matches 'mahhiamim@gmail.com'
