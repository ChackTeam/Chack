import 'package:flutter/material.dart';

class DataResetScreen extends StatelessWidget {
  const DataResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('데이터 초기화')),
      body: const Center(child: Text('데이터 초기화 화면')),
    );
  }
}
