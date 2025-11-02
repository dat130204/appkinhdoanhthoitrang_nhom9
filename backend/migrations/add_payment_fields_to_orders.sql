-- Migration: Add VNPay payment fields to orders table
-- Date: 2024-10-31
-- Description: Add payment_method, payment_status, and transaction_id for VNPay integration

-- Add payment_method column (COD or VNPay)
ALTER TABLE orders 
ADD COLUMN payment_method VARCHAR(50) DEFAULT 'COD' AFTER total_amount;

-- Add payment_status column (pending, paid, failed)
ALTER TABLE orders 
ADD COLUMN payment_status ENUM('pending', 'paid', 'failed', 'cancelled') DEFAULT 'pending' AFTER payment_method;

-- Add transaction_id for VNPay transaction reference
ALTER TABLE orders 
ADD COLUMN transaction_id VARCHAR(255) NULL AFTER payment_status;

-- Add payment_date timestamp
ALTER TABLE orders 
ADD COLUMN payment_date DATETIME NULL AFTER transaction_id;

-- Add VNPay response data (store full response for debugging)
ALTER TABLE orders 
ADD COLUMN payment_response JSON NULL AFTER payment_date;

-- Create index for faster payment status queries
CREATE INDEX idx_orders_payment_status ON orders(payment_status);

-- Create index for transaction_id lookup
CREATE INDEX idx_orders_transaction_id ON orders(transaction_id);

-- Create index for payment_method filtering
CREATE INDEX idx_orders_payment_method ON orders(payment_method);

-- Add comment for documentation
ALTER TABLE orders 
COMMENT = 'Orders table with VNPay payment integration support';
