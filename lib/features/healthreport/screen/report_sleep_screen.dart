import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class ReportSleepScreen extends StatefulWidget {
  const ReportSleepScreen({super.key});

  @override
  State<ReportSleepScreen> createState() => _ReportSleepScreenState();
}

class _ReportSleepScreenState extends State<ReportSleepScreen> {
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

  String formatValue(dynamic value) {
    if (value is int || value is double) {
      return value.toString();
    }
    return value ?? '-';
  }

  String formatMinutes(dynamic value) {
    if (value is! int) return '0분';
    final hours = value ~/ 60;
    final minutes = value % 60;
    if (hours > 0) {
      return '$hours시간 ${minutes}분';
    } else {
      return '$minutes분';
    }
  }

  void _showSleepStagesModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '수면 단계별 의미',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Color(0xFF6B46C1)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSleepStageItem(
                  '깊은 수면',
                  '신체적 회복과 기억 강화가 일어나는 가장 중요한 수면 단계입니다. 성장호르몬이 분비되어 근육과 조직이 회복됩니다.',
                  const Color(0xFF6B46C1),
                ),
                const SizedBox(height: 12),
                _buildSleepStageItem(
                  '얕은 수면',
                  '깊은 잠에 들어가기 전 단계로, 몸이 서서히 휴식 상태로 전환됩니다. 쉽게 깰 수 있는 상태입니다.',
                  const Color(0xFF6B46C1),
                ),
                const SizedBox(height: 12),
                _buildSleepStageItem(
                  '렘 수면',
                  '꿈을 꾸는 단계로 뇌가 활발하게 활동합니다. 기억 정리와 학습 내용 정착이 이루어집니다.',
                  const Color(0xFF6B46C1),
                ),
                const SizedBox(height: 12),
                _buildSleepStageItem(
                  '수면 중 깸',
                  '밤중에 잠깐 깨는 것은 정상이지만, 너무 자주 깨면 수면의 질이 떨어질 수 있습니다.',
                  const Color(0xFF6B46C1),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B46C1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSleepStageItem(String title, String description, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
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
            final String sleepScore = '${((data['sleep_score'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1)} 점';
            final String timeinBed = formatMinutes(data['timeinBed']);
            final String minutesAsleep = formatMinutes(data['minutesAsleep']);
            final String analysis = data['sleep_gpt_analysis'] ?? '분석 데이터가 없습니다.';

            final String heartratePath = data['sleep_heartrate_path'] ?? '';
            final String zoneGraphPath = data['sleep_zone_graph_path'] ?? '';

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
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
                          "수면 분석 결과",
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      // child: Image.asset(
                      //   'assets/remove_img/sleep_graph_ex.png',
                      //   fit: BoxFit.cover,
                      // ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FutureBuilder<String>(
                          future: _fetchSleepGraphUrl(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return const Text('그래프를 불러올 수 없습니다.');
                            } else {
                              return Image.network(snapshot.data!, fit: BoxFit.cover);
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  buildRowItem("수면 스코어", sleepScore),
                  buildRowItem("침대에 누워있던 시간", timeinBed),
                  buildRowItem("실제 수면 시간", minutesAsleep),

                  const SizedBox(height: 20),

                  // 수면 단계별 의미 확인하기 버튼 추가
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showSleepStagesModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B46C1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "수면 단계별 의미 확인하기",
                              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mode_night_outlined,
                                size: 16,
                                color: Color(0xFF6B46C1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

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

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<String> _fetchSleepGraphUrl() async {
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
          "graph_type": "sleep"
        }),
      );

      print('[S3 API 응답] status: ${response.statusCode}');
      print('[S3 API 응답] body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception("그래프 이미지 URL 요청 실패");
      }

      final result = jsonDecode(response.body);
      final url = result['cleanedUrl']; 
      if (url == null) throw Exception("cleanedUrl이 응답에 없습니다.");
      return url;
    } catch (e, stack) {
      print('[ERROR] 예외 발생: $e');
      print('[STACKTRACE] $stack');
      rethrow;
    }
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