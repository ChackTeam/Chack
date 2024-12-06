// services/book_search_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';

import 'package:chack_project/models/book_search_result.dart';

class BookSearchService {
  static final BookSearchService _instance = BookSearchService._internal();
  static const String _baseUrl = 'https://openapi.naver.com/v1/search/book.json';
  final Logger _logger = Logger();

  factory BookSearchService() {
    return _instance;
  }

  BookSearchService._internal();

  Future<List<BookSearchResult>> searchBooks(String query, {int start = 1, int display = 10}) async {
    try {
      _logger.i('Searching books with query: $query, start: $start, display: $display');
      
      if (query.isEmpty) {
        _logger.w('Empty search query provided');
        return [];
      }

      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse('$_baseUrl?query=$encodedQuery&start=$start&display=$display');
      
      final clientId = dotenv.env['NAVER_CLIENT_ID'];
      final clientSecret = dotenv.env['NAVER_CLIENT_SECRET'];
      
      _logger.d('Request URL: $url');
      _logger.d('Using Client ID: ${clientId?.substring(0, 4)}...');

      if (clientId == null || clientSecret == null) {
        throw Exception('API credentials not found');
      }

      final response = await http.get(
        url,
        headers: {
          'X-Naver-Client-Id': clientId,
          'X-Naver-Client-Secret': clientSecret,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      _logger.d('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        _logger.d('Response body: $responseBody');
        
        final data = json.decode(responseBody);
        
        if (data['items'] == null) {
          _logger.w('No items found in response');
          return [];
        }

        final items = data['items'] as List;
        final results = items.map((item) {
          try {
            return BookSearchResult.fromJson(item);
          } catch (e) {
            _logger.e('Error parsing book result', e);
            rethrow;
          }
        }).toList();

        _logger.i('Successfully parsed ${results.length} books');
        return results;
      } else {
        _logger.e('API Error: ${response.statusCode}\nBody: ${response.body}');
        throw Exception('Failed to search books: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.e('Error searching books', e, stackTrace);
      rethrow;
    }
  }
  
  Future<BookSearchResult?> searchBookByISBN(String isbn) async {
    try {
      final encodedISBN = Uri.encodeComponent(isbn);
      final url = Uri.parse('$_baseUrl?query=$encodedISBN');
      final clientId = dotenv.env['NAVER_CLIENT_ID'];
      final clientSecret = dotenv.env['NAVER_CLIENT_SECRET'];

      if (clientId == null || clientSecret == null) {
        throw Exception('API credentials not found');
      }

      final response = await http.get(
        url,
        headers: {
          'X-Naver-Client-Id': clientId,
          'X-Naver-Client-Secret': clientSecret,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['items'] != null && data['items'].isNotEmpty) {
          // 첫 번째 검색 결과를 반환
          return BookSearchResult.fromJson(data['items'][0]);
        }
        return null;
      } else {
        throw Exception('Failed to search book by ISBN: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error searching book by ISBN: $e');
      return null;
    }
  }
}