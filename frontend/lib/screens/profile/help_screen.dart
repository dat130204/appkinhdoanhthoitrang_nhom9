import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trợ giúp')),
      body: ListView(
        children: [
          // Contact Section
          _buildSection(
            icon: Icons.contact_support,
            title: 'Liên hệ hỗ trợ',
            children: [
              _buildListTile(
                icon: Icons.phone,
                title: 'Hotline',
                subtitle: '1900-1234 (8:00 - 22:00)',
                onTap: () => _makePhoneCall('19001234'),
              ),
              _buildListTile(
                icon: Icons.email,
                title: 'Email',
                subtitle: 'support@fashionshop.com',
                onTap: () => _sendEmail('support@fashionshop.com'),
              ),
              _buildListTile(
                icon: Icons.chat,
                title: 'Chat trực tuyến',
                subtitle: 'Nhấn để bắt đầu chat',
                onTap: () {
                  Navigator.pushNamed(context, '/support-chat');
                },
              ),
            ],
          ),

          // FAQ Section
          _buildSection(
            icon: Icons.help_outline,
            title: 'Câu hỏi thường gặp',
            children: [
              _buildExpansionTile(
                question: 'Làm thế nào để đặt hàng?',
                answer:
                    'Bạn có thể đặt hàng bằng cách:\n'
                    '1. Chọn sản phẩm yêu thích\n'
                    '2. Thêm vào giỏ hàng\n'
                    '3. Tiến hành thanh toán\n'
                    '4. Nhập thông tin giao hàng\n'
                    '5. Xác nhận đơn hàng',
              ),
              _buildExpansionTile(
                question: 'Chính sách đổi trả như thế nào?',
                answer:
                    'Sản phẩm được đổi trả trong vòng 7 ngày kể từ ngày nhận hàng:\n'
                    '- Sản phẩm còn nguyên tem, mác\n'
                    '- Chưa qua sử dụng\n'
                    '- Có hóa đơn mua hàng',
              ),
              _buildExpansionTile(
                question: 'Thời gian giao hàng?',
                answer:
                    'Thời gian giao hàng phụ thuộc vào khu vực:\n'
                    '- Nội thành: 1-2 ngày\n'
                    '- Ngoại thành: 2-3 ngày\n'
                    '- Tỉnh thành khác: 3-7 ngày',
              ),
              _buildExpansionTile(
                question: 'Có những phương thức thanh toán nào?',
                answer:
                    'Chúng tôi hỗ trợ các phương thức:\n'
                    '- COD (Thanh toán khi nhận hàng)\n'
                    '- Chuyển khoản ngân hàng\n'
                    '- Ví điện tử (MoMo, ZaloPay)\n'
                    '- Thẻ ATM/Credit Card',
              ),
              _buildExpansionTile(
                question: 'Làm thế nào để theo dõi đơn hàng?',
                answer:
                    'Bạn có thể theo dõi đơn hàng tại:\n'
                    '1. Vào mục "Đơn hàng của tôi"\n'
                    '2. Chọn đơn hàng cần xem\n'
                    '3. Xem chi tiết trạng thái đơn hàng',
              ),
            ],
          ),

          // Policies Section
          _buildSection(
            icon: Icons.policy,
            title: 'Chính sách',
            children: [
              _buildListTile(
                icon: Icons.privacy_tip,
                title: 'Chính sách bảo mật',
                onTap: () {
                  _showPolicyDialog(
                    context,
                    'Chính sách bảo mật',
                    'Fashion Shop cam kết bảo vệ thông tin cá nhân của khách hàng...',
                  );
                },
              ),
              _buildListTile(
                icon: Icons.assignment,
                title: 'Điều khoản sử dụng',
                onTap: () {
                  _showPolicyDialog(
                    context,
                    'Điều khoản sử dụng',
                    'Khi sử dụng dịch vụ của Fashion Shop, bạn đồng ý với các điều khoản...',
                  );
                },
              ),
              _buildListTile(
                icon: Icons.local_shipping,
                title: 'Chính sách vận chuyển',
                onTap: () {
                  _showPolicyDialog(
                    context,
                    'Chính sách vận chuyển',
                    'Fashion Shop hỗ trợ vận chuyển toàn quốc với nhiều hình thức...',
                  );
                },
              ),
            ],
          ),

          // About Section
          _buildSection(
            icon: Icons.info,
            title: 'Về Fashion Shop',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.store,
                          size: 80,
                          color: AppColors.primary,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fashion Shop',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Phiên bản 1.0.0',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ứng dụng mua sắm thời trang trực tuyến',
                      style: TextStyle(color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey[100],
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        ...children,
        const Divider(height: 1, thickness: 8, color: Colors.grey),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildExpansionTile({
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
        ),
      ],
    );
  }

  static void _showPolicyDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
