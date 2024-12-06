// lib/screens/splash_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/services/book_cache_service.dart';
import 'package:chack_project/services/notification_service.dart';
import 'package:chack_project/screens/main_screen.dart';
import 'package:chack_project/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. 환경 변수 로드
      await dotenv.load(fileName: ".env");

      // 2. Firebase 초기화
      await Firebase.initializeApp();

      // 3. Hive 및 캐시 서비스 초기화
      await Hive.initFlutter();
      final cacheService = BookCacheService();
      await cacheService.initialize();
      await cacheService.clearCache();

      // 4. 알림 서비스 초기화
      NotificationService.onNotificationTap = (String? payload) {
        if (payload == NotificationService.navigationActionId) {
          Navigator.of(context).pushNamed('/timer');
        }
      };
      await NotificationService.initialize();

      // 5. 상태바 스타일 설정
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );

      // 모든 초기화가 완료됨
      setState(() {
        _initialized = true;
      });

      // 잠시 로고를 보여주기 위한 지연
      await Future.delayed(const Duration(seconds: 2));

      // 인증 상태에 따른 화면 이동
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  '앱 초기화 중 오류가 발생했습니다',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(
                    color: AppColors.textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Spacer(),
              SvgPicture.asset(
                'assets/images/chack_icon.svg',
                width: screenSize.width * 0.2,
                height: screenSize.width * 0.2,
                colorFilter: const ColorFilter.mode(
                  AppColors.pointColor,
                  BlendMode.srcIn,
                ),
              ),
              if (!_initialized) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '채크',
                  style: TextStyle(
                    fontFamily: 'SUITE',
                    fontSize: 25,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}