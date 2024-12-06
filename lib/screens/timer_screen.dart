import 'package:flutter/material.dart';
import '../services/pomodoro_timer_service.dart';
import '../services/stopwatch_service.dart';
import '../components/timer/timer_pomodoro.dart';
import '../components/timer/timer_stopwatch.dart'; // StopwatchPage import 추가
import '../components/timer/timer_page_indicator.dart';

class TimerScreen extends StatefulWidget {
  final String userId;

  const TimerScreen({
    super.key,
    required this.userId,
  });

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late TimerService _timerService;
  late StopwatchService _stopwatchService;
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _timerService = TimerService()..onTick = () => setState(() {});
    _stopwatchService = StopwatchService()..onTick = () => setState(() {});
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _timerService.dispose();
    _stopwatchService.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        PageIndicator(currentPageIndex: _currentPageIndex),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPageIndex = index),
            children: [
              PomodoroPage(
                timerService: _timerService,
                userId: widget.userId,
              ),
              StopwatchPage(
                stopwatchService: _stopwatchService,
                userId: widget.userId,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
