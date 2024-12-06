import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReadingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 일일 독서 시간 업데이트
  Future<void> updateDailyReadingTime({
    required String userId,
    required int seconds,
    required DateTime date,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];
    
    try {
      final docRef = _firestore.collection('daily_reading_records').doc(userId);
      
      await docRef.set({
        dateStr: {
          'totalSeconds': FieldValue.increment(seconds),
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
      
    } catch (e) {
      // print('Error updating daily reading time: $e');
      rethrow;
    }
  }

  // 특정 날짜의 독서 시간 조회
  Future<int> getDailyReadingTime(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];

    try {
      final doc = await _firestore
          .collection('daily_reading_records')
          .doc(userId)
          .get();

      return doc.exists ? (doc.data()?[dateStr]?['totalSeconds'] ?? 0) : 0;
    } catch (e) {
      // print('Error getting daily reading time: $e');
      return 0;
    }
  }

  // 월별 독서 시간 통계 조회
  Future<Map<DateTime, int>> getMonthlyReadingStats(
    String userId,
    DateTime month,
  ) async {
    try {
      final doc = await _firestore
          .collection('daily_reading_records')
          .doc(userId)
          .get();

      if (!doc.exists) return {};

      final data = doc.data()!;
      final monthPrefix = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      
      Map<DateTime, int> monthlyStats = {};
      
      data.forEach((dateStr, value) {
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
}