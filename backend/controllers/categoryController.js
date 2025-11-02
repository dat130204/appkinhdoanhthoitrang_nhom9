const Category = require('../models/Category');
const db = require('../config/database');
const fs = require('fs').promises;
const path = require('path');

class CategoryController {
  async getAll(req, res) {
    try {
      const { parent_id } = req.query;
      const filters = {};

      if (parent_id !== undefined) {
        filters.parent_id = parent_id === 'null' ? null : parseInt(parent_id);
      }

      const categories = await Category.findAll(filters);

      res.json({
        success: true,
        data: categories
      });
    } catch (error) {
      console.error('Get categories error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy danh sách danh mục'
      });
    }
  }

  async getTree(req, res) {
    try {
      const tree = await Category.getTree();
      res.json({
        success: true,
        data: tree
      });
    } catch (error) {
      console.error('Get category tree error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy cây danh mục'
      });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const category = await Category.findById(id);

      if (!category) {
        return res.status(404).json({
          success: false,
          message: 'Danh mục không tồn tại'
        });
      }

      res.json({
        success: true,
        data: category
      });
    } catch (error) {
      console.error('Get category error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy thông tin danh mục'
      });
    }
  }

  async create(req, res) {
    try {
      const categoryData = { ...req.body };
      
      // Handle image upload
      if (req.file) {
        categoryData.image = `/uploads/${req.file.filename}`;
      }

      const categoryId = await Category.create(categoryData);
      const category = await Category.findById(categoryId);

      res.status(201).json({
        success: true,
        message: 'Tạo danh mục thành công',
        data: category
      });
    } catch (error) {
      // Delete uploaded file if error occurs
      if (req.file) {
        await fs.unlink(req.file.path).catch(err => console.error('Delete file error:', err));
      }
      
      console.error('Create category error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi tạo danh mục'
      });
    }
  }

  async update(req, res) {
    try {
      const { id } = req.params;
      const categoryData = { ...req.body };

      const category = await Category.findById(id);
      if (!category) {
        // Delete uploaded file if category not found
        if (req.file) {
          await fs.unlink(req.file.path).catch(err => console.error('Delete file error:', err));
        }
        
        return res.status(404).json({
          success: false,
          message: 'Danh mục không tồn tại'
        });
      }

      // Handle image upload
      if (req.file) {
        categoryData.image = `/uploads/${req.file.filename}`;
        
        // Delete old image if exists
        if (category.image) {
          const oldImagePath = path.join(__dirname, '..', category.image);
          await fs.unlink(oldImagePath).catch(err => console.error('Delete old image error:', err));
        }
      }

      await Category.update(id, categoryData);
      const updatedCategory = await Category.findById(id);

      res.json({
        success: true,
        message: 'Cập nhật danh mục thành công',
        data: updatedCategory
      });
    } catch (error) {
      // Delete uploaded file if error occurs
      if (req.file) {
        await fs.unlink(req.file.path).catch(err => console.error('Delete file error:', err));
      }
      
      console.error('Update category error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi cập nhật danh mục'
      });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;

      const category = await Category.findById(id);
      if (!category) {
        return res.status(404).json({
          success: false,
          message: 'Danh mục không tồn tại'
        });
      }

      // Check if category has products
      const [products] = await db.execute(
        'SELECT COUNT(*) as count FROM products WHERE category_id = ?',
        [id]
      );

      if (products[0].count > 0) {
        return res.status(400).json({
          success: false,
          message: `Không thể xóa danh mục vì đang có ${products[0].count} sản phẩm`,
          productCount: products[0].count
        });
      }

      // Delete category image if exists
      if (category.image) {
        const imagePath = path.join(__dirname, '..', category.image);
        await fs.unlink(imagePath).catch(err => console.error('Delete image error:', err));
      }

      await Category.delete(id);

      res.json({
        success: true,
        message: 'Xóa danh mục thành công'
      });
    } catch (error) {
      console.error('Delete category error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi xóa danh mục'
      });
    }
  }

  async getStats(req, res) {
    try {
      const query = `
        SELECT 
          c.id as categoryId,
          c.name,
          c.image,
          COUNT(DISTINCT p.id) as productCount,
          COALESCE(SUM(DISTINCT p.stock_quantity), 0) as totalStock,
          COALESCE(SUM(oi.quantity * oi.price), 0) as totalRevenue,
          COALESCE(COUNT(DISTINCT o.id), 0) as orderCount
        FROM categories c
        LEFT JOIN products p ON c.id = p.category_id
        LEFT JOIN order_items oi ON p.id = oi.product_id
        LEFT JOIN orders o ON oi.order_id = o.id 
          AND o.deleted_at IS NULL 
          AND o.status IN ('processing', 'shipped', 'delivered')
        WHERE c.is_active = 1
        GROUP BY c.id, c.name, c.image
        ORDER BY totalRevenue DESC, productCount DESC
      `;

      const [stats] = await db.execute(query);

      // Format the response
      const formattedStats = stats.map(stat => ({
        categoryId: stat.categoryId,
        name: stat.name,
        image: stat.image,
        productCount: parseInt(stat.productCount) || 0,
        totalStock: parseInt(stat.totalStock) || 0,
        totalRevenue: parseFloat(stat.totalRevenue) || 0,
        orderCount: parseInt(stat.orderCount) || 0,
        averageRevenue: stat.productCount > 0 
          ? parseFloat(stat.totalRevenue) / parseInt(stat.productCount)
          : 0
      }));

      res.json({
        success: true,
        data: formattedStats
      });
    } catch (error) {
      console.error('Get category stats error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy thống kê danh mục'
      });
    }
  }
}

module.exports = new CategoryController();
