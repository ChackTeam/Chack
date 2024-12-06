import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 오늘의 독서 시간을 실시간으로 받아오는 스트림
  Stream<int> getTodayReadingStream(String userId) {
    final today = DateTime.now();
    final dateStr = today.toIso8601String().split('T')[0];
    
    return _firestore
        .collection('daily_reading_records')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0;
          return doc.data()?[dateStr]?['totalSeconds'] as int? ?? 0;
        });
  }

    // 월간 독서 데이터를 실시간으로 받아오는 스트림
  Stream<Map<DateTime, int>> getMonthlyReadingStream(String userId, DateTime month) {
    final monthPrefix = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    
    return _firestore
        .collection('daily_reading_records')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return {};

          Map<DateTime, int> monthlyStats = {};
          
          doc.data()!.forEach((dateStr, value) {
            if (dateStr.startsWith(monthPrefix)) {
              final date = DateTime.parse(dateStr);
              monthlyStats[date] = value['totalSeconds'] as int;
            }
          });

          return monthlyStats;
        });
  }

  // 특정 월의 일별 독서 시간 데이터 조회
  Future<Map<DateTime, int>> getMonthlyReadingData(String userId, DateTime month) async {
    try {
      final doc = await _firestore
          .collection('daily_reading_records')
          .doc(userId)
          .get();

      if (!doc.exists) return {};

      final monthPrefix = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      Map<DateTime, int> monthlyStats = {};
      
      doc.data()!.forEach((dateStr, value) {
        if (dateStr.startsWith(monthPrefix)) {
          final date = DateTime.parse(dateStr);
          monthlyStats[date] = value['totalSeconds'] as int;
        }
      });

      return monthlyStats;
    } catch (e) {
      // print('Error getting monthly reading stats: $e');
      return {};
    }
  }

  // 최근 7일간의 독서 시간 데이터 조회
  Future<List<({DateTime date, int seconds})>> getWeeklyReadingData(String userId) async {
    try {
      final today = DateTime.now();
      final weekAgo = today.subtract(const Duration(days: 6));
      final doc = await _firestore
          .collection('daily_reading_records')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return List.generate(
        7,
        (index) => (
          date: weekAgo.add(Duration(days: index)),
          seconds: 0,
        ),
      );
      }

      List<({DateTime date, int seconds})> weeklyData = [];
      
      // 최근 7일 데이터 수집
      for (int i = 0; i < 7; i++) {
        final date = weekAgo.add(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];
        final seconds = doc.data()?[dateStr]?['totalSeconds'] as int? ?? 0;
        
        weeklyData.add((
          date: date,
          seconds: seconds,
        ));
      }

      return weeklyData;
    } catch (e) {
      final today = DateTime.now();
      final weekAgo = today.subtract(const Duration(days: 6));
      // print('Error getting weekly reading stats: $e');
      return List.generate(
        7,
        (index) => (
          date: weekAgo.add(Duration(days: index)),
          seconds: 0,
        ),
      );
    }
  }

  // 해당 월의 최대 독서 시간 조회
  Future<int> getMaxReadingTimeForMonth(String userId, DateTime month) async {
    try {
      final monthlyData = await getMonthlyReadingData(userId, month);
      if (monthlyData.isEmpty) return 0;
      
      return monthlyData.values.reduce((max, value) => value > max ? value : max);
    } catch (e) {
      // print('Error getting max reading time: $e');
      return 0;
    }
  }

  // 일일 평균 독서 시간 계산
  Future<double> getAverageDailyReadingTime(String userId, DateTime month) async {
    try {
      final monthlyData = await getMonthlyReadingData(userId, month);
      if (monthlyData.isEmpty) return 0;
      
      final totalSeconds = monthlyData.values.reduce((sum, value) => sum + value);
      return totalSeconds / monthlyData.length;
    } catch (e) {
      // print('Error calculating average reading time: $e');
      return 0;
    }
  }

  // 주간 총 독서 시간 계산
  Future<int> getWeeklyTotalReadingTime(String userId) async {
    try {
      final weeklyData = await getWeeklyReadingData(userId);
      int total = 0;
      for (final data in weeklyData) {
        total += data.seconds;
      }
      return total;
    } catch (e) {
      // print('Error calculating weekly total reading time: $e');
      return 0;
    }
  }

  // 월간 총 독서 시간 계산
  Future<int> getMonthlyTotalReadingTime(String userId, DateTime month) async {
    try {
      final monthlyData = await getMonthlyReadingData(userId, month);
      if (monthlyData.isEmpty) return 0;
      
      return monthlyData.values.reduce((total, seconds) => total + seconds);
    } catch (e) {
      // print('Error calculating monthly total reading time: $e');
      return 0;
    }
  }

  // 연속 독서일 계산
  Future<int> getReadingStreak(String userId) async {
    try {
      final today = DateTime.now();
      final doc = await _firestore
          .collection('daily_reading_records')
          .doc(userId)
          .get();

      if (!doc.exists) return 0;

      int streak = 0;
      DateTime currentDate = today;

      while (true) {
        final dateStr = currentDate.toIso8601String().split('T')[0];
        final seconds = doc.data()?[dateStr]?['totalSeconds'] as int? ?? 0;

        if (seconds == 0) break;
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      }

      return streak;
    } catch (e) {
      // print('Error calculating reading streak: $e');
      return 0;
    }
  }
}