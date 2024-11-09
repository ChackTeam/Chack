import 'package:chack_project/constants/colors.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

class BookCoverStyles {
  static const small = BookCoverStyle(
    width: 80,
    height: 122,
    borderRadius: 14,
  );

  static const medium = BookCoverStyle(
    width: 90,
    height: 137,
    borderRadius: 10.0,
  );

  static const large = BookCoverStyle(
    width: 100,
    height: 153,
    borderRadius: 12.0,
  );

  static const extraLarge = BookCoverStyle(
    width: 160,
    height: 244,
    borderRadius: 14.0,
  );
}

class BookCoverStyle {
  final double width;
  final double height;
  final double borderRadius;

  const BookCoverStyle({
    required this.width,
    required this.height,
    required this.borderRadius,
  });
}

class BookCover extends StatelessWidget {
  final BookCoverStyle style;

  const BookCover({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: style.width,
      height: style.height,
      decoration: BoxDecoration(
        color: Colors.grey[350],
        borderRadius: BorderRadius.circular(style.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }
}
