import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/statistics_service.dart';

class MonthlyReadingCard extends StatefulWidget {
  const MonthlyReadingCard({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<MonthlyReadingCard> createState() => _MonthlyReadingCardState();
}

class _MonthlyReadingCardState extends State<MonthlyReadingCard> {
  final StatisticsService _statisticsService = StatisticsService();
  Map<DateTime, int> _monthlyReadingData = {};
  bool _isLoading = true;
  int _totalReadingTime = 0;
  int _maxReadingTime = 0;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    try {
      final now = DateTime.now();
      final monthlyData = await _statisticsService.getMonthlyReadingData(
        widget.userId,
        now,
      );

      if (mounted) {
        setState(() {
          _monthlyReadingData = monthlyData;
          _maxReadingTime = monthlyData.values.fold(
            0,
            (max, value) => value > max ? value : max,
          );
          _totalReadingTime = monthlyData.values.fold(
            0,
            (sum, value) => sum + value,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading monthly reading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  String formatTotalTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '$hours시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 15,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(50),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    const double blockSize = 12;
    const double spacing = 6;
    const double gridWidth = (blockSize * 7) + (spacing * 6);
    
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 15,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${now.month}월 독서 기록',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: gridWidth,
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                      ),
                      itemCount: daysInMonth,
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final date = DateTime(now.year, now.month, day);
                        final readingTime = _monthlyReadingData[date] ?? 0;
                        return Container(
                          width: blockSize,
                          height: blockSize,
                          decoration: BoxDecoration(
                            color: readingTime > 0 
                              ? getColorByTime(readingTime)
                              : Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '총 독서 시간',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    formatTotalTime(_totalReadingTime),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}