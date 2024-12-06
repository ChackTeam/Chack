import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/icons.dart';

class CustomAlertBanner {
  static void show(
    BuildContext context, {
    required String message,
    required Color iconColor,
  }) {
    final overlayState = Overlay.of(context, rootOverlay: true);

    final overlayEntry = OverlayEntry(
      builder: (context) => _AlertBanner(
        message: message,
        iconColor: iconColor,
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}

class _AlertBanner extends StatefulWidget {
  final String message;
  final Color iconColor;

  const _AlertBanner({
    required this.message,
    required this.iconColor,
  });

  @override
  _AlertBannerState createState() => _AlertBannerState();
}

class _AlertBannerState extends State<_AlertBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                color: Colors.transparent, // 하단 버튼 클릭 차단용 투명 배경
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              AppIcons.chackIcon,
                              width: 18,
                              colorFilter: ColorFilter.mode(
                                widget.iconColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
