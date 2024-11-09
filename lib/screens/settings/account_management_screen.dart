import 'package:flutter/material.dart';

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그아웃 및 계정 삭제')),
      body: const Center(child: Text('로그아웃 및 계정 삭제 화면')),
    );
  }
}
