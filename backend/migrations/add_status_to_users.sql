-- Add status column to users table for active/blocked status
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS status ENUM('active', 'blocked') DEFAULT 'active' AFTER role;

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Update existing users to active status
UPDATE users SET status = 'active' WHERE status IS NULL;
