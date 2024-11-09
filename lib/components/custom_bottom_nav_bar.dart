// lib/components/bottom_navigation/custom_bottom_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          _buildNavigationItem(
            icon: AppIcons.homeIcon,
            label: '홈',
          ),
          _buildNavigationItem(
            icon: AppIcons.bookShelfIcon,
            label: '서재',
          ),
          _buildNavigationItem(
            icon: AppIcons.timerIcon,
            label: '타이머',
          ),
          _buildNavigationItem(
            icon: AppIcons.statisticsIcon,
            label: '통계',
          ),
        ],
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundColor,
        selectedItemColor: AppColors.pointColor,
        unselectedItemColor: AppColors.subTextColor,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'SUITE',
          fontWeight: FontWeight.w600, // SemiBold
          height: 1.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'SUITE',
          fontWeight: FontWeight.w400, // Regular
          height: 1.5,
        ),
        onTap: onTap,
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationItem({
    required String icon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(
          top: 15,
          bottom: 7,
        ),
        child: SvgPicture.asset(
          icon,
          colorFilter: ColorFilter.mode(
            AppColors.subTextColor,
            BlendMode.srcIn,
          ),
        ),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(
          top: 15,
          bottom: 7,
        ),
        child: SvgPicture.asset(
          icon,
          colorFilter: const ColorFilter.mode(
            AppColors.pointColor,
            BlendMode.srcIn,
          ),
        ),
      ),
      label: label,
    );
  }
}
