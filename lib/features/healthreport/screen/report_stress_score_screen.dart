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

  void _showStressScoreInfoModal(BuildContext context, int stressScore) {
    String stateDescription;
    String recommendedAction;

    if (stressScore >= 15 && stressScore <= 30) {
      stateDescription = "매우 양호";
      recommendedAction = "휴식이 잘 되었음, 휴식 권장";
    } else if (stressScore >= 31 && stressScore <= 45) {
      stateDescription = "정상 범위";
      recommendedAction = "스트레스 낮음, 활동 가능";
    } else if (stressScore >= 46 && stressScore <= 60) {
      stateDescription = "주의 단계";
      recommendedAction = "일시적 스트레스 증가 가능";
    } else if (stressScore >= 61 && stressScore <= 80) {
      stateDescription = "경고 단계";
      recommendedAction = "회복 필요, 휴식 권장";
    } else {
      stateDescription = "매우 높은 스트레스";
      recommendedAction = "피로 누적, 회복 및 점검 필요";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.orange[50],
          title: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              "스트레스 점수 범위",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "현재 점수: $stressScore",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "상태: $stateDescription",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "권장 행동: $recommendedAction",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "확인",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
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
            final int stressScore = (data['stress_score'] as num?)?.toInt() ?? 0;
            final String hrvContribution = ((data['hrv_contribution'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1);
            final String rhrContribution = ((data['rhr_contribution'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1);
            final String sleepContribution = ((data['sleep_contribution'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1);

            final List<Map<String, String>> healthData = [
              {'label': '심박변이도 기반 점수 기여도', 'value': hrvContribution},
              {'label': '안정시 심박수 기반 점수 기여도', 'value': rhrContribution},
              {'label': '수면 기반 점수 기여도', 'value': sleepContribution},
            ];

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 120.0),
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
                              value: stressScore / 100,
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
                                "$stressScore",
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
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "스트레스 점수 의미 확인하기",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          onPressed: () => _showStressScoreInfoModal(context, stressScore),
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.info, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}