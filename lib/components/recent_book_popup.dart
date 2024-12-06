import 'package:flutter/material.dart';

class RecentBookPopup extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onClose;
  final VoidCallback onTap;  // 새로운 콜백 추가
  final String imageUrl;
  final String title;

  const RecentBookPopup({
    super.key,
    required this.isVisible,
    required this.onClose,
    required this.onTap,  // 필수 파라미터로 추가
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 15,
      left: 15,
      right: 15,
      child: GestureDetector(
        onTap: onTap,  // 클릭 이벤트 처리
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 35,
                bottom: 0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 60,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                right: 50,
                top: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '최근에 담은 책',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SUITE',
                          ),
                        ),
                        Text(
                          title.length > 10 ? '${title.substring(0, 10)}...' : title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'SUITE',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Text(
                          '독서 시간 기록하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SUITE',
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}