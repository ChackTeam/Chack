import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class PageIndicator extends StatelessWidget {
  final int currentPageIndex;
  final int pageCount;

  const PageIndicator({
    Key? key,
    required this.currentPageIndex,
    this.pageCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPageIndex == index ? 20 : 10,
          height: 8,
          decoration: BoxDecoration(
            color: currentPageIndex == index ? AppColors.pointColor : Colors.grey,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}
