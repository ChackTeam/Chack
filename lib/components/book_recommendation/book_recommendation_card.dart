import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/constants/text_styles.dart';
import 'package:chack_project/constants/icons.dart';

import 'package:chack_project/screens/book_detail_screen.dart';

class BookRecommendationCard extends StatelessWidget {
  final String userId; // 추가
  final String isbn; // 추가
  final String title;
  final String author;
  final String publisher;
  final String distance;
  final String availability;
  final String imageUrl;
  final String description;

  const BookRecommendationCard({
    super.key,
    required this.userId, // 추가
    required this.isbn, // 추가
    required this.title,
    required this.author,
    required this.publisher,
    required this.distance,
    required this.availability,
    required this.imageUrl,
    this.description = '이 책에 대한 설명이 없습니다.',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(
              userId: userId, // userId 전달
              isbn: isbn, // isbn 전달
              title: title,
              author: author,
              publisher: publisher,
              image: imageUrl,
              description: description,
            ),
          ),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.pointColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // 채크의 추천 배지
            Positioned(
              left: 20,
              top: 18,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.pointColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppIcons.chackIcon,
                      height: 10,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '채크의 추천',
                      style: AppTextStyles.labelStyle,
                    ),
                  ],
                ),
              ),
            ),
            // 도서 정보
            Positioned(
              left: 20,
              top: 54,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 도서 제목
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    child: Text(
                      title,
                      style: AppTextStyles.titleLabelStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // 저자 및 출판사
                  Text(
                    '$author / $publisher',
                    style: AppTextStyles.authorLabelStyle,
                  ),
                  const SizedBox(height: 7),
                  // 가까운 도서관 및 대출 가능 여부
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        distance,
                        style: AppTextStyles.libraryLabelStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        availability,
                        style: AppTextStyles.libraryLabelStyle.copyWith(
                          color: availability == '대출 가능'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 도서 이미지
            Positioned(
              right: 22,
              bottom: 0,
              child: SizedBox(
                width: 90,
                height: 126,
                child: ClipRRect(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: 90,
                    height: 126,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 90,
                      height: 126,
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
