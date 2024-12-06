import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/constants/icons.dart';

class NoResultsFound extends StatelessWidget {
  final VoidCallback onRetry;
  final String searchText;
  final String buttonText;

  const NoResultsFound({
    super.key,
    required this.onRetry,
    required this.searchText,
    this.buttonText = '다시 검색하기',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG 아이콘 (회색으로 색상 변경)
          SvgPicture.asset(
            AppIcons.chackIcon,
            width: 80,
            height: 80,
            colorFilter: const ColorFilter.mode(
              Color(0xFFBDBDBD), // Grey #BDBDBD
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 24),
          // Rich Text를 사용한 메시지
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '"$searchText"',
                  style: const TextStyle(
                    color: Color(0xFFFF5353),
                    fontSize: 20,
                    fontFamily: 'SUITE',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                  text: '와 일치하는\n항목이 없습니다.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'SUITE',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 부가 설명
          const Text(
            '다른 검색어로 다시 시도해보세요',
            style: TextStyle(
              fontFamily: 'SUITE',
              fontSize: 14,
              color: Color(0xFF9E9E9E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // 재시도 버튼
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontFamily: 'SUITE',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}