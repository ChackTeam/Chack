import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:chack_project/constants/icons.dart';
import 'package:chack_project/constants/text_styles.dart';
import 'package:chack_project/constants/bookcover_styles.dart';
import 'package:chack_project/constants/colors.dart';

class BookshelfBookCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String author;
  final String status;

  const BookshelfBookCard({
    super.key,
    this.imageUrl,
    this.title = '책 제목',
    this.author = '저자',
    this.status = '읽기 전',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            BookCover(
              style: BookCoverStyles.small,
              imageUrl: imageUrl,
            ),
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.chackIcon,
                    height: 10,
                    width: 10,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Flexible(
          child: Text(
            title,
            style: AppTextStyles.titleLabelStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          author,
          style: AppTextStyles.authorLabelStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 책 상태에 따라 표시할 색상을 반환
  Color _getStatusColor(String status) {
    switch (status) {
      case '읽기 전':
        return AppColors.unreadColor;
      case '읽는 중':
        return AppColors.activeReadingColor;
      case '다 읽음':
        return AppColors.pointColor;
      default:
        return Colors.grey;
    }
  }
}
