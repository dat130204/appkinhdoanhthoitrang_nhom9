const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkDatabase() {
  let connection;
  
  try {
    console.log('🔍 Checking database data...\n');
    
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: 'fashion_shop',
      port: process.env.DB_PORT || 3306
    });

    console.log('✅ Connected to fashion_shop database\n');

    // Check users
    const [users] = await connection.query('SELECT COUNT(*) as count FROM users');
    console.log(`👥 Users: ${users[0].count} records`);

    // Check categories
    const [categories] = await connection.query('SELECT COUNT(*) as count FROM categories');
    console.log(`📁 Categories: ${categories[0].count} records`);

    // Check products
    const [products] = await connection.query('SELECT COUNT(*) as count FROM products');
    console.log(`🛍️  Products: ${products[0].count} records`);

    // Check product_images
    const [images] = await connection.query('SELECT COUNT(*) as count FROM product_images');
    console.log(`🖼️  Product Images: ${images[0].count} records`);

    // Check product_variants
    const [variants] = await connection.query('SELECT COUNT(*) as count FROM product_variants');
    console.log(`🎨 Product Variants: ${variants[0].count} records`);

    // Check reviews
    const [reviews] = await connection.query('SELECT COUNT(*) as count FROM reviews');
    console.log(`⭐ Reviews: ${reviews[0].count} records`);

    // Check orders
    const [orders] = await connection.query('SELECT COUNT(*) as count FROM orders');
    console.log(`📦 Orders: ${orders[0].count} records`);

    // Check wishlists
    const [wishlists] = await connection.query('SELECT COUNT(*) as count FROM wishlists');
    console.log(`❤️  Wishlists: ${wishlists[0].count} records`);

    // Check favorites
    const [favorites] = await connection.query('SELECT COUNT(*) as count FROM favorites');
    console.log(`⭐ Favorites: ${favorites[0].count} records`);

    console.log('\n📊 Summary:');
    const totalRecords = users[0].count + categories[0].count + products[0].count + 
                         images[0].count + variants[0].count + reviews[0].count + 
                         orders[0].count + wishlists[0].count + favorites[0].count;
    console.log(`Total records: ${totalRecords}`);

    if (categories[0].count === 0 || products[0].count === 0) {
      console.log('\n⚠️  WARNING: Missing seed data!');
      console.log('Run: node scripts/initDatabase.js to reinitialize database with seed data');
    } else {
      console.log('\n✅ Database has seed data!');
    }

  } catch (error) {
    console.error('❌ Error checking database:', error.message);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

checkDatabase();
