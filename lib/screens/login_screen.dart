import 'package:chack_project/screens/collect_birth_date_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/authentication_service.dart';
import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../components/social_login_button.dart';
import '../components/custom_alert_banner.dart';
import '../constants/text_styles.dart';
import '../constants/icons.dart';
import '../constants/colors.dart';
import 'signup_screen.dart';
import 'find_account_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _hasError = false;
  bool _isEmailVerificationNeeded = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _isEmailVerificationNeeded = false;
    });

    try {
      final userCredential = await _authService.signInWithEmail(
        email: _idController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      final uid = userCredential.user!.uid;
      final hasBirthDate = await _authService.isBirthDateAvailable(uid);

      if (hasBirthDate) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CollectBirthDateScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isEmailVerificationNeeded = e.toString().contains('이메일 인증이 완료되지 않았습니다');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await _authService.resendVerificationEmail(
        _idController.text,
        _passwordController.text,
      );
      if (!mounted) return;

      CustomAlertBanner.show(
        context,
        message: '인증메일이 발송되었습니다. 메일함을 확인해주세요.',
        iconColor: AppColors.pointColor,
      );
    } catch (e) {
      if (!mounted) return;

      CustomAlertBanner.show(
        context,
        message: e.toString(),
        iconColor: AppColors.errorColor,
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final credential = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (credential != null) {
        final uid = credential.user!.uid;
        final hasBirthDate = await _authService.isBirthDateAvailable(uid);

        if (hasBirthDate) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CollectBirthDateScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 80),

                      // 타이틀과 로고
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '똑똑한 독서 습관,',
                              style: AppTextStyles.titleStyle,
                            ),
                            const SizedBox(height: 8),
                            SvgPicture.asset(
                              AppIcons.chackWithIcon,
                              width: 110,
                              height: 34,
                              colorFilter: const ColorFilter.mode(
                                AppColors.pointColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // 이메일 입력 필드
                      CustomTextField(
                        hintText: '아이디',
                        controller: _idController,
                        keyboardType: TextInputType.emailAddress,
                        hasError: _hasError,
                        onChanged: (_) => _clearError(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일을 입력해주세요.';
                          }
                          if (!value.contains('@')) {
                            return '올바른 이메일 형식이 아닙니다.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // 비밀번호 입력 필드
                      CustomTextField(
                        hintText: '비밀번호',
                        obscureText: true,
                        controller: _passwordController,
                        hasError: _hasError,
                        onChanged: (_) => _clearError(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요.';
                          }
                          if (value.length < 6) {
                            return '비밀번호는 6자 이상이어야 합니다.';
                          }
                          return null;
                        },
                      ),

                      // 에러 메시지 영역
                      if (_hasError || _isEmailVerificationNeeded) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: _isEmailVerificationNeeded 
                              ? Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: '이메일 인증이 완료되지 않았습니다. 인증메일을 받지 못했나요? ',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontFamily: 'SUITE',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '다시 받기',
                                        style: const TextStyle(
                                          color: AppColors.pointColor,
                                          decoration: TextDecoration.underline,
                                          fontSize: 14,
                                          fontFamily: 'SUITE',
                                          fontWeight: FontWeight.w700,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = _resendVerificationEmail,
                                      ),
                                    ],
                                  ),
                                )
                              : Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontFamily: 'SUITE',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ],

                      const SizedBox(height: 45),

                      // 로그인 버튼
                      CustomButton(
                        text: '로그인하기',
                        onPressed: _isLoading ? null : _signInWithEmailAndPassword,
                      ),

                      const SizedBox(height: 30),

                      // 보조 링크들
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _isLoading 
                                ? null 
                                : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FindAccountScreen(
                                      isFindPassword: false,
                                    ),
                                  ),
                                ),
                              child: Text('아이디 찾기',
                                  style: AppTextStyles.subTextStyle),
                            ),
                            const VerticalDivider(
                              width: 10,
                              thickness: 1,
                              color: Colors.grey,
                              indent: 10,
                              endIndent: 10,
                            ),
                            TextButton(
                              onPressed: _isLoading 
                                ? null 
                                : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FindAccountScreen(
                                      isFindPassword: true,
                                    ),
                                  ),
                                ),
                              child: Text('비밀번호 찾기',
                                  style: AppTextStyles.subTextStyle),
                            ),
                            const VerticalDivider(
                              width: 10,
                              thickness: 1,
                              color: Colors.grey,
                              indent: 10,
                              endIndent: 10,
                            ),
                            TextButton(
                              onPressed: _isLoading 
                                ? null 
                                : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpScreen(),
                                  ),
                                ),
                              child: Text('회원가입',
                                  style: AppTextStyles.subTextStyle),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Google 로그인 버튼
                      SocialLoginButton(
                        text: 'Google로 시작하기',
                        svgPath: AppIcons.google,
                        onPressed: _isLoading ? null : _signInWithGoogle,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 로딩 인디케이터
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}