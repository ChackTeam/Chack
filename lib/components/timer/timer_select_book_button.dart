import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/icons.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../services/pomodoro_timer_service.dart';
import '../../services/reading_time_service.dart';
import '../../services/stopwatch_service.dart';
import 'timer_select_book_menu.dart';

class BookSelectionWidget extends StatefulWidget {
  final String elapsedTimeText;
  final Function(Map<String, String>?) onBookSelected;
  final String userId;
  final TimerService timerService;
  final StopwatchService? stopwatchService;
  const BookSelectionWidget({
    super.key,
    required this.elapsedTimeText,
    required this.onBookSelected,
    required this.userId,
    required this.timerService,
    this.stopwatchService,
  });

  @override
  State<BookSelectionWidget> createState() => _BookSelectionWidgetState();
}

class _BookSelectionWidgetState extends State<BookSelectionWidget> {
  Map<String, String>? selectedBook;
  final BookReadingTimeService _readingTimeService = BookReadingTimeService();
  StreamSubscription? _readingStatusSubscription;
  Duration _totalReadTime = Duration.zero;

  @override
  void dispose() {
    _readingStatusSubscription?.cancel();
    super.dispose();
  }

  Future<bool> _showBookSwitchDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            SvgPicture.asset(
              AppIcons.chackIcon,
              width: 40,
              colorFilter: const ColorFilter.mode(
                AppColors.pointColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '도서 변경',
              style: AppTextStyles.titleStyle.copyWith(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '현재 실행 중인 타이머가 있습니다.\n도서를 변경하시겠습니까?',
              style: AppTextStyles.subTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.pointColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.pointColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            '도서를 변경하면 현재 타이머가 초기화됩니다.',
            style: AppTextStyles.subTextStyle.copyWith(
              color: AppColors.pointColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: AppColors.pointColor.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    '취소',
                    style: AppTextStyles.buttonTextStyle.copyWith(
                      color: AppColors.pointColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '변경',
                    style: AppTextStyles.buttonTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showBookSelectionModal(BuildContext context) async {
    if (widget.timerService.isRunning) {
      final bool shouldSwitch = await _showBookSwitchDialog(context);

      if (!shouldSwitch) return;

      widget.timerService.stop();
      widget.timerService.reset();
    }

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        builder: (context) => BookSelectionModal(
        onBookSelected: (book) async {
          setState(() {
            selectedBook = book;
          });

          if (book != null) {
            final existingTime = await _readingTimeService.getBookReadingTime(
              userId: widget.userId,
              isbn: book['isbn']!,
            );

            setState(() {
              _totalReadTime = existingTime;
            });

            _readingStatusSubscription?.cancel();
            _readingStatusSubscription = _readingTimeService
                .watchBookReadingStatus(
              userId: widget.userId,
              isbn: book['isbn']!,
            )
                .listen((status) {
              setState(() {
                _totalReadTime = Duration(seconds: status['readTime'] as int);
              });
            });

            widget.onBookSelected(book);
          }
          Navigator.pop(context);
        },
        onResetSelection: () {
          setState(() {
            selectedBook = null;
            _totalReadTime = Duration.zero;
          });
          widget.onBookSelected(null);
          _readingStatusSubscription?.cancel();
        },
        userId: widget.userId,
        currentSelectedBook: selectedBook,
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showBookSelectionModal(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              if (selectedBook == null)
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: SvgPicture.asset('assets/images/chack_icon.svg',
                      width: 24, height: 18),
                ),
              if (selectedBook == null) const SizedBox(width: 15),
              Expanded(
                child: selectedBook == null
                    ? Text(
                  '기록할 도서 선택하기',
                  style: TextStyle(
                    fontFamily: 'SUITE',
                    color: AppColors.textColor.withOpacity(0.5),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                )
                    : Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        child: Image.network(
                          selectedBook!['imageUrl']!,
                          width: 32,
                          height: 49,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.book,
                              size: 30, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '현재 기록 중인 도서',
                                style: TextStyle(
                                    fontFamily: 'SUITE',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.black.withOpacity(0.4)),
                              ),
                            ],
                          ),
                          Text(
                            _truncateText(selectedBook!["title"]!, 8),
                            style: const TextStyle(
                              fontFamily: 'SUITE',
                              color: AppColors.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          // Text(_truncateText(selectedBook!["author"]!, 7)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (selectedBook != null)
                TweenAnimationBuilder<Duration>(
                  duration: const Duration(milliseconds: 100), // 애니메이션 지속 시간
                  tween: Tween<Duration>(
                    begin: Duration.zero, // 초기 상태
                    end: _totalReadTime +
                        (widget.timerService.isRunning
                            ? Duration(
                            seconds: widget.timerService.elapsedTimeForUI)
                            : Duration.zero),
                  ),
                  builder: (context, value, child) {
                    return Text(
                      _readingTimeService.formatReadingTime(value),
                      style: const TextStyle(
                        fontFamily: 'SUITE',
                        fontSize: 20,
                        color: AppColors.pointColor,
                        fontWeight: FontWeight.w800,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
