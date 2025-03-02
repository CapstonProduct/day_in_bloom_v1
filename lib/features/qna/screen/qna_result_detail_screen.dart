import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QnaResultDetailScreen extends StatelessWidget {
  const QnaResultDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "yyyy / mm / dd AI 분석 결과"),
      body: Center(
        child: Text("QNA 상세"),
      ),
    );
  }
}
