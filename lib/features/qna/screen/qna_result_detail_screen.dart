import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class QnaResultDetailScreen extends StatefulWidget {
  const QnaResultDetailScreen({super.key});

  @override
  State<QnaResultDetailScreen> createState() => _QnaResultDetailScreenState();
}

class _QnaResultDetailScreenState extends State<QnaResultDetailScreen> {
  String? _analysis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    final encodedId = await FitbitAuthService.getUserId();
    final selectedDate = GoRouterState.of(context).extra as DateTime? ?? DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    final response = await http.post(
      Uri.parse('https://drjtsxdx65.execute-api.ap-northeast-2.amazonaws.com/dev/qna-result-detail'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'encodedId': encodedId,
        'date': formattedDate,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _analysis = data['gpt_analysis'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('분석 결과를 불러오지 못했습니다: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime selectedDate = GoRouterState.of(context).extra as DateTime? ?? DateTime.now();
    final String formattedDate = DateFormat('yyyy/MM/dd').format(selectedDate);

    return Scaffold(
      appBar: CustomAppBar(title: "$formattedDate 분석결과"),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.analytics, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          "AI 분석 결과",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade50, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.orange.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _analysis ?? '건강 문답 분석 내역이 없습니다.',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
