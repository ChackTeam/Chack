import 'package:flutter/material.dart';
import '../services/recommended_books_service.dart';
import '../services/location_service.dart';
import '../models/book_model.dart';
import '../models/api_exception.dart';
import '../constants/colors.dart';
import './book_recommendation_card.dart';

class BookRecommendationList extends StatefulWidget {
  const BookRecommendationList({super.key});

  @override
  _BookRecommendationListState createState() => _BookRecommendationListState();
}

class _BookRecommendationListState extends State<BookRecommendationList> {
  final PageController _pageController = PageController();
  final RecommendedBooksService _recommendedBooksService =
      RecommendedBooksService();
  final LocationService _locationService = LocationService();

  final List<Book> _books = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    if (_pageController.page != null) {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    }
  }

  Future<void> _loadBooks() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userLocation = await _locationService.getCurrentLocation();
      final newBooks =
          await _recommendedBooksService.fetchRecommendedBooks(userLocation);

      if (mounted) {
        setState(() {
          final uniqueBooks = newBooks.where((newBook) {
            return !_books
                .any((existingBook) => existingBook.isbn == newBook.isbn);
          }).toList();

          _books.addAll(uniqueBooks);
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '도서 정보를 불러오는 중 오류가 발생했습니다.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshBooks() async {
    setState(() {
      _books.clear();
      _error = null;
    });
    await _loadBooks();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error ?? '오류가 발생했습니다.',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshBooks,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointColor,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _books.isEmpty) {
      return _buildErrorWidget();
    }

    return Column(
      children: [
        SizedBox(
          height: 160, // 카드 높이 포함 페이지 인디케이터 높이 설정
          child: PageView.builder(
            controller: _pageController,
            itemCount: _books.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final book = _books[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BookRecommendationCard(
                  title: book.title,
                  author: book.author,
                  distance: book.closestLibrary,
                  availability: book.availability,
                  imageUrl: book.imageUrl,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_books.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 20 : 10,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppColors.pointColor : Colors.grey,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
