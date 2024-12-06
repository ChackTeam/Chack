import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chack_project/components/custom_alert_banner.dart';
import 'package:chack_project/constants/icons.dart';
import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/screens/settings/profile_settings_screen.dart';
import 'package:chack_project/screens/settings/account_info_screen.dart';
import 'package:chack_project/screens/settings/notification_settings_screen.dart';
import 'package:chack_project/screens/settings/support_screen.dart';
import 'package:chack_project/screens/settings/data_reset_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // 취소
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // 확인
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.signOut(); // Firebase 로그아웃
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      } catch (e) {
        // print('Logout Error: $e');
        CustomAlertBanner.show(
          context,
          message: '로그아웃 중 오류가 발생했습니다.',
          iconColor: AppColors.errorColor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'icon': AppIcons.profileIcon,
        'label': '프로필 설정',
        'isSvg': true,
        'screen': const ProfileSettingsScreen(),
      },
      {
        'icon': Icons.alternate_email_outlined,
        'label': '계정 정보',
        'isSvg': false,
        'screen': const AccountInfoScreen(),
      },
      {
        'icon': Icons.notifications,
        'label': '알림 설정',
        'isSvg': false,
        'screen': const NotificationSettingsScreen(),
      },
      {
        'icon': Icons.question_mark_rounded,
        'label': '도움말',
        'isSvg': false,
        'screen': const SupportScreen(),
      },
      {
        'icon': Icons.exit_to_app_rounded,
        'label': '로그아웃',
        'isSvg': false,
        'action': () => _showLogoutDialog(context), // 로그아웃 다이얼로그 호출
      },
      {
        'icon': Icons.delete,
        'label': '데이터 초기화',
        'isSvg': false,
        'screen': const DataResetScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFCDECE7),
      appBar: AppBar(
        backgroundColor: AppColors.pointColor.withOpacity(0),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '프로필',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'SUITE',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final nickname = userData?['nickname'] as String? ?? '닉네임 설정하기';
          final profileImageUrl = userData?['photoURL'] as String?;

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Hero(
                            tag: 'profile_icon_tag',
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.pointColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(70),
                              ),
                              child: profileImageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(70),
                                      child: Image.network(
                                        profileImageUrl,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Padding(
                                            padding: const EdgeInsets.all(26),
                                            child: SvgPicture.asset(
                                              AppIcons.profileIcon,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                AppColors.pointColor,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(26),
                                      child: SvgPicture.asset(
                                        AppIcons.profileIcon,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.pointColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProfileSettingsScreen(),
                            ),
                          );
                        },
                        child: Text(
                          nickname,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    ...List.generate(
                      items.length,
                      (index) {
                        final item = items[index];
                        return InkWell(
                          onTap: () {
                            if (item['action'] != null) {
                              item['action'](); // 로그아웃 다이얼로그 호출
                            } else if (item['screen'] != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => item['screen'],
                                ),
                              );
                            }
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 40,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: AppColors.pointColor
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: item['isSvg']
                                                ? SvgPicture.asset(
                                                    item['icon'],
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      AppColors.pointColor,
                                                      BlendMode.srcIn,
                                                    ),
                                                  )
                                                : Icon(
                                                    item['icon'],
                                                    color: AppColors.pointColor,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Text(
                                          item['label'],
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                              if (index == 3)
                                Divider(
                                  color: Colors.black.withOpacity(0.1),
                                  thickness: 1,
                                  indent: 40,
                                  endIndent: 40,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
