import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewProfileScreen extends StatelessWidget {
  const ViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '내 정보 보기', showBackButton: true),
            body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('화이팅!'),
            ElevatedButton(
              onPressed: () {
                context.go('/homeSetting/viewProfile/modifyProfile');
              },
              child: Text('내 정보 수정'),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/homeSetting/viewProfile/medCheckup');
              },
              child: Text('건강검진 내역'),
            ),
          ],
        ),
      ),
    );
  }
}