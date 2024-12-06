import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:chack_project/components/searched_book_list_item.dart';
import 'package:chack_project/components/custom_search_bar.dart';
import 'package:chack_project/components/no_result_page.dart';
import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/services/book_search_service.dart';
import 'package:chack_project/models/book_search_result.dart';
import 'package:chack_project/screens/search/search_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String userId; // userId 추가
  final String searchText;

  const SearchResultsScreen({
    super.key,
    required this.userId, // userId 추가
    required this.searchText,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final BookSearchService _bookSearchService = BookSearchService();
  final List<BookSearchResult> _searchResults = [];
  final Logger _logger = Logger();
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _logger.i('Initializing SearchResultsScreen with query: ${widget.searchText}');
    _searchBooks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBooks();
    }
  }

  Future<void> _searchBooks() async {
    if (_isLoading) {
      _logger.d('Search already in progress, skipping');
      return;
    }

    if (widget.searchText.isEmpty) {
      _logger.w('Empty search query, skipping search');
      setState(() {
        _error = '검색어를 입력해주세요';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _logger.i('Searching books: page $_currentPage');
      final results = await _bookSearchService.searchBooks(
        widget.searchText,
        start: (_currentPage - 1) * _itemsPerPage + 1,
        display: _itemsPerPage,
      );

      setState(() {
        if (_currentPage == 1) {
          _searchResults.clear();
        }
        _searchResults.addAll(results);
        _isLoading = false;
      });

      _logger.i('Search completed. Total results: ${_searchResults.length}');
    } catch (e, stackTrace) {
      _logger.e('Error during search', e, stackTrace);
      setState(() {
        _error = '책 검색 중 오류가 발생했습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreBooks() async {
    if (!_isLoading && _searchResults.length >= _itemsPerPage) {
      _logger.d('Loading more books');
      _currentPage++;
      await _searchBooks();
    }
  }

  Future<void> _retrySearch() async {
    _logger.i('Retrying search');
    setState(() {
      _error = null;
      _currentPage = 1;
      _searchResults.clear();
    });
    await _searchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomSearchBar(
              searchText: widget.searchText,
              showBackButton: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(
                      userId: widget.userId, // userId 전달
                    ),
                  ),
                );
              },
            ),
            if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: 'SUITE',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _retrySearch,
                        child: const Text(
                          '다시 시도',
                          style: TextStyle(
                            fontFamily: 'SUITE',
                            color: AppColors.pointColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_searchResults.isEmpty && !_isLoading)
              Expanded(
                child: NoResultsFound(
                  searchText: widget.searchText,
                  onRetry: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _searchResults.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _searchResults.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: AppColors.pointColor,
                          ),
                        ),
                      );
                    }

                    final book = _searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SearchedBookListItem(
                            userId: widget.userId, // userId 추가
                            isbn: book.isbn, // isbn 추가
                            title: book.title,
                            author: book.author,
                            publisher: book.publisher,
                            image: book.imageUrl,
                            description: book.description,
                          ),
                          if (index < _searchResults.length - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                thickness: 1,
                                color: Colors.black.withOpacity(0.1),
                              ),
                            )
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
