// constants/bookcover_styles.dart
import 'package:flutter/material.dart';

class BookCoverStyle {
  final double width;
  final double height;
  final double borderRadius;
  final BoxDecoration? decoration;

  const BookCoverStyle({
    required this.width,
    required this.height,
    required this.borderRadius,
    this.decoration,
  });
}

class BookCoverStyles {
  static const small = BookCoverStyle(
    width: 80,
    height: 122,
    borderRadius: 14,
    decoration: BoxDecoration(
      color: Color.fromRGBO(200, 200, 200, 1),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          blurRadius: 15,
          offset: Offset(0, 10),
        ),
      ],
    ),
  );

  static const medium = BookCoverStyle(
    width: 90,
    height: 137,
    borderRadius: 0,
    decoration: BoxDecoration(
      color: Color.fromRGBO(200, 200, 200, 1),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          blurRadius: 15,
          offset: Offset(0, 10),
        ),
      ],
    ),
  );

  static const large = BookCoverStyle(
    width: 100,
    height: 153,
    borderRadius: 0,
    decoration: BoxDecoration(
      color: Color.fromRGBO(200, 200, 200, 1),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          blurRadius: 15,
          offset: Offset(0, 10),
        ),
      ],
    ),
  );

  static const extraLarge = BookCoverStyle(
    width: 160,
    height: 244,
    borderRadius: 0,
    decoration: BoxDecoration(
      color: Color.fromRGBO(200, 200, 200, 1),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          blurRadius: 15,
          offset: Offset(0, 10),
        ),
      ],
    ),
  );
}

class BookCover extends StatelessWidget {
  final BookCoverStyle style;
  final String? imageUrl;

  const BookCover({
    super.key, 
    required this.style,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: style.width,
      height: style.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(style.borderRadius),
        color: style.decoration?.color ?? const Color.fromRGBO(200, 200, 200, 1),
        boxShadow: style.decoration?.boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(style.borderRadius),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                width: style.width,
                height: style.height,
                fit: BoxFit.cover,
                headers: const {
                  'User-Agent': 'Mozilla/5.0',  // 네이버 이미지 로딩을 위한 헤더
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Book cover image error: $error');
                  return _buildPlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingIndicator(loadingProgress);
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: style.width,
      height: style.height,
      color: style.decoration?.color ?? const Color.fromRGBO(200, 200, 200, 1),
      child: const Center(
        child: Icon(
          Icons.book,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Container(
      width: style.width,
      height: style.height,
      color: style.decoration?.color ?? const Color.fromRGBO(200, 200, 200, 1),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }
}