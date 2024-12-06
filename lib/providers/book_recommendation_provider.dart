// providers/book_recommendation_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

import 'package:chack_project/services/recommended_books_service.dart';
import 'package:chack_project/services/location_service.dart';
import 'package:chack_project/models/book_model.dart';

class BookRecommendationProvider with ChangeNotifier {
  final RecommendedBooksService _recommendedBooksService;
  final LocationService _locationService;
  final Logger _logger = Logger();
  final String age;
  final int pageSize;
  
  List<Book> _books = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  Position? _currentPosition;
  bool _isInitialized = false;
  Timer? _libraryUpdateTimer;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  BookRecommendationProvider({
    required this.age,
    required RecommendedBooksService recommendedBooksService,
    required LocationService locationService,
    this.pageSize = 10,
  })  : _recommendedBooksService = recommendedBooksService,
        _locationService = locationService {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _logger.i("Initializing BookRecommendationProvider for age group $age");
      
      // 먼저 캐시된 책 데이터를 로드
      _logger.i("Loading cached books");
      await _loadCachedBooks();

      // 위치 정보 초기화 및 도서관 정보 업데이트
      await _initializeLocation();

      _isInitialized = true;
    } catch (e, stackTrace) {
      _logger.e("Error initializing BookRecommendationProvider", e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCachedBooks() async {
    final cachedBooks = await _recommendedBooksService.fetchRecommendedBooks(
      age,
      pageSize,
      page: _currentPage,
    );

    if (cachedBooks.isNotEmpty) {
      _books = cachedBooks;
      _currentPage = (_books.length / pageSize).floor();
      notifyListeners();
    }
  }

  Future<void> _initializeLocation() async {
    try {
      // 첫 위치 정보 가져오기
      _currentPosition = await _locationService.getCurrentLocation();
      _logger.i("Current location acquired: (${_currentPosition!.latitude}, ${_currentPosition!.longitude})");

      if (_currentPosition != null && _books.isNotEmpty) {
        await _updateLibraryInfo();
      }

      // 위치 변경 리스너 설정
      _locationService.positionStream.listen(
        (position) async {
          if (_shouldUpdateLocation(position)) {
            _currentPosition = position;
            _logger.i("Location updated: (${position.latitude}, ${position.longitude})");
            // 위치가 변경되면 도서관 정보를 갱신하고 캐시를 초기화
            await _clearLibraryCache();
            await _updateLibraryInfo();
          }
        },
        onError: (error) {
          _logger.e("Location stream error", error);
        },
      );

      // 주기적 업데이트 타이머 설정 (1시간마다)
      _libraryUpdateTimer?.cancel();
      _libraryUpdateTimer = Timer.periodic(
        const Duration(hours: 1),
        (_) async {
          final newPosition = await _locationService.getCurrentLocation(forceUpdate: true);
          if (_shouldUpdateLocation(newPosition)) {
            _currentPosition = newPosition;
            await _clearLibraryCache();
            await _updateLibraryInfo();
          }
        },
      );

    } catch (e, stackTrace) {
      _logger.e("Error initializing location", e, stackTrace);
      if (_books.isEmpty) {
        await _loadCachedBooks();
      }
    }
  }

    Future<void> _clearLibraryCache() async {
    // 모든 책의 도서관 정보 캐시 초기화
    for (var book in _books) {
      await _recommendedBooksService.clearLibraryCache(book.isbn);
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final newBooks = await _recommendedBooksService.fetchRecommendedBooks(
        age,
        pageSize,
        page: _currentPage,
      );

      if (newBooks.isEmpty) {
        _hasMore = false;
      } else {
        _books.addAll(newBooks);
        _currentPage++;

        if (_currentPosition != null) {
          // 새로 로드된 책들의 도서관 정보만 업데이트
          await _updateLibraryInfoForBooks(newBooks);
        }
      }
    } catch (e, stackTrace) {
      _logger.e("Error loading more books", e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _shouldUpdateLocation(Position newPosition) {
    if (_currentPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );
    
    return distance > 100; // 100m 이상 이동했을 때만 업데이트
  }

  Future<void> _updateLibraryInfo() async {
    if (_books.isEmpty || _currentPosition == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _updateLibraryInfoForBooks(_books);
    } catch (e, stackTrace) {
      _logger.e("Error updating library info", e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateLibraryInfoForBooks(List<Book> books) async {
    final futures = books.map((book) async {
      try {
        final libraryInfo = await _recommendedBooksService.fetchLibrary(
          book.isbn,
          _currentPosition!,
        );

        if (libraryInfo != null) {
          book.availability = libraryInfo['loanAvailable'] == 'Y'
              ? '대출 가능'
              : '대출 불가';

          final distance = libraryInfo['distance'];
          final name = libraryInfo['name'];
          
          if (distance != null && name != null) {
            final distanceKm = (distance as num).toDouble() / 1000;
            book.closestLibrary = '$name (${distanceKm.toStringAsFixed(1)}km)';
          } else {
            book.closestLibrary = name ?? '주변 도서관 정보 없음';
          }
        } else {
          book.availability = '정보 없음';
          book.closestLibrary = '주변 도서관 정보 없음';
        }
      } catch (e) {
        _logger.w("Failed to update library info for book ${book.isbn}", e);
        book.availability = '정보 없음';
        book.closestLibrary = '주변 도서관 정보 없음';
      }
    }).toList();

    await Future.wait(futures);
  }

  @override
  void dispose() {
    _libraryUpdateTimer?.cancel();
    super.dispose();
  }
}