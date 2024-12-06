// screens/collect_birth_date_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chack_project/components/birthday_input/birthdate_text_field.dart';
import 'package:chack_project/components/birthday_input/birthdate_button.dart';
import 'package:chack_project/components/custom_alert_banner.dart';
import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/constants/text_styles.dart';
import 'package:chack_project/services/authentication_service.dart';

class CollectBirthDateScreen extends StatefulWidget {
  const CollectBirthDateScreen({super.key});

  @override
  CollectBirthDateScreenState createState() => CollectBirthDateScreenState();
}

class CollectBirthDateScreenState extends State<CollectBirthDateScreen> {
  final TextEditingController _birthDateController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _birthDateController.dispose();
    super.dispose();
  }

  bool isValidDate(String dateString) {
    final RegExp regExp = RegExp(r'^(\d{4})\-(\d{2})\-(\d{2})$'); // '-' 사용
    final Match? match = regExp.firstMatch(dateString);

    if (match == null) {
      return false;
    }

    final int year = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int day = int.parse(match.group(3)!);

    // 월 범위 체크
    if (month < 1 || month > 12) {
      return false;
    }

    // 각 월의 일자 수
    List<int> daysInMonth = [
      31,
      isLeapYear(year) ? 29 : 28, // 2월
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];

    // 일 범위 체크
    if (day < 1 || day > daysInMonth[month - 1]) {
      return false;
    }

    return true;
  }

  bool isLeapYear(int year) {
    if (year % 400 == 0) {
      return true;
    } else if (year % 100 == 0) {
      return false;
    } else if (year % 4 == 0) {
      return true;
    } else {
      return false;
    }
  }

  DateTime parseDate(String dateString) {
    final RegExp regExp = RegExp(r'^(\d{4})\-(\d{2})\-(\d{2})$');
    final Match match = regExp.firstMatch(dateString)!;

    final int year = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int day = int.parse(match.group(3)!);

    return DateTime(year, month, day);
  }

  int calculateAgeGroup(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    if (age >= 0 && age <= 5) {
      return 0; // 영유아(0~5세)
    } else if (age >= 6 && age <= 7) {
      return 6; // 유아(6~7세)
    } else if (age >= 8 && age <= 13) {
      return 8; // 초등(8~13세)
    } else if (age >= 14 && age <= 19) {
      return 14; // 청소년(14~19세)
    } else if (age >= 20 && age <= 29) {
      return 20; // 20대
    } else if (age >= 30 && age <= 39) {
      return 30; // 30대
    } else if (age >= 40 && age <= 49) {
      return 40; // 40대
    } else if (age >= 50 && age <= 59) {
      return 50; // 50대
    } else if (age >= 60) {
      return 60; // 60세 이상
    } else {
      return -1; // 유효하지 않은 나이
    }
  }

  Future<void> _submitBirthDate() async {
    final String birthDateStr = _birthDateController.text.trim();

    if (birthDateStr.isEmpty) {
      CustomAlertBanner.show(
        context,
        message: '생년월일을 입력해주세요.',
        iconColor: AppColors.errorColor,
      );

      return;
    }

    // 생년월일 형식 및 유효성 검사
    if (!isValidDate(birthDateStr)) {
      CustomAlertBanner.show(
        context,
        message: '올바른 생년월일을 입력해주세요.',
        iconColor: AppColors.errorColor,
      );

      return;
    }

    // 생년월일을 DateTime 객체로 변환
    final DateTime birthDate = parseDate(birthDateStr);

    // 연령대 계산
    final int ageGroup = calculateAgeGroup(birthDate);

    if (ageGroup == -1) {
      CustomAlertBanner.show(
        context,
        message: '유효하지 않은 생년월일입니다.',
        iconColor: AppColors.errorColor,
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // AuthService를 통해 생년월일과 연령대 업데이트
      await _authService.updateBirthDate(birthDateStr, ageGroup);

      // 업데이트 성공 후 홈 화면으로 이동
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      // print('Error: $e');
      CustomAlertBanner.show(
        context,
        message: e.toString(),
        iconColor: AppColors.errorColor,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 날짜 입력 시 자동으로 '.' 추가하는 Formatter
  final _dateInputFormatter = _DateInputFormatter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                '생년월일을 입력해주세요.',
                style: AppTextStyles.titleStyle,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  // BirthdateTextField 사용
                  Expanded(
                    flex: 7,
                    child: BirthdateTextField(
                      controller: _birthDateController,
                      hintText: '예) 2000-01-01',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                        _dateInputFormatter,
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // BirthdateButton 사용
                  SizedBox(
                    width: 80,
                    height: 50,
                    child: BirthdateButton(
                      text: '완료',
                      onPressed: _isLoading ? null : _submitBirthDate,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Opacity(
                opacity: 0.3,
                child: Text(
                  '입력한 생년월일은 도서 추천에 사용됩니다.',
                  style: AppTextStyles.subTextStyle.copyWith(fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll('-', '');
    String newString = '';

    for (int i = 0; i < digitsOnly.length; i++) {
      newString += digitsOnly[i];
      if ((i == 3 || i == 5) && i != digitsOnly.length - 1) {
        newString += '-';
      }
    }

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
