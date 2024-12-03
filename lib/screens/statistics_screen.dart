import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/constants/icons.dart';
import 'package:chack_project/constants/text_styles.dart';
import 'package:chack_project/services/statistics_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StatisticsScreen extends StatefulWidget {
  final String userId;

  const StatisticsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statisticsService = StatisticsService();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, int> _monthlyReadingData = {};
  List<FlSpot> _weeklySpots =
      List.generate(7, (index) => FlSpot(index.toDouble(), 0));
  int _maxReadingTime = 0;
  double _weeklyMaxReadingTime = 0;
  Stream<int>? _todayReadingStream;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
    _loadWeeklyData();
    _initializeTodayStream();
  }

  void _initializeTodayStream() {
    final today = DateTime.now();
    _todayReadingStream =
        _statisticsService.getTodayReadingStream(widget.userId);
    _todayReadingStream?.listen((seconds) {
      if (mounted) {
        setState(() {
          _monthlyReadingData[DateTime(today.year, today.month, today.day)] =
              seconds;

          // 오늘의 독서 시간을 주간 데이터에 반영
          final minutesRead = seconds / 60;
          _weeklySpots = List.from(_weeklySpots)..[6] = FlSpot(6, minutesRead);

          // 주간 최대값 업데이트
          if (minutesRead > _weeklyMaxReadingTime) {
            _weeklyMaxReadingTime = minutesRead;
          }

          // 월별 캘린더용 최대값 업데이트
          if (seconds > _maxReadingTime) {
            _maxReadingTime = seconds;
          }
        });
      }
    });
  }

  Future<void> _loadMonthlyData() async {
    final monthlyData = await _statisticsService.getMonthlyReadingData(
        widget.userId, _focusedDay);

    if (mounted) {
      setState(() {
        _monthlyReadingData = monthlyData;
        _maxReadingTime = monthlyData.values
            .fold(0, (max, value) => value > max ? value : max);
      });
    }
  }

  Future<void> _loadWeeklyData() async {
    final weeklyData =
        await _statisticsService.getWeeklyReadingData(widget.userId);

    if (mounted) {
      setState(() {
        _weeklySpots = weeklyData
            .asMap()
            .entries
            .map((entry) => FlSpot(
                  entry.key.toDouble(),
                  entry.value.seconds / 60,
                ))
            .toList();

        // 최근 7일 최대값 계산
        _weeklyMaxReadingTime =
            _weeklySpots.fold(0.0, (max, spot) => spot.y > max ? spot.y : max);
      });
    }
  }

  Color getColorByTime(int seconds) {
    if (_maxReadingTime == 0) return Colors.transparent;
    const minOpacity = 0.3;
    const maxOpacity = 1;
    final ratio = seconds / _maxReadingTime;
    final logRatio = (log(ratio * 9 + 1) / log(10));
    final opacity = minOpacity + (maxOpacity - minOpacity) * logRatio;
    return AppColors.pointColor.withOpacity(opacity.clamp(0.0, 1.0));
  }

  String formatMinutes(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()}분';
    }
    final hours = (minutes / 60).floor();
    final mins = (minutes % 60).round();
    return mins > 0 ? '$hours시간 $mins분' : '$hours시간';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isCurrentMonth =
        _focusedDay.year == today.year && _focusedDay.month == today.month;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, today),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextFormatter: (date, locale) =>
                    '${date.year}년 ${date.month}월',
                titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                formatButtonVisible: false,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.3),
                ),
                weekendStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              rowHeight: 60,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final readingTime = _monthlyReadingData[
                          DateTime(day.year, day.month, day.day)] ??
                      0;
                  final isToday = isSameDay(day, today);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: readingTime > 0
                              ? getColorByTime(readingTime)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: (readingTime > 0)
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                      if (isToday)
                        Positioned(
                          top: 2,
                          left: 2,
                          child: SvgPicture.asset(
                            AppIcons.chackIcon,
                            width: 12,
                            height: 12,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                    ],
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final readingTime = _monthlyReadingData[
                          DateTime(day.year, day.month, day.day)] ??
                      0;
                  final isToday = isSameDay(day, today);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: readingTime > 0
                              ? getColorByTime(readingTime)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: (readingTime > 0)
                                      ? Colors.white
                                      : Colors.black.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: (readingTime > 0)
                                      ? Colors.white
                                      : Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final readingTime = _monthlyReadingData[
                          DateTime(day.year, day.month, day.day)] ??
                      0;
                  final isToday = isSameDay(day, today);
                  return null;
                },
                outsideBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(3),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black.withOpacity(0.25),
                        ),
                      ),
                    ),
                  );
                },
              ),
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                _loadMonthlyData();
              },
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '최근 7일 독서 시간',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(30),
                  child: SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        // 터치 동작 및 툴팁 설정
                        lineTouchData: LineTouchData(
                          enabled: true, // 터치 동작 활성화
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor:
                                Colors.black.withOpacity(0.05), // 툴팁 배경색
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              // 터치한 점들의 데이터를 툴팁으로 표시
                              return touchedSpots.map((LineBarSpot spot) {
                                return LineTooltipItem(
                                  '${spot.y.toStringAsFixed(1)}분', // 값을 소수점 한 자리로 표시
                                  const TextStyle(
                                    color: Colors.black, // 툴팁 텍스트 색상
                                    fontWeight: FontWeight.w700, // 텍스트 굵기
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        // 차트의 격자선 설정
                        gridData: FlGridData(
                          show: true, // 격자선 표시
                          drawHorizontalLine: true, // 가로선 표시
                          drawVerticalLine: false, // 세로선 숨김
                          horizontalInterval: 10, // 가로선 간격 (값이 10 단위로 나타남)
                          getDrawingHorizontalLine: (value) {
                            // 각 가로선의 스타일 정의
                            return FlLine(
                              color: Colors.black.withOpacity(0.1), // 선 색상
                              strokeWidth: 1, // 선 두께
                            );
                          },
                        ),
                        // 축 타이틀 설정
                        titlesData: FlTitlesData(
                          // 왼쪽 Y축 타이틀
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true, // Y축 타이틀 표시
                              reservedSize: 50, // 공간 확보
                              getTitlesWidget: (value, _) {
                                // 값을 받아 텍스트로 변환
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    formatMinutes(value), // 값을 분/시간 형식으로 변환
                                    style: TextStyle(
                                      fontSize: 12, // 텍스트 크기
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black
                                          .withOpacity(0.3), // 텍스트 색상
                                    ),
                                  ),
                                );
                              },
                              interval: 30, // 30 단위로 값 표시
                            ),
                          ),
                          // 아래 X축 타이틀
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true, // X축 타이틀 표시
                              reservedSize: 30, // 공간 확보
                              getTitlesWidget: (value, _) {
                                // 값을 날짜로 변환
                                final index = value.toInt();
                                if (index >= 0 && index <= 6) {
                                  final date = DateTime.now()
                                      .subtract(Duration(days: 6 - index));
                                  final isToday = index == 6; // 오늘인지 확인
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      isToday
                                          ? '오늘'
                                          : '${date.day}일', // 오늘이면 '오늘', 아니면 날짜 표시
                                      style: TextStyle(
                                        fontSize: 12, // 텍스트 크기
                                        fontWeight: FontWeight.w700, // 굵기 설정
                                        color: Colors.black
                                            .withOpacity(0.3), // 색상 설정
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox
                                    .shrink(); // 표시할 값이 없으면 빈 위젯 반환
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)), // 위쪽 타이틀 숨김
                          rightTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)), // 오른쪽 타이틀 숨김
                        ),
                        // 차트 외곽선 설정
                        borderData: FlBorderData(show: false), // 외곽선 숨김
                        // X축, Y축의 최소/최대값 설정
                        minX: 0, // X축 최소값
                        maxX: 6, // X축 최대값
                        minY: 0, // Y축 최소값
                        maxY: () {
                          // Y축 최대값 계산
                          final maxMinutes = _weeklySpots.fold<double>(
                            0,
                            (max, spot) =>
                                spot.y > max ? spot.y : max, // 데이터 중 최대값 찾기
                          );

                          if (maxMinutes <= 0) {
                            return 30.0; // 값이 없으면 기본값으로 30 설정
                          }

                          return ((maxMinutes / 30).ceil() * 30.0)
                              .clamp(30.0, double.infinity); // 30 단위로 반올림
                        }(),
                        // 선 데이터 설정
                        lineBarsData: [
                          LineChartBarData(
                            spots: _weeklySpots, // 차트에 표시할 데이터
                            isCurved: true, // 곡선으로 표시
                            color: AppColors.pointColor, // 선 색상
                            barWidth: 4, // 선 두께
                            // 점 스타일 설정
                            dotData: FlDotData(
                              show: true, // 점 표시
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4, // 점 크기
                                  color: AppColors.pointColor, // 점 색상
                                  strokeWidth: 1, // 테두리 두께
                                  strokeColor: AppColors.pointColor, // 테두리 색상
                                );
                              },
                            ),
                            // 선 아래 영역 스타일 설정
                            belowBarData: BarAreaData(
                              show: true, // 아래 영역 표시
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.pointColor
                                      .withOpacity(0.4), // 위쪽 색상
                                  AppColors.pointColor
                                      .withOpacity(0.1), // 아래쪽 색상
                                ],
                                begin: Alignment.topCenter, // 그라데이션 시작점
                                end: Alignment.bottomCenter, // 그라데이션 끝점
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
