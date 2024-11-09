import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/icons.dart';
import '../constants/text_styles.dart';
import '../constants/bookcover_styles.dart';

class BookshelfBookCard extends StatelessWidget {
  const BookshelfBookCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const BookCover(style: BookCoverStyles.small),
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.grey,
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
        const Flexible(
          child: Text(
            '책 제목',
            style: AppTextStyles.titleLabelStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '저자',
          style: AppTextStyles.authorLabelStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
