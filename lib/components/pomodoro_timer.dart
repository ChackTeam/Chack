
import 'package:chack_project/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/icons.dart';
import '../services/timer_service.dart';
import '../services/stopwatch_service.dart';

class PomodoroTimer extends StatefulWidget {
  final int duration;
  const PomodoroTimer({Key? key, required this.duration}) : super(key: key);

  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  late TimerService _timerService;
  late StopwatchService _stopwatchService;
  late PageController _pageController;
  int _currentPageIndex = 0; // 현재 페이지 인덱스

  @override
  void initState() {
    super.initState();
    _timerService = TimerService(duration: widget.duration)
      ..onTick = () {
        setState(() {});
      }
      ..onComplete = () {
        setState(() {
          _timerService.isRunning = false;
        });
      };

    _stopwatchService = StopwatchService()
      ..onTick = () {
        setState(() {});
      };

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
        _buildPageIndicator(),
        Container(
          height: 480,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
                if (index == 0) {
                  _timerService.reset();
                } else {
                  _stopwatchService.reset();
                }
              });
            },
            children: [
              _buildPomodoroPage(),
              _buildStopwatchPage(),
            ],
          ),
        ),
        buildSelectBook(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPageIndex == index ? 20 : 10,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPageIndex == index ? AppColors.pointColor : Colors.grey,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  Widget _buildPomodoroPage() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 1),
            child: Text(
              '뽀모도로',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'SUITE',
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 114.5,
                lineWidth: 20.0,
                percent: _timerService.progress,
                center: Text(
                  _timerService.formatTime(),
                  style: const TextStyle(fontFamily: "SUITE", fontSize: 44, fontWeight: FontWeight.w800),
                ),
                progressColor: AppColors.pointColor,
                backgroundColor: Colors.grey[300]!,
                circularStrokeCap: CircularStrokeCap.round,
                reverse: true,
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
                        onPressed: () {
                          setState(() {
                            _timerService.reset();
                          });
                        },
                      ),
                      const Text(
                        "다시 시작",
                        style: TextStyle(fontFamily: "SUITE", fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(_timerService.isRunning ? AppIcons.pauseIcon : AppIcons.startIcon),
                        iconSize: 30,
                        onPressed: () {
                          setState(() {
                            if (_timerService.isRunning) {
                              _timerService.stop();
                            } else {
                              _timerService.start();
                            }
                          });
                        },
                      ),
                      Text(
                        _timerService.isRunning ? "정지" : "시작",
                        style: const TextStyle(fontFamily: "SUITE", fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStopwatchPage() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 1),
            child: Text(
              '스탑워치',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'SUITE',
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _stopwatchService.formatTime(),
          style: const TextStyle(fontFamily: "SUITE", fontSize: 44, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: SvgPicture.asset(AppIcons.restartIcon),
              iconSize: 30,
              onPressed: () {
                setState(() {
                  _stopwatchService.reset();
                });
              },
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: SvgPicture.asset(_stopwatchService.isRunning ? AppIcons.pauseIcon : AppIcons.startIcon),
              iconSize: 30,
              onPressed: () {
                setState(() {
                  _stopwatchService.isRunning ? _stopwatchService.stop() : _stopwatchService.start();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSelectBook(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('기록할 도서 선택하기 버튼이 눌렸습니다.');
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 330),
          padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/chack_icon.svg', width: 24, height: 18),
              const SizedBox(width: 16),
              const Text(
                '기록할 도서 선택하기',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
