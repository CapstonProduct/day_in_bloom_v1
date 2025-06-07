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
      return '$hours시간 $minutes분';
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
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSleepStageItem(
                          '깊은 수면',
                          '''깊은 수면은 보통 잠든 후 몇 시간 동안 가장 많이 나타납니다. 아침에 상쾌하게 일어났다면 전날 밤에 깊은 수면을 충분히 취했을 가능성이 높습니다. 이 단계에서는 외부 자극에 대한 반응이 줄어들어 깨어나기 어려워지며, 호흡이 느려지고 근육이 이완되며 심박수가 보다 규칙적으로 변합니다. 나이가 들수록 깊은 수면의 양이 자연스럽게 감소하는 경향이 있지만, 개인마다 수면 패턴은 다를 수 있습니다. 깊은 수면은 신체 회복, 기억과 학습 능력, 면역 체계 강화에 중요한 역할을 합니다.''',
                          const Color(0xFF6B46C1),
                        ),
                        const SizedBox(height: 12),
                        _buildSleepStageItem(
                          '얕은 수면',
                          '''얕은 수면은 매일 밤 수면으로 진입할 때의 첫 단계로, 몸이 이완되고 느려지기 시작하면서 시작됩니다. 일반적으로 잠들고 몇 분 이내에 시작되며, 이 초기 단계에서는 깨어 있음과 잠듦 사이를 오가며 비교적 깨어있을 때와 가까운 상태이므로 쉽게 깨어날 수 있습니다. 이때 호흡과 심박수는 약간 감소합니다. 얕은 수면은 정신적 및 신체적 회복에 도움이 됩니다.''',
                          const Color(0xFF6B46C1),
                        ),
                        const SizedBox(height: 12),
                        _buildSleepStageItem(
                          '렘 수면',
                          '''REM 수면은 보통 첫 번째 깊은 수면 단계를 지나고 나서 나타납니다. 수면 주기의 후반부로 갈수록 REM 수면의 비중이 커집니다. 이 단계에서는 뇌 활동이 활발해지고 꿈이 주로 이때 발생합니다. 눈동자가 빠르게 움직이며, 심박수는 증가하고 호흡은 불규칙해집니다. 일반적으로 목 아래 근육은 움직이지 않게 되어 꿈속 행동을 실제로 하지 않도록 합니다. REM 수면은 기분 조절, 학습, 기억 형성에 중요한 역할을 하며, 뇌가 하루 동안의 정보를 처리하고 장기 기억으로 저장합니다.''',
                          const Color(0xFF6B46C1),
                        ),
                        const SizedBox(height: 12),
                        _buildSleepStageItem(
                          '수면 중 깸',
                          '''수면 중에 일시적으로 깨어 있는 것은 정상적인 현상입니다. 특히 2~3분 미만으로 깨어 있었을 경우, 깨어났다는 사실조차 기억하지 못할 수 있습니다. 아침에 피곤하게 느껴진다면, 다른 날보다 수면 중 깨어 있었던 시간이 많았을 수 있습니다. 이전에는 Fitbit에서 깨어 있었던 시간, 뒤척임, 수면 시간을 각각 표시했지만, 이제는 심박수 및 기타 데이터를 바탕으로 더 정밀하게 수면 단계를 추정합니다. 이에 따라 깨어 있었던 시간과 뒤척인 시간을 합산하여 총 깨어 있는 시간으로 보여줍니다.''',
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