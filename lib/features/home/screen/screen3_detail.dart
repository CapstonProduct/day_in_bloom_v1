import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class Screen3Detail extends StatelessWidget {
  const Screen3Detail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Detail3', showBackButton: true),
      body: Center(child: Text('Screen 3 Detail View')),
    );
  }
}