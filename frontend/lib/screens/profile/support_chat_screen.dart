import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_colors.dart';
import 'package:intl/intl.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    // Welcome message from support
    setState(() {
      _messages.add(
        ChatMessage(
          id: '1',
          text:
              'Xin chào! Tôi là trợ lý ảo của Fashion Shop. Tôi có thể giúp gì cho bạn?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });

    // Show quick replies after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: '2',
              text: 'Bạn có thể hỏi tôi về:',
              isUser: false,
              timestamp: DateTime.now(),
              quickReplies: [
                'Trạng thái đơn hàng',
                'Chính sách đổi trả',
                'Hướng dẫn thanh toán',
                'Liên hệ với nhân viên',
              ],
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate bot response
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      final botResponse = _generateBotResponse(text.trim());
      setState(() {
        _messages.add(botResponse);
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  ChatMessage _generateBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    String responseText;
    List<String>? quickReplies;

    if (lowerMessage.contains('đơn hàng') || lowerMessage.contains('order')) {
      responseText =
          'Bạn có thể kiểm tra trạng thái đơn hàng tại mục "Đơn hàng của tôi" trong tài khoản. '
          'Nếu cần hỗ trợ thêm, vui lòng cung cấp mã đơn hàng.';
      quickReplies = ['Xem đơn hàng', 'Hủy đơn hàng', 'Liên hệ nhân viên'];
    } else if (lowerMessage.contains('đổi trả') ||
        lowerMessage.contains('return')) {
      responseText =
          'Chính sách đổi trả của chúng tôi:\n'
          '• Đổi trả trong vòng 7 ngày\n'
          '• Sản phẩm còn nguyên tem mác\n'
          '• Có hóa đơn mua hàng\n\n'
          'Bạn có muốn tạo yêu cầu đổi trả không?';
      quickReplies = ['Tạo yêu cầu đổi trả', 'Xem chi tiết chính sách'];
    } else if (lowerMessage.contains('thanh toán') ||
        lowerMessage.contains('payment')) {
      responseText =
          'Chúng tôi hỗ trợ các phương thức thanh toán:\n'
          '• COD (Thanh toán khi nhận hàng)\n'
          '• Chuyển khoản ngân hàng\n'
          '• Ví điện tử (MoMo, ZaloPay)\n'
          '• Thẻ ATM/Credit Card';
      quickReplies = ['Hướng dẫn thanh toán', 'Khác'];
    } else if (lowerMessage.contains('nhân viên') ||
        lowerMessage.contains('support')) {
      responseText =
          'Bạn muốn kết nối với nhân viên tư vấn?\n\n'
          'Hotline: 1900-1234 (8:00 - 22:00)\n'
          'Email: support@fashionshop.com\n\n'
          'Hoặc để lại số điện thoại, chúng tôi sẽ gọi lại cho bạn.';
      quickReplies = ['Gọi hotline', 'Gửi email', 'Để lại SĐT'];
    } else if (lowerMessage.contains('giao hàng') ||
        lowerMessage.contains('ship')) {
      responseText =
          'Thời gian giao hàng:\n'
          '• Nội thành: 1-2 ngày\n'
          '• Ngoại thành: 2-3 ngày\n'
          '• Tỉnh thành khác: 3-7 ngày\n\n'
          'Phí ship: MIỄN PHÍ cho đơn từ 200.000đ';
      quickReplies = ['Tra cứu đơn hàng', 'Khác'];
    } else {
      responseText =
          'Cảm ơn bạn đã liên hệ. Tôi có thể giúp bạn về:\n'
          '• Trạng thái đơn hàng\n'
          '• Chính sách đổi trả\n'
          '• Thanh toán & Vận chuyển\n'
          '• Kết nối nhân viên tư vấn';
      quickReplies = [
        'Trạng thái đơn hàng',
        'Chính sách đổi trả',
        'Thanh toán',
        'Liên hệ nhân viên',
      ];
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
      quickReplies: quickReplies,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.fullName ?? 'Khách hàng';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hỗ trợ trực tuyến', style: TextStyle(fontSize: 18)),
            Text(
              'Online • Phản hồi ngay',
              style: TextStyle(fontSize: 12, color: Colors.green.shade300),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                _showClearChatDialog();
              } else if (value == 'email') {
                _showEmailTranscriptDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Gửi bản ghi qua email'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Xóa lịch sử chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat info banner
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    userName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        'Trò chuyện được mã hóa end-to-end',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified_user,
                  color: Colors.green.shade600,
                  size: 20,
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.support_agent,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypingDot(),
                        const SizedBox(width: 4),
                        _buildTypingDot(delay: 200),
                        const SizedBox(width: 4),
                        _buildTypingDot(delay: 400),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _sendMessage(_messageController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser) ...[
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.support_agent,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 20),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 16),
                ),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: message.isUser ? 0 : 40,
              right: message.isUser ? 40 : 0,
              top: 4,
            ),
            child: Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),

          // Quick replies
          if (message.quickReplies != null && message.quickReplies!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 40),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.quickReplies!.map((reply) {
                  return InkWell(
                    onTap: () => _sendMessage(reply),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Text(
                        reply,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingDot({int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade600.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        // Loop animation
        if (mounted && _isTyping) {
          setState(() {});
        }
      },
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử chat'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử trò chuyện?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
              });
              _initializeChat();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showEmailTranscriptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi bản ghi chat'),
        content: const Text(
          'Bản ghi cuộc trò chuyện sẽ được gửi đến email đã đăng ký của bạn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã gửi bản ghi chat đến email của bạn'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? quickReplies;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.quickReplies,
  });
}
