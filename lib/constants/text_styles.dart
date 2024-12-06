import 'package:flutter/material.dart';

import 'package:chack_project/constants/colors.dart';

class AppTextStyles {
  static const TextStyle titleStyle = TextStyle(
    fontSize: 22,
    fontFamily: 'SUITE',
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontFamily: 'SUITE',
    fontWeight: FontWeight.w600,
  );

  static TextStyle hintTextStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'SUITE',
    fontWeight: FontWeight.w600,
    color: AppColors.hintTextColor,
  );

  static TextStyle subTextStyle = TextStyle(
    fontSize: 14,
    fontFamily: 'SUITE',
    fontWeight: FontWeight.w500,
    color: AppColors.subTextColor,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontFamily: 'SUITE',
    fontWeight: FontWeight.w800,
    color: AppColors.backgroundColor,
  );

  // Card Text Styles
  static const TextStyle titleLabelStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'SUITE',
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  static TextStyle authorLabelStyle = TextStyle(
    fontSize: 12,
    fontFamily: 'SUITE',
    fontWeight: FontWeight.w500,
    color: Colors.black.withOpacity(0.5),
  );

  static TextStyle libraryLabelStyle = TextStyle(
    fontSize: 12,
    fontFamily: 'SUITE',
    fontWeight: FontWeight.w500,
    color: Colors.black.withOpacity(0.5),
  );
}
