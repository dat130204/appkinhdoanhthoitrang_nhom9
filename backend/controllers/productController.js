const Product = require('../models/Product');
const ProductImage = require('../models/ProductImage');

class ProductController {
  async getAll(req, res) {
    try {
      const {
        category_id,
        search,
        min_price,
        max_price,
        brand,
        is_featured,
        sort_by,
        sort_order,
        page = 1,
        limit = 20
      } = req.query;

      const filters = {
        category_id,
        search,
        min_price,
        max_price,
        brand,
        is_featured,
        sort_by,
        sort_order,
        limit: parseInt(limit),
        offset: (parseInt(page) - 1) * parseInt(limit)
      };

      const products = await Product.findAll(filters);
      const total = await Product.count(filters);

      res.json({
        success: true,
        data: {
          products,
          pagination: {
            current_page: parseInt(page),
            per_page: parseInt(limit),
            total_items: total,
            total_pages: Math.ceil(total / parseInt(limit))
          }
        }
      });
    } catch (error) {
      console.error('Get products error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy danh sách sản phẩm'
      });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const product = await Product.findById(id);

      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Sản phẩm không tồn tại'
        });
      }

      // Get product images
      const ProductImage = require('../models/ProductImage');
      const images = await ProductImage.findByProductId(id);

      // Get product variants
      const ProductVariant = require('../models/ProductVariant');
      const variants = await ProductVariant.findByProductId(id);

      // Get related products
      const relatedProducts = await Product.getRelatedProducts(
        product.id,
        product.category_id,
        4
      );

      res.json({
        success: true,
        data: {
          ...product,
          images: images || [],
          variants: variants || [],
          related_products: relatedProducts
        }
      });
    } catch (error) {
      console.error('Get product error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy thông tin sản phẩm'
      });
    }
  }

  async create(req, res) {
    try {
      const productData = req.body;
      const productId = await Product.create(productData);

      // Handle images if provided
      if (req.body.images && Array.isArray(req.body.images)) {
        for (let i = 0; i < req.body.images.length; i++) {
          await ProductImage.create({
            product_id: productId,
            image_url: req.body.images[i],
            is_primary: i === 0,
            display_order: i
          });
        }
      }

      const product = await Product.findById(productId);

      res.status(201).json({
        success: true,
        message: 'Tạo sản phẩm thành công',
        data: product
      });
    } catch (error) {
      console.error('Create product error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi tạo sản phẩm'
      });
    }
  }

  async update(req, res) {
    try {
      const { id } = req.params;
      const productData = req.body;

      const product = await Product.findById(id);
      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Sản phẩm không tồn tại'
        });
      }

      // Remove images from product data
      const { images, ...updateData } = productData;

      await Product.update(id, updateData);

      // Handle images if provided
      if (images && Array.isArray(images)) {
        await ProductImage.deleteByProductId(id);
        for (let i = 0; i < images.length; i++) {
          await ProductImage.create({
            product_id: id,
            image_url: images[i],
            is_primary: i === 0,
            display_order: i
          });
        }
      }

      const updatedProduct = await Product.findById(id);

      res.json({
        success: true,
        message: 'Cập nhật sản phẩm thành công',
        data: updatedProduct
      });
    } catch (error) {
      console.error('Update product error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi cập nhật sản phẩm'
      });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;

      const product = await Product.findById(id);
      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Sản phẩm không tồn tại'
        });
      }

      await Product.delete(id);

      res.json({
        success: true,
        message: 'Xóa sản phẩm thành công'
      });
    } catch (error) {
      console.error('Delete product error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi xóa sản phẩm'
      });
    }
  }

  async getBrands(req, res) {
    try {
      const brands = await Product.getBrands();
      res.json({
        success: true,
        data: brands
      });
    } catch (error) {
      console.error('Get brands error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy danh sách thương hiệu'
      });
    }
  }

  async getFeatured(req, res) {
    try {
      const { limit = 8 } = req.query;
      const products = await Product.findAll({
        is_featured: true,
        limit: parseInt(limit),
        offset: 0
      });

      res.json({
        success: true,
        data: products
      });
    } catch (error) {
      console.error('Get featured products error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy sản phẩm nổi bật'
      });
    }
  }

  async uploadImages(req, res) {
    try {
      if (!req.files || req.files.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Không có file nào được upload'
        });
      }

      // Generate image URLs from uploaded files
      const baseUrl = `${req.protocol}://${req.get('host')}`;
      const imageUrls = req.files.map(file => {
        // Path format: /uploads/images/filename.jpg
        const relativePath = file.path.replace(/\\/g, '/').split('uploads/')[1];
        return `${baseUrl}/uploads/${relativePath}`;
      });

      res.status(200).json({
        success: true,
        message: 'Upload ảnh thành công',
        data: {
          images: imageUrls
        }
      });
    } catch (error) {
      console.error('Upload images error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi upload ảnh'
      });
    }
  }

  // GET /api/products/admin/export?format=csv
  async exportProducts(req, res) {
    try {
      const format = req.query.format || 'csv';

      if (format !== 'csv') {
        return res.status(400).json({
          success: false,
          message: 'Hiện tại chỉ hỗ trợ format CSV'
        });
      }

      // Get all products with filters (without pagination)
      const {
        category_id,
        search,
        brand,
        is_featured,
        is_active
      } = req.query;

      const filters = {
        category_id,
        search,
        brand,
        is_featured,
        is_active,
        limit: 999999, // Get all
        offset: 0
      };

      const products = await Product.findAll(filters);

      // Generate CSV
      const csvRows = [];
      
      // Header
      csvRows.push([
        'ID',
        'Tên sản phẩm',
        'SKU',
        'Danh mục',
        'Giá gốc',
        'Giá khuyến mãi',
        'Tồn kho',
        'Thương hiệu',
        'Nổi bật',
        'Trạng thái',
        'Ngày tạo'
      ].join(','));

      // Data rows
      products.forEach(product => {
        const row = [
          product.id,
          `"${product.name.replace(/"/g, '""')}"`, // Escape quotes
          product.sku || '',
          `"${product.category_name || ''}"`,
          product.regular_price || 0,
          product.sale_price || '',
          product.stock_quantity || 0,
          `"${product.brand || ''}"`,
          product.is_featured ? 'Có' : 'Không',
          product.is_active ? 'Hoạt động' : 'Tạm ẩn',
          new Date(product.created_at).toLocaleString('vi-VN')
        ];
        csvRows.push(row.join(','));
      });

      const csvContent = csvRows.join('\n');

      // Set headers for file download
      res.setHeader('Content-Type', 'text/csv; charset=utf-8');
      res.setHeader('Content-Disposition', `attachment; filename="products_${Date.now()}.csv"`);
      
      // Add BOM for UTF-8 to support Vietnamese characters in Excel
      res.write('\uFEFF');
      res.write(csvContent);
      res.end();
    } catch (error) {
      console.error('Error in exportProducts:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi xuất danh sách sản phẩm',
        error: error.message
      });
    }
  }
}

module.exports = new ProductController();
