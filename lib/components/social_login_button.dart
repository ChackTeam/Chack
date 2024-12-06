// lib/components/social_login_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:chack_project/constants/colors.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String svgPath;
  final VoidCallback? onPressed;  // nullable로 변경

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.svgPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton(
        onPressed: onPressed,  // OutlinedButton은 자체적으로 nullable VoidCallback을 지원
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textColor,
          backgroundColor: AppColors.backgroundColor,
          side: BorderSide(
            color: AppColors.textColor.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(31),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 18,
                fontFamily: 'SUITE',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}