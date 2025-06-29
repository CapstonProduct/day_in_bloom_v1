import 'dart:convert';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '꽃이 되는 하루'),
      body: FutureBuilder(
        future: Future.wait([
          FitbitAuthService.getAccessToken(),
          FitbitAuthService.getUserId(),
          FitbitAuthService.getRefreshToken(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Text("로그인 정보 없음");
          }

          final userId = snapshot.data![1] as String;

          return FutureBuilder<bool>(
            future: checkTodayMissionReport(userId),
            builder: (context, missionReportSnapshot) {
              if (missionReportSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final missionReportDone = missionReportSnapshot.data ?? false;

              void showReportFirstSnackbar() {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⛔ 어제의 건강 리포트 확인을 먼저 진행해주세요.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 어제 리포트 확인 버튼 (항상 활성)
                            _buildSettingOption(
                              context,
                              title: '어제의 건강 리포트 확인하기',
                              imagePath: 'assets/mission_icon/report.png',
                              onTap: () async {
                                final yesterday = DateFormat('yyyy-MM-dd').format(
                                  DateTime.now().subtract(const Duration(days: 1)),
                                );
                                context.go('/homeCalendar/report?date=$yesterday');
                                await updateMission('mission_report');
                              },
                              isChecked: missionReportDone,
                            ),

                            // 건강 문답, 운동, 수면 추천은 mission_report가 true일 때만 가능
                            _buildSettingOption(
                              context,
                              title: '오늘의 문답 완료',
                              imagePath: 'assets/mission_icon/doctor.png',
                              onTap: () {
                                if (!missionReportDone) {
                                  showReportFirstSnackbar();
                                  return;
                                }
                                context.go('/homeQna');
                              },
                              isChecked: false,
                            ),

                            _buildSettingOption(
                              context,
                              title: '맞춤형 운동 추천 확인',
                              imagePath: 'assets/mission_icon/runner.png',
                              onTap: () async {
                                if (!missionReportDone) {
                                  showReportFirstSnackbar();
                                  return;
                                }
                                context.go('/homeCalendar/exerciseRecommendation');
                                await updateMission('mission_exercise');
                              },
                              isChecked: false,
                            ),

                            _buildSettingOption(
                              context,
                              title: '수면패턴에 따른 행동 추천 확인',
                              imagePath: 'assets/mission_icon/recommendation.png',
                              onTap: () async {
                                if (!missionReportDone) {
                                  showReportFirstSnackbar();
                                  return;
                                }
                                context.go('/homeCalendar/sleepRecommendation');
                                await updateMission('mission_sleep');
                              },
                              isChecked: false,
                            ),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.greenAccent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "위의 오늘 할일 목록을 클릭하시면\n해당 목록으로 이동합니다.\n할일을 완료하시면 오늘의 꽃밭일지에\n완료한 개수에 따라 씨앗 ~ 꽃이 핍니다 :)",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSettingOption(
    BuildContext context, {
    required String title,
    required String imagePath,
    required VoidCallback onTap,
    required bool isChecked,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFf6f9f7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 75,
              decoration: const BoxDecoration(
                color: Color(0xFF41af7a),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          imagePath,
                          width: 45,
                          height: 45,
                        ),
                        if (isChecked)
                          const Opacity(
                            opacity: 0.6,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward,
                size: 40,
                color: Colors.lightGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateMission(String missionType) async {
    final encodedId = await FitbitAuthService.getUserId();
    if (encodedId == null) return;

    final response = await http.post(
      Uri.parse('https://5ft8cwlwua.execute-api.ap-northeast-2.amazonaws.com/default/update-mission'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'encodedId': encodedId,
        'mission_type': missionType,
      }),
    );

    if (response.statusCode != 200) {
      debugPrint('미션 업데이트 실패: ${response.body}');
    } else {
      debugPrint('미션 업데이트 성공: ${response.body}');
    }
  }
}

Future<bool> checkYesterdayReport(String encodedId) async {
  final response = await http.get(
    Uri.parse('https://e1tbu7jvyh.execute-api.ap-northeast-2.amazonaws.com/Prod/reports?encodedId=$encodedId'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['hasReport'] == true;
  }

  return false;
}

Future<bool> checkTodayMissionReport(String encodedId) async {
  final response = await http.get(
    Uri.parse('https://e1tbu7jvyh.execute-api.ap-northeast-2.amazonaws.com/Prod/mission/today-report?encodedId=$encodedId'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['mission_report'] == true;
  }
  return false;
}
