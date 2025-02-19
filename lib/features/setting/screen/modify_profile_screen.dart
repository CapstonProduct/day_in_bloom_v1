import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class ModifyProfileScreen extends StatelessWidget {
  const ModifyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '내 정보 수정', showBackButton: true),
      body: Center(child: Text('화이팅')),
    );
  }
}