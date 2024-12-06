import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/constants/text_styles.dart';

class BirthdateTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool hasError;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;

  const BirthdateTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.hasError = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        fontFamily: 'SUITE',
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.hintTextStyle,
        filled: true,
        fillColor: AppColors.textFieldBackground,
        // 기본 border 설정
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        // 포커스되지 않았을 때의 border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        // 포커스되었을 때의 border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.pointColor, // 원하는 색상으로 설정
            width: 2.0,
          ),
        ),
        // 에러가 발생했을 때의 border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        // 포커스되었을 때 에러가 발생한 경우의 border
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
      ),
    );
  }
}
