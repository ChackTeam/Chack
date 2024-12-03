import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/bookshelf_service.dart';
import '../../models/bookshelf_model.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BookSelectionModal extends StatefulWidget {
  final Function(Map<String, String>) onBookSelected; // 책 선택 콜백
  final VoidCallback onResetSelection; // 선택 초기화 콜백
  final String userId; // 사용자 ID
  final Map<String, String>? currentSelectedBook;

  const BookSelectionModal({
    super.key,
    required this.onBookSelected,
    required this.onResetSelection,
    required this.userId,
    this.currentSelectedBook,
  });

  @override
  State<BookSelectionModal> createState() => _BookSelectionModalState();
}

class _BookSelectionModalState extends State<BookSelectionModal> {
  final BookshelfService _bookshelfService = BookshelfService();
  String _searchQuery = ''; // 검색어 저장
  String? _selectedBookIsbn; // 선택된 책의 ISBN 저장

  @override
  void initState() {
    super.initState();
    if (widget.currentSelectedBook != null) {
      _selectedBookIsbn = widget.currentSelectedBook!['isbn'];
    }
  }

  // 책 상태에 따라 색상 반환
  Color _getStatusColor(String status) {
    switch (status) {
      case '읽기 전':
        return AppColors.unreadColor;
      case '읽는 중':
        return AppColors.activeReadingColor;
      case '다 읽음':
        return AppColors.pointColor;
      default:
        return AppColors.primary; // 기본 색상
    }
  }

  // 책 선택 처리
  void _handleBookSelection(BookshelfBook book) async {
    setState(() {
      _selectedBookIsbn = book.isbn; // 선택된 ISBN 업데이트
    });

    await _bookshelfService.updateBookStatus(
      userId: widget.userId,
      isbn: book.isbn,
      newStatus: '읽는 중',
    );

    widget.onBookSelected({
      'title': book.title,
      'author': book.author,
      'isbn': book.isbn,
      'imageUrl': book.imageUrl,
      'status': '읽는 중',
    });
  }

  // 선택 초기화 처리
  void _resetSelection() {
    setState(() {
      _selectedBookIsbn = null; // 선택 초기화
    });

    widget.onResetSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 바텀시트 스타일 정의
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(15),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // 검색 입력 필드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: ShapeDecoration(
              color: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '기록할 책을 알려주세요',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value; // 검색어 업데이트
                      });
                    },
                  ),
                ),
                Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.black.withOpacity(0.4),
                ),
                const SizedBox(width: 5)
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 책 리스트 표시
          Expanded(
            child: StreamBuilder<List<BookshelfBook>>(
              stream: _bookshelfService.fetchBookshelf(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = snapshot.data ?? [];

                // 검색어와 상태로 필터링
                final filteredBooks = books
                    .where((book) =>
                        (book.status == '읽기 전' || book.status == '읽는 중') &&
                        (book.title
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            book.author
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase())))
                    .toList();

                if (filteredBooks.isEmpty) {
                  // 필터 결과 없음
                  return const Center(
                    child: Text(
                      '선택 가능한 책이 없습니다.\n서재에서 책을 추가해주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SUITE',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                // 책 리스트 렌더링
                return ListView.builder(
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    final isSelected = _selectedBookIsbn == book.isbn;
                    final isCurrentBook = widget.currentSelectedBook != null &&
                        widget.currentSelectedBook!['isbn'] == book.isbn;

                    return GestureDetector(
                      onTap: isCurrentBook
                          ? () {
                              _resetSelection(); // 현재 선택된 책일 경우 선택 해제
                            }
                          : () {
                              setState(() {
                                _selectedBookIsbn =
                                    isSelected ? null : book.isbn;
                              });
                              if (!isSelected) {
                                _handleBookSelection(book);
                              }
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.pointColor.withOpacity(0.2)
                              : AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 독서 상태 색상 뱃지
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _getStatusColor(book.status),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  AppIcons.chackIcon,
                                  height: 8,
                                  width: 8,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // 책 이미지
                            ClipRRect(
                              child: Image.network(
                                book.imageUrl,
                                width: 40,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.book,
                                        size: 40, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // 책 제목 및 저자
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 책 제목 (15자 초과 시 말줄임표)
                                  Text(
                                    book.title.length > 15
                                        ? '${book.title.substring(0, 15)}...'
                                        : book.title,
                                    style: const TextStyle(
                                      fontFamily: 'SUITE',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // 책 저자
                                  Text(
                                    book.author,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SvgPicture.asset(
                              AppIcons.chackIcon,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                isSelected
                                    ? AppColors.pointColor
                                    : Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 5)
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
