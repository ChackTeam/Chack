import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:chack_project/components/custom_text_field.dart';
import 'package:chack_project/components/primary_button.dart';
import 'package:chack_project/components/custom_alert_banner.dart';
import 'package:chack_project/constants/text_styles.dart';
import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/services/authentication_service.dart';

class FindAccountScreen extends StatefulWidget {
  final bool isFindPassword;

  const FindAccountScreen({
    super.key,
    required this.isFindPassword,
  });

  @override
  State<FindAccountScreen> createState() => _FindAccountScreenState();
}

class _FindAccountScreenState extends State<FindAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      if (widget.isFindPassword) {
        await _authService.sendPasswordResetEmail(
          email: _emailController.text,
        );
        if (!mounted) return;
        CustomAlertBanner.show(
          context,
          message: '비밀번호 재설정 링크가 이메일로 전송되었습니다.',
          iconColor: AppColors.pointColor,
        );
        Navigator.pop(context); // 성공 시 이전 화면으로 돌아가기
      } else {
        final email = await _authService.findEmail(
          nickname: _nicknameController.text,
        );
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              '아이디 찾기 결과',
              style: AppTextStyles.titleStyle.copyWith(fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '귀하의 이메일은',
                  style: AppTextStyles.subTextStyle.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: email));
                    CustomAlertBanner.show(
                      context,
                      message: '이메일이 복사되었습니다.',
                      iconColor: AppColors.pointColor,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pointColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.pointColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          email,
                          style: AppTextStyles.titleLabelStyle.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.copy,
                          size: 20,
                          color: AppColors.pointColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '입니다.',
                  style: AppTextStyles.subTextStyle.copyWith(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pop(context); // 이전 화면으로 돌아가기
                },
                child: const Text(
                  '확인',
                  style: TextStyle(color: AppColors.pointColor),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
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
                  // 뒤로가기 버튼
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // 타이틀
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: widget.isFindPassword ? '비밀번호' : '아이디',
                          style: AppTextStyles.titleStyle.copyWith(
                            color: AppColors.pointColor,
                          ),
                        ),
                        TextSpan(
                          text: widget.isFindPassword 
                              ? '를 잊으셨나요?\n이메일을 입력해주세요.' 
                              : '를 잊으셨나요?\n닉네임을 입력해주세요.',
                          style: AppTextStyles.titleStyle,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 입력 필드
                  if (widget.isFindPassword)
                    CustomTextField(
                      controller: _emailController,
                      hintText: '이메일',
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
                    )
                  else
                    CustomTextField(
                      controller: _nicknameController,
                      hintText: '닉네임',
                      hasError: _hasError,
                      onChanged: (_) => _clearError(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '닉네임을 입력해주세요.';
                        }
                        return null;
                      },
                    ),

                  // 에러 메시지
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

                  // 제출 버튼
                  CustomButton(
                    text: _isLoading 
                        ? '로딩 중...' 
                        : (widget.isFindPassword ? '비밀번호 재설정' : '아이디 찾기'),
                    onPressed: _isLoading ? null : _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}