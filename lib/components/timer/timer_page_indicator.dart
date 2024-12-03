import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class PageIndicator extends StatelessWidget {
  final int currentPageIndex;
  final int pageCount;

  const PageIndicator({
    super.key,
    required this.currentPageIndex,
    this.pageCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPageIndex == index ? 20 : 8,
          height: 7,
          decoration: BoxDecoration(
            color: currentPageIndex == index
                ? AppColors.pointColor
                : Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}
