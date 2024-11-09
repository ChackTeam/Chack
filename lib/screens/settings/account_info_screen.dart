import 'package:flutter/material.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('계정 정보')),
      body: const Center(child: Text('계정 정보 화면')),
    );
  }
}
