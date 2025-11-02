const Cart = require('../models/Cart');
const Product = require('../models/Product');

class CartController {
  async getCart(req, res) {
    try {
      const cart = await Cart.findOrCreateByUserId(req.user.id);
      const items = await Cart.getItems(cart.id);
      const summary = await Cart.getCartSummary(cart.id);

      res.json({
        success: true,
        data: {
          cart_id: cart.id,
          items,
          summary
        }
      });
    } catch (error) {
      console.error('Get cart error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi lấy giỏ hàng'
      });
    }
  }

  async addItem(req, res) {
    try {
      const { product_id, variant_id, quantity } = req.body;

      // Validate product
      const product = await Product.findById(product_id);
      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Sản phẩm không tồn tại'
        });
      }

      if (!product.is_active) {
        return res.status(400).json({
          success: false,
          message: 'Sản phẩm không còn kinh doanh'
        });
      }

      if (product.stock_quantity < quantity) {
        return res.status(400).json({
          success: false,
          message: 'Số lượng sản phẩm không đủ'
        });
      }

      // Get or create cart
      const cart = await Cart.findOrCreateByUserId(req.user.id);

      // Calculate price
      const price = product.sale_price || product.price;

      // Add item to cart
      await Cart.addItem(cart.id, {
        product_id,
        variant_id,
        quantity,
        price
      });

      // Get updated cart
      const items = await Cart.getItems(cart.id);
      const summary = await Cart.getCartSummary(cart.id);

      res.json({
        success: true,
        message: 'Đã thêm sản phẩm vào giỏ hàng',
        data: {
          cart_id: cart.id,
          items,
          summary
        }
      });
    } catch (error) {
      console.error('Add to cart error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi thêm sản phẩm vào giỏ hàng'
      });
    }
  }

  async updateItem(req, res) {
    try {
      const { id } = req.params;
      const { quantity } = req.body;

      if (quantity <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Số lượng phải lớn hơn 0'
        });
      }

      const cart = await Cart.findOrCreateByUserId(req.user.id);
      await Cart.updateItemQuantity(id, quantity);

      const items = await Cart.getItems(cart.id);
      const summary = await Cart.getCartSummary(cart.id);

      res.json({
        success: true,
        message: 'Cập nhật giỏ hàng thành công',
        data: {
          cart_id: cart.id,
          items,
          summary
        }
      });
    } catch (error) {
      console.error('Update cart item error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi cập nhật giỏ hàng'
      });
    }
  }

  async removeItem(req, res) {
    try {
      const { id } = req.params;

      await Cart.removeItem(id);

      const cart = await Cart.findOrCreateByUserId(req.user.id);
      const items = await Cart.getItems(cart.id);
      const summary = await Cart.getCartSummary(cart.id);

      res.json({
        success: true,
        message: 'Đã xóa sản phẩm khỏi giỏ hàng',
        data: {
          cart_id: cart.id,
          items,
          summary
        }
      });
    } catch (error) {
      console.error('Remove cart item error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi xóa sản phẩm khỏi giỏ hàng'
      });
    }
  }

  async clearCart(req, res) {
    try {
      const cart = await Cart.findOrCreateByUserId(req.user.id);
      await Cart.clearCart(cart.id);

      res.json({
        success: true,
        message: 'Đã xóa toàn bộ giỏ hàng',
        data: {
          cart_id: cart.id,
          items: [],
          summary: {
            item_count: 0,
            total_items: 0,
            subtotal: 0
          }
        }
      });
    } catch (error) {
      console.error('Clear cart error:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi xóa giỏ hàng'
      });
    }
  }
}

module.exports = new CartController();
