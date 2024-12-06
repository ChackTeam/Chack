import 'package:flutter/material.dart';

import 'package:chack_project/constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool hasError;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.hasError = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      decoration: ShapeDecoration(
        color: hasError 
            ? Colors.red.withOpacity(0.1) 
            : Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: hasError
              ? const BorderSide(color: Colors.red, width: 1)
              : BorderSide.none,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(
          color: hasError ? Colors.red : AppColors.textColor,
          fontSize: 16,
          fontFamily: 'SUITE',
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: (hasError 
                ? Colors.red 
                : AppColors.textColor).withOpacity(0.3),
            fontSize: 16,
            fontFamily: 'SUITE',
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          fillColor: Colors.transparent,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          errorStyle: const TextStyle(height: 0),
        ),
      ),
    );
  }
}