const Wishlist = require('../models/Wishlist');

class WishlistController {
  async getAll(req, res) {
    try {
      const items = await Wishlist.findByUserId(req.user.id);
      const total = await Wishlist.count(req.user.id);

      res.json({
        success: true,
        data: {
          items,
          total
        }
      });
    } catch (error) {
      console.error('Get wishlist error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy danh sách yêu thích'
      });
    }
  }

  async add(req, res) {
    try {
      const { product_id } = req.body;

      if (!product_id) {
        return res.status(400).json({
          success: false,
          message: 'Thiếu thông tin sản phẩm'
        });
      }

      // Check if product exists
      const Product = require('../models/Product');
      const product = await Product.findById(product_id);
      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Sản phẩm không tồn tại'
        });
      }

      const itemId = await Wishlist.add(req.user.id, product_id);

      res.json({
        success: true,
        message: 'Đã thêm vào danh sách yêu thích',
        data: { id: itemId }
      });
    } catch (error) {
      console.error('Add to wishlist error:', error);
      
      // Handle duplicate entry error
      if (error.message && error.message.includes('đã có trong danh sách')) {
        return res.status(400).json({
          success: false,
          message: error.message
        });
      }
      
      res.status(500).json({
        success: false,
        message: 'Lỗi thêm vào danh sách yêu thích'
      });
    }
  }

  async remove(req, res) {
    try {
      const { product_id } = req.params;

      const success = await Wishlist.remove(req.user.id, product_id);

      if (!success) {
        return res.status(404).json({
          success: false,
          message: 'Sản phẩm không có trong danh sách yêu thích'
        });
      }

      res.json({
        success: true,
        message: 'Đã xóa khỏi danh sách yêu thích'
      });
    } catch (error) {
      console.error('Remove from wishlist error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi xóa khỏi danh sách yêu thích'
      });
    }
  }

  async check(req, res) {
    try {
      const { product_id } = req.params;

      const isInWishlist = await Wishlist.isInWishlist(req.user.id, product_id);

      res.json({
        success: true,
        data: { isInWishlist }
      });
    } catch (error) {
      console.error('Check wishlist error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi kiểm tra danh sách yêu thích'
      });
    }
  }

  async clear(req, res) {
    try {
      const count = await Wishlist.clearAll(req.user.id);

      res.json({
        success: true,
        message: `Đã xóa ${count} sản phẩm khỏi danh sách yêu thích`
      });
    } catch (error) {
      console.error('Clear wishlist error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi xóa danh sách yêu thích'
      });
    }
  }
}

module.exports = new WishlistController();
