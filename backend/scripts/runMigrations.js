const pool = require('../config/database');
const fs = require('fs').promises;
const path = require('path');

async function runMigrations() {
  try {
    console.log('🔄 Running migrations...');

    // Read and run notifications migration
    const notificationsSql = await fs.readFile(
      path.join(__dirname, '../migrations/create_notifications_table.sql'),
      'utf8'
    );
    
    const notificationsStatements = notificationsSql
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'));

    for (const statement of notificationsStatements) {
      await pool.query(statement);
    }
    console.log('✅ Notifications table created successfully');

    // Read and run settings migration
    const settingsSql = await fs.readFile(
      path.join(__dirname, '../migrations/create_settings_table.sql'),
      'utf8'
    );
    
    const settingsStatements = settingsSql
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'));

    for (const statement of settingsStatements) {
      await pool.query(statement);
    }
    console.log('✅ Settings table created successfully');

    // Read and run Google auth migration
    const googleAuthSql = await fs.readFile(
      path.join(__dirname, '../migrations/add_google_auth_to_users.sql'),
      'utf8'
    );
    
    const googleAuthStatements = googleAuthSql
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'));

    for (const statement of googleAuthStatements) {
      await pool.query(statement);
    }
    console.log('✅ Google auth fields added to users table successfully');

    // Read and run payment fields migration
    const paymentSql = await fs.readFile(
      path.join(__dirname, '../migrations/add_payment_fields_to_orders.sql'),
      'utf8'
    );
    
    const paymentStatements = paymentSql
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'));

    for (const statement of paymentStatements) {
      await pool.query(statement);
    }
    console.log('✅ Payment fields added to orders table successfully');

    console.log('✅ All migrations completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

runMigrations();
