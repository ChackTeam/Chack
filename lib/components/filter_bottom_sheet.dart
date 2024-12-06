import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/constants/icons.dart';

class FilterBottomSheet extends StatelessWidget {
  final List<String> filterOptions;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const FilterBottomSheet({
    super.key,
    required this.filterOptions,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 바텀시트의 스타일과 레이아웃 설정
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 핸들바
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
          const SizedBox(height: 10),
          // 필터 리스트
          ListView.builder(
            shrinkWrap: true,
            itemCount: filterOptions.length,
            itemBuilder: (context, index) {
              final filter = filterOptions[index];
              final isSelected = filter == selectedFilter;
              return Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.pointColor.withOpacity(0.2)
                      : AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    // 필터 항목 텍스트와 선택 아이콘
                    title: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _getStatusColor(filter), // 상태에 따른 색상 설정
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
                        Text(
                          filter,
                          style: TextStyle(
                            fontSize: 18,
                            color: isSelected
                                ? Colors.black
                                : Colors.black.withOpacity(0.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? SvgPicture.asset(
                            AppIcons.chackIcon,
                            height: 14,
                            width: 14,
                            colorFilter: const ColorFilter.mode(
                              AppColors.pointColor,
                              BlendMode.srcIn,
                            ),
                          )
                        : null,
                    onTap: () {
                      onFilterSelected(filter);
                      Navigator.pop(context); // 바텀시트 닫기
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 필터 상태에 따라 색상 반환
  Color _getStatusColor(String filter) {
    switch (filter) {
      case '읽기 전':
        return AppColors.unreadColor;
      case '읽는 중':
        return AppColors.activeReadingColor;
      case '다 읽음':
        return AppColors.pointColor;
      default:
        return AppColors.primary;
    }
  }
}
