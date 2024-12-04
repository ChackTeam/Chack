import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/book_review_service.dart';

class BookReviewCard extends StatefulWidget {
  final String userId;
  final String isbn;
  final VoidCallback onReviewSaved;

  const BookReviewCard({
    Key? key,
    required this.userId,
    required this.isbn,
    required this.onReviewSaved,
  }) : super(key: key);

  @override
  _BookReviewCardState createState() => _BookReviewCardState();
}

class _BookReviewCardState extends State<BookReviewCard> {
  final BookReviewService _reviewService = BookReviewService();
  bool _isEditing = false;
  String _reviewText = '책 읽은 후 소감을 알려주세요.';
  int _rating = 0;
  bool _isLoading = true;
  String? _error;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final review = await _reviewService.getBookReview(
        userId: widget.userId,
        isbn: widget.isbn,
      );

      if (review != null && mounted) {
        setState(() {
          _reviewText = review['reviewText'] ?? '책 읽은 후 소감을 알려주세요.';
          _rating = review['reviewRating'] ?? 0;
          _controller.text = review['reviewText'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '리뷰를 불러오는데 실패했습니다.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveReview() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _reviewService.saveBookReview(
        userId: widget.userId,
        isbn: widget.isbn,
        review: _controller.text,
        rating: _rating,
      );

      if (mounted) {
        setState(() {
          _reviewText = _controller.text;
          _isEditing = false;
        });
        widget.onReviewSaved();  // 저장 완료 후 콜백 호출
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '리뷰 저장에 실패했습니다.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return Card(
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _loadReview,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      '내 별점',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: "SUITE",
                        fontSize: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: _isEditing
                              ? () {
                                  setState(() {
                                    _rating = index + 1;
                                  });
                                }
                              : null,
                          child: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: AppColors.pointColor,
                            size: 24,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_isEditing) {
                        _saveReview();  // 저장 로직 호출
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    });
                  },
                  icon: Icon(
                    _isEditing ? Icons.check : Icons.edit,
                    color: _isEditing ? Colors.teal : Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _isEditing
                ? TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '독후감을 작성하세요.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.unreadColor),
                      ),
                    ),
                  )
                : Text(
                    _reviewText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "SUITE",
                      color: AppColors.primary,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}