-- Add password reset fields to users table
ALTER TABLE users 
ADD COLUMN password_reset_token VARCHAR(255) NULL,
ADD COLUMN password_reset_expires DATETIME NULL,
ADD INDEX idx_password_reset_token (password_reset_token);
