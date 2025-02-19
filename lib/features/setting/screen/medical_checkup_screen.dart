import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class MedicalCheckupScreen extends StatelessWidget {
  const MedicalCheckupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '건강검진 내역', showBackButton: true),
      body: Center(child: Text('화이팅')),
    );
  }
}