import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chack_project/constants/colors.dart';
import 'package:chack_project/components/custom_alert_banner.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists && doc.data()?['notificationsEnabled'] != null) {
          setState(() {
            _notificationsEnabled = doc.data()!['notificationsEnabled'];
          });
        }
      }
    } catch (e) {
      // print('Error loading notification settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNotificationSettings(bool value) async {
    setState(() => _notificationsEnabled = value);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'notificationsEnabled': value,
        });
        
        if (mounted) {
          CustomAlertBanner.show(
            context,
            message: value ? '알림이 켜졌습니다.' : '알림이 꺼졌습니다.',
            iconColor: AppColors.pointColor,
          );
        }
      }
    } catch (e) {
      // print('Error updating notification settings: $e');
      if (mounted) {
        CustomAlertBanner.show(
          context,
          message: '설정 업데이트 중 오류가 발생했습니다.',
          iconColor: AppColors.errorColor,
        );
      }
      setState(() => _notificationsEnabled = !value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '알림 설정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.pointColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: AppColors.pointColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '앱 알림',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '타이머 완료 등의 알림을 받습니다.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: _updateNotificationSettings,
                          activeColor: AppColors.pointColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}