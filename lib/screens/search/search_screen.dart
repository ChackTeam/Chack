import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../components/search_input_bar.dart';
import 'search_results_screen.dart';
import '../../constants/colors.dart';

class SearchScreen extends StatefulWidget {
  final String userId; // 사용자 ID 추가

  const SearchScreen({super.key, required this.userId}); // 생성자 수정

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List<String> recentSearches = [];
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    searchController.dispose(); // TextEditingController 해제
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSearches = prefs.getStringList('recentSearches') ?? [];
      setState(() {
        recentSearches = savedSearches;
      });
    } catch (e) {
      _logger.e('Error loading recent searches: $e');
    }
  }

  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recentSearches', recentSearches);
    } catch (e) {
      _logger.e('Error saving recent searches: $e');
    }
  }

  void addSearchTerm(String term) {
    if (term.isEmpty) return;

    setState(() {
      // 이미 존재하는 검색어라면 삭제
      recentSearches.remove(term);
      // 새로운 검색어를 리스트 맨 앞에 추가
      recentSearches.insert(0, term);
      // 최대 10개까지만 유지
      if (recentSearches.length > 10) {
        recentSearches = recentSearches.sublist(0, 10);
      }
    });
    _saveRecentSearches();
  }

  void deleteSearchTerm(String term) {
    setState(() {
      recentSearches.remove(term);
    });
    _saveRecentSearches();
  }

  void _onSearch(String searchText) {
    if (searchText.isEmpty) return;

    addSearchTerm(searchText);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          searchText: searchText,
          userId: widget.userId, // 사용자 ID 전달
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: SearchInputBar(
          controller: searchController,
          onSearch: () => _onSearch(searchController.text),
          onBack: () => Navigator.pop(context), // 뒤로가기 기능 추가
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '최근 검색어',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SUITE',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      recentSearches.clear();
                    });
                    _saveRecentSearches();
                  },
                  child: Text(
                    '전체 삭제',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontFamily: 'SUITE',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            recentSearches.isEmpty
                ? const Center(
                    child: Text(
                      '최근 검색어가 없습니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'SUITE',
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: recentSearches.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _onSearch(recentSearches[index]),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color: Colors.black.withOpacity(0.4),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          recentSearches[index],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'SUITE',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      deleteSearchTerm(recentSearches[index]),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.black.withOpacity(0.4),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
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
