// services/bookshelf_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chack_project/models/bookshelf_model.dart';

class BookshelfService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 사용자의 서재에서 책 데이터를 실시간으로 가져오기
  Stream<List<BookshelfBook>> fetchBookshelf(String userId) {
    return _firestore
        .collection('userShelf')
        .doc(userId)
        .collection('books')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookshelfBook.fromFirestore(doc.data()))
            .toList());
  }

  /// 사용자의 서재에 책이 있는지 확인
  Future<bool> isBookInShelf({
    required String userId,
    required String isbn,
  }) async {
    final doc = await _firestore
        .collection('userShelf')
        .doc(userId)
        .collection('books')
        .doc(isbn)
        .get();
        
    return doc.exists;
  }

  /// 사용자의 서재에 책 추가
  Future<void> addBookToShelf({
    required String userId,
    required String isbn,
    required String title,
    required String author,
    required String publisher,
    required String image,
  }) async {
    final userShelfRef = _firestore
        .collection('userShelf')
        .doc(userId)
        .collection('books')
        .doc(isbn);

    await userShelfRef.set({
      'isbn': isbn,
      'title': title,
      'author': author,
      'publisher': publisher,
      'image': image,
      'status': '읽기 전',
      'addedAt': Timestamp.now(),
      'startedAt': null,
      'finishedAt': null,
    });
  }

  /// 서재에서 책 삭제
  Future<void> removeBookFromShelf({
    required String userId,
    required String isbn,
  }) async {
    await _firestore
        .collection('userShelf')
        .doc(userId)
        .collection('books')
        .doc(isbn)
        .delete();
  }

  /// 책 상태 업데이트
  Future<void> updateBookStatus({
    required String userId,
    required String isbn,
    required String newStatus,
  }) async {
    final userShelfRef = _firestore
        .collection('userShelf')
        .doc(userId)
        .collection('books')
        .doc(isbn);

    final Map<String, dynamic> updateData = {
      'status': newStatus,
    };

    if (newStatus == '읽는 중') {
      updateData['startedAt'] = Timestamp.now();
    } else if (newStatus == '다 읽음') {
      updateData['finishedAt'] = Timestamp.now();
    }

    await userShelfRef.update(updateData);
  }
}