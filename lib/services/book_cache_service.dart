// services/book_cache_service.dart

import 'package:hive/hive.dart';
import '../models/book_model.dart';
import 'dart:convert';

class BookCacheService {
  static const String _booksBoxName = 'books_box';
  static const String _libraryInfoBoxName = 'library_info_box';
  static const Duration _booksCacheExpiration = Duration(hours: 24);
  static const Duration _libraryInfoExpiration = Duration(hours: 1);

  late Box<String> _booksBox;
  late Box<String> _libraryInfoBox;

  // 싱글톤 패턴 구현
  static final BookCacheService _instance = BookCacheService._internal();
  factory BookCacheService() => _instance;
  BookCacheService._internal();

  Future<void> initialize() async {
    _booksBox = await Hive.openBox<String>(_booksBoxName);
    _libraryInfoBox = await Hive.openBox<String>(_libraryInfoBoxName);
    await _cleanExpiredCache();
  }

  Future<void> _cleanExpiredCache() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 만료된 도서 정보 삭제
    final booksExpiration = now - _booksCacheExpiration.inMilliseconds;
    final bookKeys = _booksBox.keys.where((key) {
      final timestamp = int.tryParse(_booksBox.get('${key}_timestamp') ?? '0') ?? 0;
      return timestamp < booksExpiration;
    }).toList();

    await _booksBox.deleteAll(bookKeys);

    // 만료된 도서관 정보 삭제
    final libraryExpiration = now - _libraryInfoExpiration.inMilliseconds;
    final libraryKeys = _libraryInfoBox.keys.where((key) {
      final timestamp = int.tryParse(_libraryInfoBox.get('${key}_timestamp') ?? '0') ?? 0;
      return timestamp < libraryExpiration;
    }).toList();

    await _libraryInfoBox.deleteAll(libraryKeys);
  }

  Future<List<Book>> getCachedBooks(String age) async {
    final cacheKey = 'books_$age';
    final booksJson = _booksBox.get(cacheKey);

    if (booksJson != null) {
      final timestamp = int.tryParse(_booksBox.get('${cacheKey}_timestamp') ?? '0') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - timestamp < _booksCacheExpiration.inMilliseconds) {
        try {
          final List<dynamic> decoded = json.decode(booksJson);
          return decoded.map((json) => Book.fromJson(json)).toList();
        } catch (e) {
          // print('Cache parsing error: $e');
          await _booksBox.delete(cacheKey);
          return [];
        }
      }
    }
    return [];
  }

  Future<void> cacheBooks(String age, List<Book> books) async {
    final cacheKey = 'books_$age';
    final booksJson = json.encode(books.map((book) => book.toJson()).toList());
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    await _booksBox.put(cacheKey, booksJson);
    await _booksBox.put('${cacheKey}_timestamp', timestamp);
  }

  Future<Map<String, dynamic>?> getCachedLibraryInfo(String isbn) async {
    final libraryInfo = _libraryInfoBox.get(isbn);
    if (libraryInfo != null) {
      final timestamp = int.tryParse(_libraryInfoBox.get('${isbn}_timestamp') ?? '0') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - timestamp < _libraryInfoExpiration.inMilliseconds) {
        return json.decode(libraryInfo);
      }
    }
    return null;
  }

  Future<void> cacheLibraryInfo(String isbn, Map<String, dynamic> info) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _libraryInfoBox.put(isbn, json.encode(info));
    await _libraryInfoBox.put('${isbn}_timestamp', timestamp);
  }

  // clearCache 메서드 추가
  Future<void> clearCache() async {
    await _booksBox.clear();
    await _libraryInfoBox.clear();
  }

    Future<void> clearLibraryInfo(String isbn) async {
    await _libraryInfoBox.delete(isbn);
    await _libraryInfoBox.delete('${isbn}_timestamp');
  }

  // 모든 도서관 정보 캐시 삭제
  Future<void> clearAllLibraryInfo() async {
    final keys = _libraryInfoBox.keys.toList();
    await _libraryInfoBox.deleteAll(keys);
  }


  Future<void> dispose() async {
    await _booksBox.close();
    await _libraryInfoBox.close();
  }
}
