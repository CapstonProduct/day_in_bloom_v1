import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '알림 목록', showBackButton: true),
      body: Center(child: Text('화이팅')),
    );
  }
}