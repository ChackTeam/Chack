import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/reading_time_service.dart';
import '../../components/timer/timer_select_book_button.dart';
import '../../services/daily_reading_service.dart';
import '../../components/custom_alert_banner.dart';
import '../../constants/icons.dart';
import '../../constants/text_styles.dart';
import '../../services/pomodoro_timer_service.dart';
import '../../constants/colors.dart';

class PomodoroPage extends StatefulWidget {
  final TimerService timerService;
  final String userId;

  const PomodoroPage({
    super.key,
    required this.timerService,
    required this.userId,
  });

  @override
  _PomodoroPageState createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  final BookReadingTimeService _readingTimeService = BookReadingTimeService();
  final DailyReadingService _dailyReadingService = DailyReadingService();
  String elapsedTimeText = '';
  Map<String, String>? selectedBook;
  StreamSubscription? _readingStatusSubscription;
  Duration _totalReadTime = Duration.zero;

  @override
  void initState() {
    super.initState();

    widget.timerService.onTick = () {
      setState(() {
        elapsedTimeText = widget.timerService
            .formatElapsedTime(widget.timerService.elapsedTimeForUI);
      });
    };

    widget.timerService.onComplete = () async {
      if (selectedBook != null && widget.timerService.isPomodoro) {
        await _updateReadingTime();

        if (mounted) {
          CustomAlertBanner.show(
            context,
            message: '독서 시간이 끝났습니다. 휴식 시간이 시작됩니다!',
            iconColor: AppColors.pointColor,
          );
        }
      } else if (mounted) {
        CustomAlertBanner.show(
          context,
          message: '휴식 시간이 끝났습니다. 다음 독서를 시작하세요!',
          iconColor: AppColors.pointColor,
        );
      }
    };
  }

  Future<void> _updateReadingTime() async {
    if (selectedBook == null) return;

    final sessionTime = widget.timerService.elapsedTimeForFirestore;

    try {
      // 도서 독서 시간과 일일 독서 시간을 동시에 업데이트
      await Future.wait([
        // 특정 도서의 독서 시간 업데이트
        _readingTimeService.updateReadingTime(
          userId: widget.userId,
          isbn: selectedBook!['isbn']!,
          elapsedSeconds: sessionTime,
        ),
        // 하루 전체 독서 시간 업데이트
        _dailyReadingService.updateDailyReadingTime(
          userId: widget.userId,
          seconds: sessionTime,
          date: DateTime.now(),
        ),
      ]);

      // Firestore 업데이트 후 저장 시간 초기화 (UI용 시간은 유지)
      widget.timerService.elapsedTimeForFirestore = 0;
    } catch (e) {
      print('Failed to update reading time: $e');
    }
  }

  void _resetTimer() {
    if (widget.timerService.isRunning) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('타이머 초기화'),
          content: const Text('현재 진행 중인 타이머를 초기화하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (selectedBook != null && widget.timerService.isPomodoro) {
                  _updateReadingTime();
                }
                setState(() {
                  // 휴식 시간이면 포모도로 모드로 전환하기 위해 한번 더 switchTimer 호출
                  widget.timerService.reset();
                  if (!widget.timerService.isPomodoro) {
                    widget.timerService
                        .switchTimer(); // private 메서드 접근 가능하도록 수정 필요
                  }
                  elapsedTimeText = widget.timerService
                      .formatElapsedTime(widget.timerService.elapsedTimeForUI);
                });
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        widget.timerService.reset();
        if (!widget.timerService.isPomodoro) {
          widget.timerService.switchTimer(); // private 메서드 접근 가능하도록 수정 필요
        }
        elapsedTimeText = widget.timerService
            .formatElapsedTime(widget.timerService.elapsedTimeForUI);
      });
    }
  }

  void _toggleTimer() {
    setState(() {
      if (selectedBook == null) {
        CustomAlertBanner.show(
          context,
          message: '먼저 기록할 도서를 선택해주세요.',
          iconColor: AppColors.errorColor,
        );

        return;
      }

      if (widget.timerService.isRunning) {
        // 타이머가 멈출 때 Firestore에 업데이트하고 elapsedTimeForUI 초기화
        widget.timerService.stop();
        _updateReadingTime(); // Firestore에 저장
        widget.timerService.elapsedTimeForUI = 0; // 초기화
      } else {
        // 타이머가 다시 시작될 때 기존 값과 중복되지 않도록 유지
        widget.timerService.start();
      }

      // UI 업데이트
      elapsedTimeText = widget.timerService
          .formatElapsedTime(widget.timerService.elapsedTimeForUI);
    });
  }

  Future<void> _onBookSelected(Map<String, String>? book) async {
    if (widget.timerService.isRunning) {
      final bool shouldSwitch = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('타이머 실행 중'),
              content: const Text('현재 실행 중인 타이머가 있습니다. 도서를 변경하시겠습니까?'),
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

      await _updateReadingTime();
      widget.timerService.stop();
      widget.timerService.reset();
    }

    setState(() {
      selectedBook = book;
    });

    _readingStatusSubscription?.cancel();

    if (book != null) {
      final existingTime = await _readingTimeService.getBookReadingTime(
        userId: widget.userId,
        isbn: book['isbn']!,
      );

      setState(() {
        _totalReadTime = existingTime;
      });

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
    widget.timerService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '뽀모도로',
                      style: AppTextStyles.titleStyle,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 114.5,
                        lineWidth: 20.0,
                        percent: widget.timerService.progress,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.timerService.formatTime(),
                              style: const TextStyle(
                                fontFamily: "SUITE",
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (!widget.timerService.isPomodoro)
                              const Text(
                                "휴식 시간",
                                style: TextStyle(
                                  fontFamily: "SUITE",
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        progressColor: widget.timerService.isPomodoro
                            ? AppColors.pointColor
                            : Colors.green,
                        backgroundColor: Colors.grey[300]!,
                        circularStrokeCap: CircularStrokeCap.butt,
                        reverse: true,
                      ),
                    ],
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
                            onPressed: _resetTimer,
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
                              widget.timerService.isRunning
                                  ? AppIcons.pauseIcon
                                  : AppIcons.startIcon,
                            ),
                            iconSize: 30,
                            onPressed: _toggleTimer,
                          ),
                          Text(
                            widget.timerService.isRunning ? "정지" : "시작",
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
              // 바텀 네비게이션과 도서 선택 버튼 사이 간격
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                child: BookSelectionWidget(
                  elapsedTimeText: elapsedTimeText,
                  onBookSelected: _onBookSelected,
                  userId: widget.userId,
                  timerService: widget.timerService,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
