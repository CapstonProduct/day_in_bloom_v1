import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class HomeQnaScreen extends StatelessWidget {
  const HomeQnaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '건강 문답'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('건강 문답'),
          ],
        ),
      ),
    );
  }
}