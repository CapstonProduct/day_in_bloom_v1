import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class ReportStressScoreScreen extends StatefulWidget {
  const ReportStressScoreScreen({super.key});

  @override
  State<ReportStressScoreScreen> createState() => _ReportStressScoreScreenState();
}

class _ReportStressScoreScreenState extends State<ReportStressScoreScreen> {
  late Future<Map<String, dynamic>> _reportData;

  @override
  void initState() {
    super.initState();
    _reportData = fetchReportData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _reportData = fetchReportData();
    });
  }

  Future<Map<String, dynamic>> fetchReportData() async {
    final encodedId = await FitbitAuthService.getUserId();
    final reportDateRaw = GoRouterState.of(context).uri.queryParameters['date'];

    if (encodedId == null || reportDateRaw == null) {
      throw Exception('사용자 정보 또는 날짜가 없습니다.');
    }

    final formattedDate = _parseReportDate(reportDateRaw);

    final response = await http.post(
      Uri.parse('https://w3labpvlec.execute-api.ap-northeast-2.amazonaws.com/prod/report-category').replace(queryParameters: {
      'encodedId': encodedId,
      'report_date': formattedDate,
    }),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'encodedId': encodedId,
        'report_date': formattedDate,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('데이터 로드 실패: ${response.body}');
    }

    return json.decode(response.body);
  }

  String _parseReportDate(String rawDate) {
    try {
      final sanitized = rawDate.replaceAll('/', '-').replaceAll(' ', '');
      final parsedDate = DateTime.parse(sanitized);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (_) {
      throw Exception('날짜 파싱 실패: $rawDate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "건강 리포트"),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.green,
        backgroundColor: Colors.white,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _reportData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            } else if (snapshot.hasError) {
              return Center(child: Text('에러 발생: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('데이터가 없습니다.'));
            }

            final data = snapshot.data!;
            final int totalScore = data['stress_score'] ?? 0;
            final String spo2Variation = '${data['spo2_variation'] ?? 0}%';
            final String sleepHeartRate = '${data['sleep_heart_rate'] ?? 0} bpm';
            final String sleepScore = '${data['sleep_score'] ?? 0}점';

            final List<Map<String, String>> healthData = [
              {'label': '예상 산소량 변화', 'value': spo2Variation},
              {'label': '수면 중 심박수', 'value': sleepHeartRate},
              {'label': '수면 스코어', 'value': sleepScore},
            ];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "스트레스 점수",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 50),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: totalScore / 100,
                          strokeWidth: 3,
                          backgroundColor: Colors.red[100],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red,
                              spreadRadius: 5,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "$totalScore",
                            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: healthData.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              healthData[index]['label']!,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black45),
                            ),
                            Text(
                              healthData[index]['value']!,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
