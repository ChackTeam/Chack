import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/icons.dart';

class SearchInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback? onBack;  // 추가

  const SearchInputBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onBack,  // 추가
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 14,
        ),
        Row(
          children: [
            // 로고를 GestureDetector로 감싸서 클릭 가능하게 함
            GestureDetector(
              onTap: onBack,  // 뒤로가기 기능 추가
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SvgPicture.asset(
                  AppIcons.chackIcon,
                  width: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          hintText: '읽고 싶은 책을 알려주세요',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.4),
                            fontSize: 16,
                            fontFamily: 'SUITE',
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // 검색어가 입력되었을 때만 검색 결과 화면 표시
                        if (controller.text.isNotEmpty) {
                          onSearch();
                          controller.clear(); // 검색 후 텍스트 필드 비우기
                        }
                      },
                      child: Icon(
                        Icons.search,
                        color: Colors.black.withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}