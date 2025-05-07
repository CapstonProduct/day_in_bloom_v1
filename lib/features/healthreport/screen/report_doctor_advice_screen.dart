import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class ReportDoctorAdviceScreen extends StatefulWidget {
  const ReportDoctorAdviceScreen({super.key});

  @override
  State<ReportDoctorAdviceScreen> createState() => _ReportDoctorAdviceScreenState();
}

class _ReportDoctorAdviceScreenState extends State<ReportDoctorAdviceScreen> {
  late Future<String> _advice;

  @override
  void initState() {
    super.initState();
    _loadAdvice();
  }

  void _loadAdvice() {
    setState(() {
      _advice = _fetchAdvice();
    });
  }

  Future<String> _fetchAdvice() async {
    final encodedId = await FitbitAuthService.getUserId();
    final reportDate = GoRouterState.of(context).uri.queryParameters['date'];

    if (encodedId == null || reportDate == null) {
      throw Exception('사용자 정보 또는 날짜가 누락되었습니다.');
    }

    final response = await http.post(
      Uri.parse('https://ep31fcz7cd.execute-api.ap-northeast-2.amazonaws.com/dev/report-advice'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'encodedId': encodedId,
        'report_date': reportDate,
        'role': 'doctor', // ✅ 역할 명시
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('데이터 요청 실패: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['content'] ?? '의사 조언이 없습니다.';
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜 없음';

    return Scaffold(
      appBar: const CustomAppBar(title: "건강 리포트"),
      body: RefreshIndicator(
        onRefresh: () async => _loadAdvice(),
        color: Colors.green,
        child: FutureBuilder<String>(
          future: _advice,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            }
            if (snapshot.hasError) {
              return Center(child: Text('에러: ${snapshot.error}'));
            }

            final content = snapshot.data ?? '의사 조언이 없습니다.';

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      "의사선생님 조언",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    _AdviceCard(date: selectedDate, content: content),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final String date;
  final String content;

  const _AdviceCard({required this.date, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF41af7a),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
              child: const Text("조언과 응원", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45)),
                const SizedBox(height: 8),
                Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
