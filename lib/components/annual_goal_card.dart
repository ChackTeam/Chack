import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/icons.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../components/custom_alert_banner.dart';

class AnnualGoalCard extends StatelessWidget {
  final String userId;

  const AnnualGoalCard({
    super.key,
    required this.userId,
  });

  Future<void> _showGoalEditDialog(BuildContext context) async {
    final TextEditingController goalController = TextEditingController();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                children: [
                  // 아이콘 추가
                  SvgPicture.asset(
                    AppIcons.chackIcon,
                    width: 40,
                    colorFilter: const ColorFilter.mode(
                      AppColors.pointColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '연간 독서 목표 설정',
                    style: AppTextStyles.titleStyle.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '올해 읽고 싶은 책의 수를 입력해주세요',
                    style: AppTextStyles.subTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: goalController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLabelStyle.copyWith(
                      fontSize: 24,
                      color: AppColors.pointColor,
                    ),
                    decoration: InputDecoration(
                      hintText: '목표 권수',
                      hintStyle: AppTextStyles.hintTextStyle,
                      errorText: errorText,
                      errorStyle: const TextStyle(
                        color: AppColors.errorColor,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.pointColor,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.pointColor,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.pointColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '권',
                    style: AppTextStyles.subTextStyle.copyWith(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: AppColors.pointColor.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: AppTextStyles.buttonTextStyle.copyWith(
                            color: AppColors.pointColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final input = goalController.text;
                          final goal = int.tryParse(input);

                          if (goal == null || goal <= 0) {
                            setState(() => errorText = '1권 이상의 숫자를 입력해주세요.');
                            return;
                          }

                          try {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .update({
                              'annualGoal': goal,
                            });

                            if (context.mounted) Navigator.of(context).pop();
                          } catch (e) {
                            if (context.mounted) {
                              CustomAlertBanner.show(
                                context,
                                message: '목표 설정 중 오류가 발생했습니다.',
                                iconColor: AppColors.errorColor,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pointColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          '설정',
                          style: AppTextStyles.buttonTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('userShelf')
          .doc(userId)
          .collection('books')
          .where('status', isEqualTo: '다 읽음')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('오류가 발생했습니다.');
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // 읽은 책 수 계산
        final readBooks = snapshot.data!.docs.length;

        // Firestore 업데이트 (필요 시)
        FirebaseFirestore.instance.collection('users').doc(userId).update({
          'readBooks': readBooks,
        });

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return const Text('오류가 발생했습니다.');
            }

            if (!userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
            final annualGoal = userData?['annualGoal'] as int? ?? 0;

            final remainingBooks = annualGoal - readBooks;
            final progress = annualGoal > 0 ? readBooks / annualGoal : 0.0;

            return Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 첫 번째 Row: 텍스트와 아이콘
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.chackIcon,
                          width: 30,
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          child: Text(
                            annualGoal > 0
                                ? '연간 목표 달성까지\n$remainingBooks권 남았어요.'
                                : '연간 독서 목표를\n설정해주세요!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 두 번째 Row: 진행률과 읽은 책/목표 책 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 읽은 책 수와 목표 책 수
                        RichText(
                          text: TextSpan(
                            text: '$readBooks',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF58BFAE),
                              fontFamily: 'SUITE',
                            ),
                            children: [
                              TextSpan(
                                text: '/$annualGoal권',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontFamily: 'SUITE',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 편집 아이콘
                        GestureDetector(
                          onTap: () => _showGoalEditDialog(context),
                          child: Icon(
                            Icons.edit,
                            color: Colors.black.withOpacity(0.15),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // 진행률 바
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // 진행률 배경 바
                        Container(
                          width: double.infinity,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // 진행률 바
                        FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.pointColor,
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
