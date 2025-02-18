import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class Screen1DeepDetail extends StatelessWidget {
  const Screen1DeepDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Deep Detail 1', showBackButton: true),
      body: Center(child: Text('Screen 1 Deep Detail View')),
    );
  }
}