import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class ReportExerciseScreen extends StatefulWidget {
  const ReportExerciseScreen({super.key});

  @override
  State<ReportExerciseScreen> createState() => _ReportExerciseScreenState();
}

class _ReportExerciseScreenState extends State<ReportExerciseScreen> {
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

  String formatNumber(dynamic value, String unit) {
    if (value is num) {
      return (value % 1 == 0)
          ? '${value.toInt()} $unit'
          : '${value.toStringAsFixed(1)} $unit';
    }
    return '$value';
  }

  Future<String> _fetchGraphUrl(String graphType) async {
    try {
      final encodedId = await FitbitAuthService.getUserId();
      final rawDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '';

      if (encodedId == null || rawDate.isEmpty) {
        throw Exception("날짜 또는 사용자 정보가 없습니다.");
      }

      final cleaned = rawDate.replaceAll('/', '-').replaceAll(' ', '');
      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(cleaned));

      final response = await http.post(
        Uri.parse('https://hrag4ozp99.execute-api.ap-northeast-2.amazonaws.com/default/get-graph-report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "encodedId": encodedId,
          "report_date": formattedDate,
          "graph_type": graphType,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("[$graphType] 그래프 이미지 URL 요청 실패");
      }

      final result = jsonDecode(response.body);
      final url = result['cleanedUrl'];
      if (url == null) throw Exception("[$graphType] cleanedUrl이 응답에 없습니다.");
      return url;
    } catch (e, stack) {
      print('[ERROR][$graphType]: $e');
      print('[STACKTRACE][$graphType]: $stack');
      rethrow;
    }
  }

  Widget buildGraphSection(String title, String graphType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF41af7a), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FutureBuilder<String>(
          future: _fetchGraphUrl(graphType),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Text('$title 그래프를 불러올 수 없습니다.');
            } else {
              return Image.network(snapshot.data!, fit: BoxFit.cover);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜 없음';
    const Color primaryColor = Color(0xFF41af7a);

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
            final avgExerciseTime = formatNumber(data['avg_exercise_time'], '분');
            final avgHeartRate = formatNumber(data['avg_heart_rate'], 'bpm');
            final caloriesBurned = formatNumber(data['calories_burned'], '칼로리');
            final String analysis = data['exercise_gpt_analysis'] ?? '분석 데이터가 없습니다.';

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      child: const Text(
                        "운동 분석 결과",
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  buildGraphSection("심박수 그래프", "heartrate"),
                  buildGraphSection("걸음수/칼로리 그래프", "steps_calories"),

                  buildRowItem("평균 운동 시간", avgExerciseTime),
                  buildRowItem("평균 심박수", avgHeartRate),
                  buildRowItem("에너지 소모량", caloriesBurned),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDate,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          analysis,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildRowItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF41af7a), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
