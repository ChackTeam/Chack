import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/constants/icons.dart';
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
  List<FlSpot> _weeklySpots = List.generate(7, (index) => FlSpot(index.toDouble(), 0));
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
    _todayReadingStream = _statisticsService.getTodayReadingStream(widget.userId);
    _todayReadingStream?.listen((seconds) {
      if (mounted) {
        setState(() {
          _monthlyReadingData[DateTime(today.year, today.month, today.day)] = seconds;
          
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
      widget.userId, 
      _focusedDay
    );
    
    if (mounted) {
      setState(() {
        _monthlyReadingData = monthlyData;
        _maxReadingTime = monthlyData.values.fold(0, (max, value) => value > max ? value : max);
      });
    }
  }

  Future<void> _loadWeeklyData() async {
    final weeklyData = await _statisticsService.getWeeklyReadingData(widget.userId);
    
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
        _weeklyMaxReadingTime = _weeklySpots.fold(0.0, (max, spot) => spot.y > max ? spot.y : max);
      });
    }
  }

  Color getColorByTime(int seconds) {
    if (_maxReadingTime == 0) return Colors.transparent;
    final minOpacity = 0.1;
    final maxOpacity = 0.8;
    final ratio = seconds / _maxReadingTime;
    final logRatio = (log(ratio * 9 + 1) / log(10));
    final opacity = minOpacity + (maxOpacity - minOpacity) * logRatio;
    return AppColors.pointColor.withOpacity(opacity.clamp(minOpacity, maxOpacity));
  }

  String formatMinutes(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()}분';
    }
    final hours = (minutes / 60).floor();
    final mins = (minutes % 60).round();
    return mins > 0 ? '$hours시간 ${mins}분' : '$hours시간';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isCurrentMonth = _focusedDay.year == today.year && _focusedDay.month == today.month;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
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
                titleTextFormatter: (date, locale) => '${date.year}년 ${date.month}월',
                titleTextStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                formatButtonVisible: false,
              ),
              calendarStyle: const CalendarStyle(
                defaultDecoration: BoxDecoration(),
                weekendDecoration: BoxDecoration(),
                outsideDecoration: BoxDecoration(),
                selectedDecoration: BoxDecoration(),
                todayDecoration: BoxDecoration(),
                defaultTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                weekendTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                outsideTextStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                selectedTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                todayTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final readingTime = _monthlyReadingData[DateTime(day.year, day.month, day.day)] ?? 0;
                  final isToday = isSameDay(day, today);
                  
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: readingTime > 0 ? getColorByTime(readingTime) : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                    ],
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final readingTime = _monthlyReadingData[DateTime(day.year, day.month, day.day)] ?? 0;
                  final isToday = isSameDay(day, today);
                  
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: readingTime > 0 ? getColorByTime(readingTime) : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                    ],
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final readingTime = _monthlyReadingData[DateTime(day.year, day.month, day.day)] ?? 0;
                  final isToday = isSameDay(day, today);
                  
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: readingTime > 0 ? getColorByTime(readingTime) : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                    ],
                  );
                },
                outsideBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
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
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '최근 7일 독서 시간',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(30),
                  child: SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.white,
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots.map((LineBarSpot spot) {
                                return LineTooltipItem(
                                  '${spot.y.toStringAsFixed(1)}분',
                                  const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          drawVerticalLine: false,
                          horizontalInterval: 30,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.6),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, _) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    formatMinutes(value),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                              interval: 30,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, _) {
                                final index = value.toInt();
                                if (index >= 0 && index <= 6) {
                                  final date = DateTime.now().subtract(Duration(days: 6 - index));
                                  final isToday = index == 6;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      isToday ? '오늘' : '${date.day}일',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                        color: isToday ? AppColors.pointColor : Colors.grey,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 6,
                        minY: 0,
                        maxY: () {
                          final maxMinutes = _weeklySpots.fold<double>(
                            0,
                            (max, spot) => spot.y > max ? spot.y : max,
                          );
                          
                          if (maxMinutes <= 0) {
                            return 30.0;
                          }
                          
                          return ((maxMinutes / 30).ceil() * 30.0).clamp(30.0, double.infinity);
                        }(),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _weeklySpots,
                            isCurved: true,
                            color: AppColors.pointColor,
                            barWidth: 4,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 6,
                                  color: AppColors.pointColor,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.pointColor.withOpacity(0.4),
                                  AppColors.pointColor.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
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
                                