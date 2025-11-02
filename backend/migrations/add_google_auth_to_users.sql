-- Migration: Add Google OAuth support to users table
-- Date: 2024
-- Description: Add google_id column and make password optional for Google login

-- Add google_id column for storing Google user ID
ALTER TABLE users 
ADD COLUMN google_id VARCHAR(255) UNIQUE AFTER email;

-- Make password nullable to allow Google-only accounts
ALTER TABLE users 
MODIFY COLUMN password VARCHAR(255) NULL;

-- Add index for faster Google ID lookups
CREATE INDEX idx_users_google_id ON users(google_id);

-- Add comment for documentation
ALTER TABLE users 
COMMENT = 'Users table with support for email/password and Google OAuth authentication';
