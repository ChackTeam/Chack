import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/constants/icons.dart';

import 'package:chack_project/services/book_review_service.dart';

class BookReviewCard extends StatefulWidget {
  final String userId;
  final String isbn;
  final VoidCallback onReviewSaved;

  const BookReviewCard({
    super.key,
    required this.userId,
    required this.isbn,
    required this.onReviewSaved,
  });

  @override
  BookReviewCardState createState() => BookReviewCardState();
}

class BookReviewCardState extends State<BookReviewCard> {
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
        widget.onReviewSaved(); // 저장 완료 후 콜백 호출
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.pointColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppIcons.chackIcon,
                  width: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.pointColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '책을 읽고 느낀 점을 자유롭게 작성해 보세요.',
                  style: TextStyle(
                    color: AppColors.pointColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '별점',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_isEditing) {
                            _saveReview(); // 저장 로직 호출
                          } else {
                            setState(() {
                              _isEditing = true;
                            });
                          }
                        });
                      },
                      icon: Icon(
                        _isEditing ? Icons.check : Icons.edit,
                        color: _isEditing
                            ? AppColors.pointColor
                            : Colors.black.withOpacity(0.2),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) {
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: _isEditing
                                    ? () {
                                        setState(() {
                                          _rating = index + 1;
                                        });
                                      }
                                    : null,
                                child: index < _rating
                                    ? SvgPicture.asset(
                                        AppIcons.starIcon,
                                        width: 18,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.pointColor,
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        AppIcons.starIcon,
                                        width: 18,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.1),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                              ),
                              if (index < 4)
                                const SizedBox(width: 6), // 별 사이의 간격
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          '$_rating점', // 현재 별점과 최대 별점 표시
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  color: Colors.black.withOpacity(0.1), // 선 색상
                  thickness: 1, // 선 두께
                  height: 50, // 선 위아래 공간
                ),
                const Text(
                  '독후감',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                _isEditing
                    ? TextField(
                        controller: _controller,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: '  독후감을 작성하세요.',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black.withOpacity(0.3),
                          ),
                          fillColor: Colors.transparent,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.1)),
                          ),
                        ),
                      )
                    : Text(
                        _reviewText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary.withOpacity(0.6),
                        ),
                      ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
