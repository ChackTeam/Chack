import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/icons.dart';
import '../constants/colors.dart';
import 'settings/profile_settings_screen.dart';
import 'settings/account_info_screen.dart';
import 'settings/notification_settings_screen.dart';
import 'settings/support_screen.dart';
import 'settings/account_management_screen.dart';
import 'settings/data_reset_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
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
        'label': '로그아웃 및 계정 삭제',
        'isSvg': false,
        'screen': const AccountManagementScreen(),
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
      body: Column(
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
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: AppColors.pointColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(70),
                          ),
                          child: SvgPicture.asset(
                            AppIcons.profileIcon,
                            colorFilter: const ColorFilter.mode(
                              AppColors.pointColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppColors.pointColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '상상부기',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
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
                        if (item['screen'] != null) {
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.pointColor
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }
}
