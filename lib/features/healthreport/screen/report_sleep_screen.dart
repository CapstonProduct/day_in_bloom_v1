import 'package:flutter/material.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:go_router/go_router.dart';

class ReportSleepScreen extends StatelessWidget {
  const ReportSleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜 없음';
    const Color primaryColor = Color(0xFF41af7a);

    return Scaffold(
      appBar: const CustomAppBar(title: "건강 리포트"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 그래프 이미지
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
                        child: Image.asset(
                          'assets/remove_img/sleep_graph_ex.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 수면 정보 요약
                    buildRowItem("수면 스코어", "67"),
                    buildRowItem("예상 산소량 변화", "낮음"),
                    buildRowItem("수면 중 심박수", "77 bpm (평균)"),

                    const SizedBox(height: 20),

                    // 요약 설명 컨테이너
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
                          const Text(
                            "최근 Fitbit 수면 데이터 분석 결과, 평균 수면 시간이 6시간 이하로 나타나며, 수면 효율성이 75% 미만으로 감소하는 경향이 확인되었습니다.\n"
                            "특히, 깊은 수면(Deep Sleep) 비율이 전체 수면의 15% 이하로 낮아져 신체 회복과 기억 강화에 필요한 수면의 질이 저하되고 있습니다.\n"
                            "또한, 수면 중 평균 심박수는 77bpm으로 안정적인 수준이지만, 예상 산소량 변화 지표에서 약간의 변동성이 감지되어 수면 무호흡증 가능성을 고려할 필요가 있습니다.\n"
                            "이러한 수면 패턴은 전반적인 건강과 피로 회복에 영향을 줄 수 있으므로, 취침 전 블루라이트 노출 감소, 일정한 수면 루틴 유지, 그리고 규칙적인 수면 환경 개선을 권장드립니다.",
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 235, 241, 203),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "수면 장애 예측 및 대응방안",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),

                          buildPredictionItem(
                            title: "1. 불면증 가능성",
                            analysisText: "● 환자 범주: ~ ~\n● 사용자 점수: ○○○\n➜ 불면증 가능성이 높습니다",
                          ),

                          const SizedBox(height: 20),

                          buildPredictionItem(
                            title: "2. 수면 무호흡증 가능성",
                            analysisText: "● 환자 범주: ~ ~\n● 사용자 점수: ○○○\n➜ 수면 무호흡증 가능성이 낮습니다",
                          ),

                          const SizedBox(height: 20),

                          buildPredictionItem(
                            title: "3. 주간 졸림증(EDS) 가능성",
                            analysisText: "● 환자 범주: ~ ~\n● 사용자 점수: ○○○\n➜ 주간 졸림증 가능성이 낮습니다",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPredictionItem({required String title, required String analysisText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/remove_img/sleep_graph_ex.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "[ 분석 ]\n$analysisText",
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}
