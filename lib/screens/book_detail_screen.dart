import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chack_project/services/bookshelf_service.dart';
import '../services/recommended_books_service.dart';
import '../services/book_cache_service.dart';
import '../services/library_info_service.dart';
import 'package:chack_project/screens/book_review_screen.dart';
import '../../constants/icons.dart';
import '../../constants/colors.dart';
import '../components/custom_alert_banner.dart';
import 'dart:ui';

class BookDetailScreen extends StatefulWidget {
  final String userId;
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final String image;
  final String description;

  const BookDetailScreen({
    super.key,
    required this.userId,
    required this.isbn,
    required this.title,
    required this.author,
    required this.publisher,
    required this.image,
    required this.description,
  });

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookshelfService _bookshelfService = BookshelfService();
  bool _isInShelf = false;
  bool _isLoading = true;

  // LibraryInfoProvider 관련 필드 추가
  final LibraryInfoProvider _libraryInfoProvider = LibraryInfoProvider(
    recommendedBooksService: RecommendedBooksService(
      cacheService: BookCacheService(),
    ),
  );
  String _libraryName = '도서관 정보를 불러오는 중입니다...';
  String _libraryDistance = '';
  String _loanStatus = '';

  @override
  void initState() {
    super.initState();
    _checkBookInShelf();
    _initializeLibraryInfo(); // LibraryInfoProvider 초기화 호출
  }

  Future<void> _checkBookInShelf() async {
    final isInShelf = await _bookshelfService.isBookInShelf(
      userId: widget.userId,
      isbn: widget.isbn,
    );
    if (mounted) {
      setState(() {
        _isInShelf = isInShelf;
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeLibraryInfo() async {
    await _libraryInfoProvider.setupLocationSubscription(
      isbn: widget.isbn,
      onLibraryNameUpdate: (name) {
        if (mounted) {
          setState(() {
            _libraryName = name;
          });
        }
      },
      onDistanceUpdate: (distance) {
        if (mounted) {
          setState(() {
            _libraryDistance = distance;
          });
        }
      },
      onLoanStatusUpdate: (status) {
        if (mounted) {
          setState(() {
            _loanStatus = status;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _libraryName = error;
            _libraryDistance = '';
            _loanStatus = '';
          });
        }
      },
    );
  }

  Future<void> _addBookToShelf() async {
    setState(() {
      _isLoading = true;
    });

    await _bookshelfService.addBookToShelf(
      userId: widget.userId,
      isbn: widget.isbn,
      title: widget.title,
      author: widget.author,
      publisher: widget.publisher,
      image: widget.image,
    );

    setState(() {
      _isInShelf = true;
      _isLoading = false;
    });

    if (mounted) {
      CustomAlertBanner.show(
        context,
        message: '책이 서재에 추가되었습니다.',
        iconColor: AppColors.pointColor,
      );
    }
  }

  Future<void> _removeBookFromShelf() async {
    setState(() {
      _isLoading = true;
    });

    await _bookshelfService.removeBookFromShelf(
      userId: widget.userId,
      isbn: widget.isbn,
    );

    setState(() {
      _isInShelf = false;
      _isLoading = false;
    });

    if (mounted) {
      CustomAlertBanner.show(
        context,
        message: '책이 서재에서 제거되었습니다.',
        iconColor: AppColors.pointColor,
      );
    }
  }

  Future<void> _navigateToReviewScreen() async {
    if (!_isInShelf) {
      CustomAlertBanner.show(
        context,
        message: '먼저 책을 서재에 추가해주세요.',
        iconColor: AppColors.errorColor,
      );
      return;
    }

    try {
      final bookDoc = await FirebaseFirestore.instance
          .collection('userShelf')
          .doc(widget.userId)
          .collection('books')
          .doc(widget.isbn)
          .get();

      if (!bookDoc.exists) {
        if (mounted) {
          CustomAlertBanner.show(
            context,
            message: '서재에서 책을 찾을 수 없습니다.',
            iconColor: AppColors.errorColor,
          );
        }
        return;
      }

      final bookData = bookDoc.data()!;
      final int readTime = bookData['readTime'] ?? 0;
      if (readTime == 0) {
        if (mounted) {
          CustomAlertBanner.show(
            context,
            message: '아직 독서 중의 도서가 아닙니다.',
            iconColor: AppColors.errorColor,
          );
        }
        return;
      }
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewWritingScreen(
              title: widget.title,
              author: widget.author,
              publisher: widget.publisher,
              image: widget.image,
              userId: widget.userId,
              isbn: widget.isbn,
              startedAt: (bookData['startedAt'] as Timestamp).toDate(),
              finishedAt: bookData['finishedAt'] != null
                  ? (bookData['finishedAt'] as Timestamp).toDate()
                  : null,
              readTime: bookData['readTime'] ?? 0,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomAlertBanner.show(
          context,
          message: '책 정보를 불러오는 데에 실패했습니다.',
          iconColor: AppColors.errorColor, // 에러 색상 설정
        );
      }
    }
  }

  @override
  void dispose() {
    _libraryInfoProvider.dispose(); // LibraryInfoProvider 리소스 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          // 고정된 SliverAppBar: 책 정보, 썸네일 배경, 독서 상태 표시
          SliverAppBar(
            expandedHeight: 450,
            pinned: false,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Row(
              children: [
                Text(
                  '책 정보',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "SUITE",
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    ),
                  ),
                  // 블러 효과
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                  // 도서 썸네일 및 상태 표시
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              child: Image.network(
                                widget.image,
                                width: 170,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.book,
                                  size: 150,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          if (_isInShelf)
                            Transform.translate(
                              offset: const Offset(0, -70),
                              child: SvgPicture.asset(
                                AppIcons.bookmarkIcon,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.pointColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 스크롤 가능한 콘텐츠: 책 정보, 도서관 상태, 책 소개
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                    color: Colors.black.withOpacity(0.05),
                    width: 10,
                  ))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 책 제목 및 저자 정보
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontFamily: "SUITE",
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${widget.author} / ${widget.publisher}',
                          style: TextStyle(
                            fontFamily: "SUITE",
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 도서관 보유 정보
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '근처 도서관 보유 현황',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Text(
                                      _libraryName,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      '($_libraryDistance)',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.4)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: _loanStatus == '대출 가능'
                                      ? AppColors.pointColor.withOpacity(0.5)
                                      : AppColors.errorColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _loanStatus == '대출 가능'
                                          ? AppColors.pointColor
                                              .withOpacity(0.7)
                                          : AppColors.errorColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    _loanStatus,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _loanStatus == '대출 가능'
                                          ? AppColors.pointColor
                                          : AppColors.errorColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 책 소개
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '책 소개',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: Colors.black.withOpacity(0.2),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '네이버 도서 API에서 제공하는 정보입니다.',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontFamily: "SUITE",
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // 고정된 하단 버튼
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(left: 25, right: 25, bottom: 30, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _isInShelf ? _removeBookFromShelf : _addBookToShelf,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                elevation: 0,
                minimumSize: const Size(160, 50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: SvgPicture.asset(
                _isInShelf ? AppIcons.bookDeleteIcon : AppIcons.bookAddIcon,
              ),
              label: Text(
                _isInShelf ? '책장에서 빼기' : '책장에 추가하기',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SUITE',
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _navigateToReviewScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(170, 50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: SvgPicture.asset(AppIcons.bookReportIcon),
              label: const Text(
                '독후감 작성하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SUITE',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
