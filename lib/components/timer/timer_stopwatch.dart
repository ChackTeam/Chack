import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/icons.dart';
import '../../services/stopwatch_service.dart';
import '../../services/reading_time_service.dart';
import '../../components/timer/timer_select_book_button.dart';
import '../../components/custom_alert_banner.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

class StopwatchPage extends StatefulWidget {
  final StopwatchService stopwatchService;
  final String userId;

  const StopwatchPage({
    super.key,
    required this.stopwatchService,
    required this.userId,
  });

  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final BookReadingTimeService _readingTimeService = BookReadingTimeService();
  String elapsedTimeText = '00:00';
  Map<String, String>? selectedBook;
  StreamSubscription? _readingStatusSubscription;
  Duration _totalReadTime = Duration.zero;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    widget.stopwatchService.onTick = () {
      setState(() {
        elapsedTimeText = widget.stopwatchService.formatTime();
      });
    };
    widget.stopwatchService.onComplete = () async {
      if (selectedBook != null && widget.stopwatchService.isRunning) {
        await _updateReadingTime();
      }
    };
  }

  Future<void> _updateReadingTime() async {
    if (selectedBook == null || !mounted) return;

    final sessionTime = widget.stopwatchService.getElapsedSecondsForFirestore();

    try {
      // Firestore에 읽은 시간 업데이트
      await _readingTimeService.updateReadingTime(
        userId: widget.userId,
        isbn: selectedBook!['isbn']!,
        elapsedSeconds: sessionTime,
      );

      await widget.stopwatchService.updateDailyReadingTime(
        userId: widget.userId,
      );

      // Firestore 업데이트 후 저장 시간 초기화 (중복 방지)
      widget.stopwatchService.elapsedTimeForFirestore = 0;
    } catch (e) {
      print('Failed to update reading time: $e');
    }
    print('Firestore 업데이트 시간: $sessionTime'); // 디버깅용 로그
  }

  void _toggleStopwatch() {
    setState(() {
      if (selectedBook == null) {
        CustomAlertBanner.show(
          context,
          message: '먼저 기록할 도서를 선택해주세요.',
          iconColor: AppColors.errorColor,
        );

        return;
      }

      if (widget.stopwatchService.isRunning) {
        widget.stopwatchService.stop(); // 스톱워치 정지
        _updateReadingTime(); // 정지 후 경과 시간 업데이트
        widget.stopwatchService.elapsedTimeForUI = 0;
      } else {
        widget.stopwatchService.start(); // 스톱워치 시작
      }

      elapsedTimeText = widget.stopwatchService.formatTime();
    });
  }

  void _resetStopwatch() {
    if (widget.stopwatchService.isRunning) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('스톱워치 초기화'),
          content: const Text('현재 진행 중인 스톱워치를 초기화하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (selectedBook != null) {
                  _updateReadingTime(); // 경과 시간 업데이트
                }
                setState(() {
                  widget.stopwatchService.reset(); // 스톱워치 초기화
                  elapsedTimeText = widget.stopwatchService.formatTime();
                });
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        widget.stopwatchService.reset();
        elapsedTimeText = widget.stopwatchService.formatTime();
      });
    }
  }

  Future<void> _onBookSelected(Map<String, String>? book) async {
    if (widget.stopwatchService.isRunning) {
      final bool shouldSwitch = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('스톱워치 실행 중'),
              content: const Text('현재 실행 중인 스톱워치가 있습니다. 도서를 변경하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('확인'),
                ),
              ],
            ),
          ) ??
          false;

      if (!shouldSwitch) return;

      await _updateReadingTime(); // 도서 변경 전 현재까지의 시간 저장
      widget.stopwatchService.stop();
      widget.stopwatchService.reset();
    }

    setState(() {
      selectedBook = book;
    });

    _readingStatusSubscription?.cancel();

    if (book != null) {
      // 새로 선택한 도서의 기존 읽은 시간 가져오기
      final existingTime = await _readingTimeService.getBookReadingTime(
        userId: widget.userId,
        isbn: book['isbn']!,
      );

      setState(() {
        _totalReadTime = existingTime;
      });

      // 읽은 시간 실시간 업데이트 구독
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
    }
  }

  @override
  void dispose() {
    _readingStatusSubscription?.cancel();
    _updateTimer?.cancel();
    widget.stopwatchService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                '스톱워치',
                style: AppTextStyles.titleStyle,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.stopwatchService.formatTime(),
                  style: const TextStyle(
                    fontFamily: "SUITE",
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(AppIcons.restartIcon),
                          iconSize: 30,
                          onPressed: _resetStopwatch,
                        ),
                        const Text(
                          "다시 시작",
                          style: TextStyle(
                            fontFamily: "SUITE",
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40),
                    Column(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(
                            widget.stopwatchService.isRunning
                                ? AppIcons.pauseIcon
                                : AppIcons.startIcon,
                          ),
                          iconSize: 30,
                          onPressed: _toggleStopwatch,
                        ),
                        Text(
                          widget.stopwatchService.isRunning ? "정지" : "시작",
                          style: const TextStyle(
                            fontFamily: "SUITE",
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            child: BookSelectionWidget(
              elapsedTimeText: elapsedTimeText,
              onBookSelected: _onBookSelected,
              userId: widget.userId,
              timerService: widget.stopwatchService,
              stopwatchService: widget.stopwatchService, // StopwatchService 전달
            ),
          ),
        ],
      ),
    );
  }
}
