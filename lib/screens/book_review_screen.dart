import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chack_project/constants/icons.dart';
import 'package:chack_project/components/book_review/book_readingtime_card.dart';
import 'package:chack_project/components/book_review/book_review_card.dart';

class ReviewWritingScreen extends StatefulWidget {
  // StatelessWidget에서 StatefulWidget으로 변경
  final String title;
  final String author;
  final String publisher;
  final String image;
  final String userId;
  final String isbn;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int readTime;

  const ReviewWritingScreen({
    super.key,
    required this.title,
    required this.author,
    required this.publisher,
    required this.image,
    required this.userId,
    required this.isbn,
    required this.startedAt,
    this.finishedAt,
    required this.readTime,
  });

  @override
  ReviewWritingScreenState createState() => ReviewWritingScreenState();
}

class ReviewWritingScreenState extends State<ReviewWritingScreen> {
  DateTime? _finishedAt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _finishedAt = widget.finishedAt;
    _loadBookData();
  }

  Future<void> _loadBookData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final bookDoc = await FirebaseFirestore.instance
          .collection('userShelf')
          .doc(widget.userId)
          .collection('books')
          .doc(widget.isbn)
          .get();

      if (bookDoc.exists && mounted) {
        setState(() {
          _finishedAt = bookDoc.data()?['finishedAt'] != null
              ? (bookDoc.data()!['finishedAt'] as Timestamp).toDate()
              : null;
        });
      }
    } catch (e) {
      // 에러 처리
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 리뷰 저장 완료 후 호출될 콜백
  void _onReviewSaved() {
    _loadBookData(); // 데이터 리로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          // 고정된 헤더와 이미지
          SliverAppBar(
            expandedHeight: 450,
            pinned: false, // 스크롤 시 AppBar 고정
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              children: [
                const SizedBox(width: 10),
                SvgPicture.asset(
                  AppIcons.chackIcon,
                  width: 30,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.author} / ${widget.publisher}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // 배경 이미지
                  Positioned.fill(
                    child: Image.network(
                      widget.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.book,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // 검정색 반투명 상자
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                  // 독서 정보 카드
                  Positioned(
                    bottom: 40,
                    left: 10,
                    right: 10,
                    child: BookReadingtimeCard(
                      startedAt: widget.startedAt,
                      finishedAt: _finishedAt,
                      readTime: widget.readTime,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 스크롤 가능한 콘텐츠
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 리뷰 카드 - 콜백 추가
                BookReviewCard(
                  userId: widget.userId,
                  isbn: widget.isbn,
                  onReviewSaved: _onReviewSaved,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
