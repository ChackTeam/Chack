import 'package:flutter/material.dart';
import '../services/authentication_service.dart';
import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../constants/text_styles.dart';
import '../constants/colors.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _birthDateController = TextEditingController();
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
    _birthDateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '이메일 인증',
            style: TextStyle(
              fontFamily: 'SUITE',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_emailController.text}로\n인증 메일이 발송되었습니다.',
                style: const TextStyle(
                  fontFamily: 'SUITE',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '이메일의 인증 링크를 클릭하여\n인증을 완료해 주세요.',
                style: TextStyle(
                  fontFamily: 'SUITE',
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _authService.resendVerificationEmail(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '인증 메일이 재발송되었습니다.',
                        style: TextStyle(fontFamily: 'SUITE'),
                      ),
                      backgroundColor: AppColors.pointColor,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString(),
                        style: const TextStyle(fontFamily: 'SUITE'),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                '인증 메일 재발송',
                style: TextStyle(
                  fontFamily: 'SUITE',
                  color: AppColors.pointColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 회원가입 화면 닫기
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  fontFamily: 'SUITE',
                  color: AppColors.pointColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
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
        birthDate: _birthDateController.text,
      );

      if (!mounted) return;

      _showVerificationDialog();

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(fontFamily: 'SUITE'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // 초기 날짜
      firstDate: DateTime(1900), // 선택 가능한 가장 이른 날짜
      lastDate: DateTime.now(), // 현재 날짜까지  
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
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
                        TextSpan(
                          text: '똑똑한 독서 습관,\n',
                          style: AppTextStyles.titleStyle,
                        ),
                        TextSpan(
                          text: '채크',
                          style: AppTextStyles.titleStyle.copyWith(
                            color: AppColors.pointColor,
                          ),
                        ),
                        TextSpan(
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

                  // 생년월일 필드 수정: 달력 선택 가능
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: CustomTextField(
                        hintText: '생년월일 (예: 1990-01-01)',
                        controller: _birthDateController,
                        hasError: _hasError,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '생년월일을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                    ),
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