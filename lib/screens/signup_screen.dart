import 'package:flutter/material.dart';

import 'package:chack_project/services/authentication_service.dart';
import 'package:chack_project/components/custom_text_field.dart';
import 'package:chack_project/components/primary_button.dart';
import 'package:chack_project/components/custom_alert_banner.dart';
import 'package:chack_project/constants/text_styles.dart';
import 'package:chack_project/constants/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      await _authService.signUpWithEmail(
        nickname: _nicknameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // 회원가입 성공 메시지 표시

      CustomAlertBanner.show(
        context,
        message: '인증 메일을 보냈습니다. 메일함을 확인해주세요.',
        iconColor: AppColors.pointColor,
      );

      // 로그인 화면으로 이동
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });

      CustomAlertBanner.show(
        context,
        message: e.toString(),
        iconColor: AppColors.errorColor,
      );
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '똑똑한 독서 습관,\n',
                          style: AppTextStyles.titleStyle,
                        ),
                        TextSpan(
                          text: '채크',
                          style: AppTextStyles.titleStyle.copyWith(
                            color: AppColors.pointColor,
                          ),
                        ),
                        const TextSpan(
                          text: '에 오신 것을 환영해요 :)',
                          style: AppTextStyles.titleStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    hintText: '닉네임',
                    controller: _nicknameController,
                    hasError: _hasError,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: '이메일 주소',
                    controller: _emailController,
                    hasError: _hasError,
                    keyboardType: TextInputType.emailAddress,
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
                  CustomTextField(
                    hintText: '비밀번호',
                    obscureText: true,
                    controller: _passwordController,
                    hasError: _hasError,
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
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: '비밀번호 확인',
                    obscureText: true,
                    controller: _confirmPasswordController,
                    hasError: _hasError,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다.';
                      }
                      return null;
                    },
                  ),
                  if (_hasError) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
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
                  CustomButton(
                    text: _isLoading ? '로딩 중...' : '시작하기',
                    onPressed: _isLoading ? null : _register,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
