import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'dart:async';

import 'package:chack_project/components/annual_goal_card.dart';
import 'package:chack_project/components/monthly_reading_card.dart';
import 'package:chack_project/components/custom_bottom_nav_bar.dart';
import 'package:chack_project/components/custom_search_bar.dart';
import 'package:chack_project/components/book_recommendation/book_recommendation_list.dart';
import 'package:chack_project/components/recent_book_popup.dart';
import 'package:chack_project/components/custom_alert_banner.dart';
import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/constants/text_styles.dart';
import 'package:chack_project/services/authentication_service.dart';
import 'package:chack_project/services/recent_book_service.dart';
import 'package:chack_project/screens/profile_screen.dart';
import 'package:chack_project/screens/bookshelf_screen.dart';
import 'package:chack_project/screens/search/search_screen.dart';
import 'package:chack_project/screens/statistics_screen.dart';
import 'package:chack_project/screens/timer_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainScreen> {
  final Logger _logger = Logger();
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();
  final RecentBookService _recentBookService = RecentBookService();
  StreamSubscription<({String? imageUrl, String? title})>? _bookSubscription;

  String? _userId;
  String? _age;
  bool _isPopupVisible = true;
  String? _recentBookImageUrl;
  String? _recentBookTitle;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    await _getUserAge(user.uid);
    _setupRecentBookListener(user.uid);
  }

  void _setupRecentBookListener(String userId) {
    _bookSubscription?.cancel();
    _bookSubscription =
        _recentBookService.watchRecentBook(userId).listen((bookData) {
      if (!mounted) return;

      if (bookData.imageUrl != null && bookData.title != null) {
        setState(() {
          _recentBookImageUrl = bookData.imageUrl;
          _recentBookTitle = bookData.title;
          _isPopupVisible = true;
        });
        _logger.i('Recent book updated: ${bookData.title}');
      }
    }, onError: (error) {
      _logger.e('Error in recent book stream: $error');
    });
  }

  Future<void> _getUserAge(String uid) async {
    try {
      _logger.i('HomeScreen: 사용자 정보 로드 시작 - UID: $uid');
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData['age'] != null) {
          setState(() {
            _userId = uid;
            _age = userData['age'].toString();
          });
          _logger.i('HomeScreen: 사용자 나이 그룹 로드 완료: $_age');
        } else {
          _logger.w('HomeScreen: 사용자 문서에 age 필드가 없음');
        }
      } else {
        _logger.w('HomeScreen: 사용자 문서가 존재하지 않음');
      }
    } catch (e) {
      _logger.e('HomeScreen: 사용자 정보 로드 중 오류 발생: $e');
    }
  }

  void _handleNavigateToTimer() {
    setState(() {
      _currentIndex = 2; // 타이머 탭의 인덱스
      _pageController.jumpToPage(2);
      _isPopupVisible = false; // 팝업 닫기
    });
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      CustomAlertBanner.show(
        context,
        message: '로그아웃 중 오류가 발생했습니다: $e',
        iconColor: AppColors.errorColor,
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
          child: Stack(
            children: [
              Column(
                children: [
                  CustomSearchBar(
                    onTap: () {
                      if (_userId == null) {
                        CustomAlertBanner.show(
                          context,
                          message: '로그인이 필요한 서비스입니다.',
                          iconColor: AppColors.errorColor,
                        );

                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            userId: _userId!,
                          ),
                        ),
                      );
                    },
                    onProfileTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      children: [
                        _HomeTab(
                          userId: _userId,
                          age: _age,
                        ),
                        _userId != null
                            ? BookshelfScreen(userId: _userId!)
                            : const Center(
                                child: Text(
                                  '로그인이 필요한 서비스입니다.',
                                  style: TextStyle(
                                    fontFamily: 'SUITE',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                        _TimerTab(userId: _userId), // 타이머 탭
                        _userId != null
                            ? StatisticsScreen(userId: _userId!)
                            : const Center(
                                child: Text(
                                  '로그인이 필요한 서비스입니다.',
                                  style: TextStyle(
                                    fontFamily: 'SUITE',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_recentBookImageUrl != null && _recentBookTitle != null)
                RecentBookPopup(
                  isVisible: _isPopupVisible,
                  onClose: () {
                    setState(() {
                      _isPopupVisible = false;
                    });
                  },
                  onTap: _handleNavigateToTimer,
                  imageUrl: _recentBookImageUrl!,
                  title: _recentBookTitle!,
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
    _bookSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}

class _HomeTab extends StatelessWidget {
  final String? userId;
  final String? age;

  const _HomeTab({
    required this.userId,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return ColoredBox(
      color: AppColors.backgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userId != null && age != null)
                SizedBox(
                  height: 170,
                  child: BookRecommendationList(
                    userId: userId!,
                    age: age!,
                  ),
                ),
              const Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '홈',
                        style: AppTextStyles.titleStyle,
                      ),
                    ),
                  ],
                ),
              ),
              if (userId != null) ...[
                AnnualGoalCard(userId: userId!),
                const SizedBox(height: 30),
                MonthlyReadingCard(userId: userId!),
                const SizedBox(height: 200),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerTab extends StatelessWidget {
  final String? userId; // userId 추가

  const _TimerTab({
    required this.userId, // required로 설정
  });

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Center(
        child: Text(
          '로그인이 필요한 서비스입니다.',
          style: TextStyle(
            fontFamily: 'SUITE',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Center(
      child: TimerScreen(
        userId: userId!, // userId 전달
      ),
    );
  }
}
