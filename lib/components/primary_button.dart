import 'package:flutter/material.dart';

import 'package:chack_project/constants/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // onPressed를 nullable로 변경
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: onPressed, // nullable로 되어 null을 받을 수 있음
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(31),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: AppTextStyles.buttonTextStyle.copyWith(color: textColor),
        ),
      ),
    );
  }
}
