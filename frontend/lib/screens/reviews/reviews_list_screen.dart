import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/review_card.dart';
import '../../widgets/review_statistics_widget.dart';
import 'review_form_screen.dart';

class ReviewsListScreen extends StatefulWidget {
  final int productId;
  final String productName;
  final String? productImage;

  const ReviewsListScreen({
    Key? key,
    required this.productId,
    required this.productName,
    this.productImage,
  }) : super(key: key);

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  final _reviewService = ReviewService();
  final _scrollController = ScrollController();

  List<Review> _reviews = [];
  ReviewStatistics? _statistics;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String _sortBy = 'recent';

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMore();
      }
    }
  }

  Future<void> _loadReviews({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _reviews = [];
        _isLoading = true;
      });
    }

    try {
      final response = await _reviewService.getProductReviews(
        productId: widget.productId,
        page: _currentPage,
        sortBy: _sortBy,
      );

      if (mounted) {
        setState(() {
          if (refresh) {
            _reviews = response.reviews;
          } else {
            _reviews.addAll(response.reviews);
          }
          _statistics = response.statistics;
          _totalPages = response.totalPages;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    await _loadReviews();
  }

  Future<void> _toggleHelpful(Review review) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập')));
      return;
    }

    try {
      final result = await _reviewService.toggleHelpful(review.id);
      final newHelpfulStatus = result['is_helpful'] ?? false;
      final newHelpfulCount = result['helpful_count'] ?? review.helpfulCount;

      setState(() {
        final index = _reviews.indexWhere((r) => r.id == review.id);
        if (index != -1) {
          _reviews[index] = _reviews[index].copyWith(
            isHelpfulByCurrentUser: newHelpfulStatus,
            helpfulCount: newHelpfulCount,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa đánh giá này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _reviewService.deleteReview(review.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa đánh giá'),
            backgroundColor: Colors.green,
          ),
        );
        _loadReviews(refresh: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editReview(Review review) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewFormScreen(
          productId: widget.productId,
          productName: widget.productName,
          productImage: widget.productImage,
          existingReview: review,
        ),
      ),
    );

    if (result == true) {
      _loadReviews(refresh: true);
    }
  }

  void _writeReview() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để viết đánh giá')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewFormScreen(
          productId: widget.productId,
          productName: widget.productName,
          productImage: widget.productImage,
        ),
      ),
    );

    if (result == true) {
      _loadReviews(refresh: true);
    }
  }

  void _changeSortOrder() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sắp xếp theo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...[
              {'value': 'recent', 'label': 'Mới nhất'},
              {'value': 'helpful', 'label': 'Hữu ích nhất'},
              {'value': 'rating_high', 'label': 'Đánh giá cao nhất'},
              {'value': 'rating_low', 'label': 'Đánh giá thấp nhất'},
            ].map((option) {
              return ListTile(
                title: Text(option['label']!),
                trailing: _sortBy == option['value']
                    ? const Icon(Icons.check, color: Color(0xFFFF6B35))
                    : null,
                onTap: () {
                  setState(() => _sortBy = option['value']!);
                  Navigator.pop(context);
                  _loadReviews(refresh: true);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.id;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Đánh giá sản phẩm'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _changeSortOrder,
            tooltip: 'Sắp xếp',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadReviews(refresh: true),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Statistics
                  if (_statistics != null)
                    ReviewStatisticsWidget(statistics: _statistics!),

                  const SizedBox(height: 20),

                  // Reviews list header
                  Row(
                    children: [
                      Text(
                        'Tất cả đánh giá (${_statistics?.totalReviews ?? 0})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Reviews
                  if (_reviews.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có đánh giá nào',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._reviews.map((review) {
                      final isOwn =
                          currentUserId != null &&
                          review.userId == currentUserId;
                      return ReviewCard(
                        review: review,
                        isOwnReview: isOwn,
                        onHelpful: () => _toggleHelpful(review),
                        onEdit: isOwn ? () => _editReview(review) : null,
                        onDelete: isOwn ? () => _deleteReview(review) : null,
                      );
                    }).toList(),

                  // Loading more indicator
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _writeReview,
        backgroundColor: const Color(0xFFFF6B35),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Viết đánh giá',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
