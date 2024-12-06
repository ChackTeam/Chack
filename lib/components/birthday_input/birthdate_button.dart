import 'package:flutter/material.dart';

import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/constants/text_styles.dart';

class BirthdateButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const BirthdateButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity, // 버튼이 부모의 너비를 가득 채우도록 설정
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: AppTextStyles.buttonTextStyle.copyWith(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
