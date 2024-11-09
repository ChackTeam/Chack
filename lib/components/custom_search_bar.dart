// lib/components/search_bar/custom_search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/icons.dart';
import '../constants/colors.dart';

class CustomSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onProfileTap;

  const CustomSearchBar({
    super.key,
    this.onTap,
    this.onLogoTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.only(left: 10, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 로고
          GestureDetector(
            onTap: onLogoTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SvgPicture.asset(
                AppIcons.chackIcon,
                width: 24,
              ),
            ),
          ),

          const SizedBox(width: 5),

          // 검색창
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: ShapeDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 검색 텍스트
                    Text(
                      '읽고 싶은 책을 알려주세요',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 16,
                        fontFamily: 'SUITE',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // 돋보기 아이콘
                    Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: onProfileTap,
            child: Hero(
              tag: 'profile_icon_tag',
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.pointColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SvgPicture.asset(
                  AppIcons.profileIcon,
                  colorFilter: const ColorFilter.mode(
                    AppColors.pointColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
