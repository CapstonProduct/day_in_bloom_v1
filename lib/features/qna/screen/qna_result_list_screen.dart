import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QnaResultListScreen extends StatelessWidget {
  const QnaResultListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "지난 건강 문답 분석결과"),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/homeQna/healthList/healthDetail');
          },
          child: Text("QNA 상세"),
        ),
      ),
    );
  }
}