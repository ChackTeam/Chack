import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../components/custom_search_bar.dart';
import '../components/book_recommendation_list.dart';
import '../services/authentication_service.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../components/pomodoro_timer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkUserAuth();
  }

  Future<void> _checkUserAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          _pageController.jumpToPage(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              CustomSearchBar(
                onTap: () => Navigator.pushNamed(context, '/search'),
                onLogoTap: () {
                  setState(() => _currentIndex = 0);
                  _pageController.jumpToPage(0);
                },
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  children: const [
                    _HomeTab(),
                    _BookshelfTab(),
                    _TimerTab(),
                    _StatisticsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            _pageController.jumpToPage(index);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// HomeTab 개선
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return ColoredBox(
      color: AppColors.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 10),
            child: Text(
              '오늘의 추천 도서',
              style: AppTextStyles.titleStyle.copyWith(fontSize: 18),
            ),
          ),
          const Expanded(
            child: BookRecommendationList(),
          ),
        ],
      ),
    );
  }
}


// 서재 탭
class _BookshelfTab extends StatelessWidget {
  const _BookshelfTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: const Center(
        child: Text(
          '서재',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'SUITE',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// 타이머 탭
class _TimerTab extends StatelessWidget {
  const _TimerTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PomodoroTimer(duration: 60 * 1), // 예: 25분 타이머
    );
  }
}

// 통계 탭
class _StatisticsTab extends StatelessWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: const Center(
        child: Text(
          '통계',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'SUITE',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}