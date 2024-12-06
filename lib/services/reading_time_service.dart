import 'package:cloud_firestore/cloud_firestore.dart';

class BookReadingTimeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 책의 읽은 시간 업데이트
  Future<void> updateReadingTime({
    required String userId,
    required String isbn,
    required int elapsedSeconds,
  }) async {
    try {
      final bookRef = _firestore
          .collection('userShelf')
          .doc(userId)
          .collection('books')
          .doc(isbn);

      // print('Updating reading time for book $isbn at path: ${bookRef.path}');
      // print('Elapsed seconds: $elapsedSeconds');

      await _firestore.runTransaction((transaction) async {
        final bookDoc = await transaction.get(bookRef);

        if (!bookDoc.exists) {
          // 문서가 없으면 예외를 던짐
          throw Exception('Book not found in bookshelf');
        } else {
          // 필드가 없을 경우 기본값 추가
          final currentData = bookDoc.data() ?? {};
          final currentReadTime = currentData['readTime'] as int? ?? 0;

          // 누락된 필드 체크 및 기본값 설정
          final updateData = <String, dynamic>{};
          if (!currentData.containsKey('readTime')) {
            updateData['readTime'] = 0;
          }
          if (!currentData.containsKey('lastReadAt')) {
            updateData['lastReadAt'] = FieldValue.serverTimestamp();
          }

          // 기존 데이터 업데이트
          updateData['readTime'] = currentReadTime + elapsedSeconds;
          updateData['lastReadAt'] = FieldValue.serverTimestamp();

          // print('Updating fields: $updateData');

          // 트랜잭션 업데이트
          transaction.update(bookRef, updateData);
        }
      });

      // 업데이트 확인
      final updatedDoc = await bookRef.get();
      // print('Updated document: ${updatedDoc.data()}');
    } catch (e) {
      // print('Failed to update reading time: $e');
      throw Exception('Failed to update reading time: $e');
    }
  }

  // 책의 총 읽은 시간 조회
  Future<Duration> getBookReadingTime({
    required String userId,
    required String isbn,
  }) async {
    try {
      final bookDoc = await _firestore
          .collection('userShelf')
          .doc(userId)
          .collection('books')
          .doc(isbn)
          .get();

      if (!bookDoc.exists) {
        return Duration.zero;
      }

      final readTimeSeconds = bookDoc.data()?['readTime'] as int? ?? 0;
      return Duration(seconds: readTimeSeconds);
    } catch (e) {
      throw Exception('Failed to get reading time: $e');
    }
  }

  // 읽은 시간을 포맷팅하는 유틸리티 메소드
  String formatReadingTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes분 ${seconds.toString().padLeft(2, '0')}초';
  }

  // 책의 읽기 상태와 시간을 스트림으로 구독
  Stream<Map<String, dynamic>> watchBookReadingStatus({
    required String userId,
    required String isbn,
  }) {
    return _firestore
        .collection('userShelf')
        .doc(userId)
        .collection('books')
        .doc(isbn)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return {
              'readTime': 0,
              'status': '읽기 전',
              'lastReadAt': null,
            };
          }

          return {
            'readTime': doc.data()?['readTime'] ?? 0,
            'status': doc.data()?['status'] ?? '읽기 전',
            'lastReadAt': doc.data()?['lastReadAt'],
          };
        });
  }
}