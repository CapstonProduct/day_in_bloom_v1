import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class ExvideoScreen extends StatelessWidget {
  const ExvideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '운동 영상 추천', showBackButton: true),
      body: Center(child: Text('화이팅')),
    );
  }
}