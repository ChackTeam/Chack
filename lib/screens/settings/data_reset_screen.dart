// data_reset_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/icons.dart';
import '../../constants/colors.dart';
import '../../components/custom_alert_banner.dart';

class DataResetScreen extends StatelessWidget {
  const DataResetScreen({super.key});

  Future<void> _resetUserData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '데이터 초기화',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '독서 기록과 책장 데이터가 모두 삭제되며 복구할 수 없습니다.\n정말 초기화하시겠습니까?',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // 모든 독서 기록 삭제
          await FirebaseFirestore.instance
              .collection('daily_reading_records')
              .doc(user.uid)
              .delete();

          // 유저 책장 데이터 삭제
          final userBooks = await FirebaseFirestore.instance
              .collection('userShelf')
              .doc(user.uid)
              .collection('books')
              .get();
          for (var doc in userBooks.docs) {
            await doc.reference.delete();
          }

          // 초기화 날짜 기록
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'lastResetDate': FieldValue.serverTimestamp(),
          });

          if (context.mounted) {
            CustomAlertBanner.show(
              context,
              message: '모든 독서 기록과 책장 데이터가 초기화되었습니다.',
              iconColor: AppColors.pointColor,
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        // print('Error resetting user data: $e');
        if (context.mounted) {
          CustomAlertBanner.show(
            context,
            message: '데이터 초기화 중 오류가 발생했습니다.',
            iconColor: AppColors.errorColor,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '데이터 초기화',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '데이터 초기화 시 다음 항목이 삭제됩니다:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildResetItem(
              icon: Icons.book,
              title: '독서 기록',
              description: '모든 독서 시간 기록이 삭제됩니다.',
            ),
            _buildResetItem(
              icon: Icons.bookmark,
              title: '내 책장',
              description: '책장에 저장된 모든 책 정보가 삭제됩니다.',
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '초기화된 데이터는 복구할 수 없습니다.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _resetUserData(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '데이터 초기화',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
              child: Icon(
                icon,
                color: AppColors.pointColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
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