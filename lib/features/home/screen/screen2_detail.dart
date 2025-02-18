import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class Screen2Detail extends StatelessWidget {
  const Screen2Detail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Detail2', showBackButton: true),
      body: Center(child: Text('Screen 2 Detail View')),
    );
  }
}