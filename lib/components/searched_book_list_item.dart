import 'package:flutter/material.dart';

import 'package:chack_project/constants/bookcover_styles.dart';
import 'package:chack_project/screens/book_detail_screen.dart';

class SearchedBookListItem extends StatelessWidget {
  final String userId;
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final String image;
  final String description;

  const SearchedBookListItem({
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 표지
            BookCover(
              style: BookCoverStyles.medium,
              imageUrl: image,
            ),
            const SizedBox(width: 16),

            // 책 제목, 저자 / 출판사, 버튼
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SUITE',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$author / $publisher',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black.withOpacity(0.6),
                      fontFamily: 'SUITE',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(
                              userId: userId,
                              isbn: isbn,
                              title: title,
                              author: author,
                              publisher: publisher,
                              image: image,
                              description: description,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                      ),
                      child: const Text(
                        '책 정보 보기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SUITE',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}