import 'package:flutter/material.dart';

import 'package:chack_project/components/timer/timer_pomodoro.dart';
import 'package:chack_project/components/timer/timer_stopwatch.dart';
import 'package:chack_project/components/timer/timer_page_indicator.dart';
import 'package:chack_project/services/pomodoro_service.dart';
import 'package:chack_project/services/stopwatch_service.dart';

class TimerScreen extends StatefulWidget {
  final String userId;

  const TimerScreen({
    super.key,
    required this.userId,
  });

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
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
