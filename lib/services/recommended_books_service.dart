// services/recommended_books_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:async';

import 'package:chack_project/models/api_exception.dart';
import 'package:chack_project/models/book_model.dart';
import 'package:chack_project/utils/book_data_normalizer.dart';
import 'package:chack_project/services/book_cache_service.dart';
import 'package:chack_project/services/book_search_service.dart';

class RecommendedBooksService {
  final String libraryServiceUrl = "https://getlibrarieswithbook-m3ebrnkf5q-du.a.run.app";
  final http.Client httpClient;
  final BookCacheService _cacheService;
  final Logger _logger = Logger();
  final BookSearchService _bookSearchService = BookSearchService();
  final Map<String, Future<Map<String, dynamic>?>> _pendingRequests = {};

  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  RecommendedBooksService({
    http.Client? httpClient,
    required BookCacheService cacheService,
  })  : httpClient = httpClient ?? http.Client(),
        _cacheService = cacheService;

  Future<List<Book>> fetchRecommendedBooks(
    String age,
    int pageSize, {
    int? page,
  }) async {
    try {
      _logger.i("Fetching recommended books for age group $age, page $page");

      List<Book> cachedBooks = await _cacheService.getCachedBooks(age);

      final offset = page != null ? page * pageSize : 0;

      if (cachedBooks.length >= offset + pageSize) {
        _logger.i("Returning cached books for page $page");
        return cachedBooks.sublist(offset, offset + pageSize);
      }

      final remaining = (offset + pageSize) - cachedBooks.length;

      final newBooks = await _fetchBooksFromFirestore(
        age,
        remaining,
        offset: cachedBooks.length,
      );

      cachedBooks.addAll(newBooks);
      await _cacheService.cacheBooks(age, cachedBooks);

      _logger.i("Fetched ${newBooks.length} books from Firestore for page $page");
      return cachedBooks.length >= offset + pageSize
          ? cachedBooks.sublist(offset, offset + pageSize)
          : cachedBooks.sublist(offset);
    } catch (e, stackTrace) {
      _logger.e("Error fetching recommended books", e, stackTrace);
      throw ApiException('도서 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<List<Book>> _fetchBooksFromFirestore(
    String age,
    int limit, {
    int offset = 0,
  }) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('hotBooks')
        .doc(age)
        .get();

    if (!docSnapshot.exists || !docSnapshot.data()!.containsKey('books')) {
      return [];
    }

    final List<dynamic> booksData = docSnapshot.data()!['books'] as List<dynamic>;
    final endIndex = offset + limit;
    final slicedBooksData = booksData.sublist(
      offset,
      endIndex > booksData.length ? booksData.length : endIndex,
    );

    return _convertToBooks(slicedBooksData);
  }

  // _convertToBooks 메서드를 추가하여 Firestore 데이터를 Book 객체 리스트로 변환합니다.
  Future<List<Book>> _convertToBooks(List<dynamic> booksData) async {
    final List<Book> books = booksData.map((bookData) {
      final rawTitle = bookData['bookname'] ?? 'No Title';
      final rawAuthor = bookData['authors'] ?? 'No Author';
      final rawPublisher = bookData['publisher'] ?? '';

      return Book(
        id: bookData['id'] ?? '',
        title: BookDataNormalizer.normalizeTitle(rawTitle),
        author: BookDataNormalizer.normalizeAuthor(rawAuthor),
        publisher: BookDataNormalizer.normalizePublisher(rawPublisher),
        isbn: bookData['isbn13'] ?? '',
        imageUrl: bookData['bookImageURL'] ?? '',
      );
    }).toList();

    // 각 책의 description을 ISBN으로 로드
    for (var book in books) {
      final description = await _fetchDescription(book.isbn);
      book.description = description; // description 추가
    }

    return books;
  }

  Future<String?> _fetchDescription(String isbn) async {
    if (isbn.isEmpty) {
      _logger.w("No ISBN provided for description fetch");
      return null;
    }

    try {
      final result = await _bookSearchService.searchBookByISBN(isbn);
      return result?.description ?? '설명을 찾을 수 없습니다.';
    } catch (e) {
      _logger.e("Error fetching description for ISBN $isbn: $e");
      return '설명을 찾을 수 없습니다.';
    }
  }

  Future<Map<String, dynamic>?> fetchLibrary(
    String isbn,
    Position userLocation,
  ) async {
    if (isbn.isEmpty) return null;

    // 캐시된 정보가 있고 위치가 크게 변하지 않았다면 캐시 사용
    final cachedInfo = await _cacheService.getCachedLibraryInfo(isbn);
    if (cachedInfo != null && cachedInfo['latitude'] != null && cachedInfo['longitude'] != null) {
      final cachedLat = cachedInfo['latitude'] as double;
      final cachedLng = cachedInfo['longitude'] as double;
      
      // 이전 위치와 현재 위치의 거리 계산
      final distance = Geolocator.distanceBetween(
        cachedLat,
        cachedLng,
        userLocation.latitude,
        userLocation.longitude,
      );

      // 100m 이내면 캐시 사용
      if (distance < 100) {
        _logger.i("Using cached library info for ISBN $isbn");
        return cachedInfo['library'];
      }
    }

    return _fetchLibraryWithRetry(isbn, userLocation);
  }

  Future<void> clearLibraryCache(String isbn) async {
    await _cacheService.clearLibraryInfo(isbn);
  }

  Future<Map<String, dynamic>?> _fetchLibraryWithRetry(
    String isbn,
    Position userLocation,
  ) async {
    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        final url = Uri.parse(
          "$libraryServiceUrl?isbn=$isbn&latitude=${userLocation.latitude}&longitude=${userLocation.longitude}"
        );

        final response = await httpClient
            .get(url)
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);

          if (jsonResponse['success'] && jsonResponse['data']['library'] != null) {
            final libraryData = Map<String, dynamic>.from(jsonResponse['data']['library']);
            
            // 캐시에 현재 위치 정보도 함께 저장
            await _cacheService.cacheLibraryInfo(isbn, {
              'library': libraryData,
              'latitude': userLocation.latitude,
              'longitude': userLocation.longitude,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });

            return libraryData;
          }
        }

        if (response.statusCode >= 500) {
          attempts++;
          if (attempts < _maxRetries) {
            await Future.delayed(_retryDelay * attempts);
            continue;
          }
        }

        return null;
      } catch (e) {
        _logger.w("Error fetching library info for ISBN $isbn", e);
        attempts++;
        if (attempts < _maxRetries) {
          await Future.delayed(_retryDelay * attempts);
          continue;
        }
        return null;
      }
    }
    return null;
  }
}
