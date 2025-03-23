import 'package:flutter/material.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';

class SleepRecommendationScreen extends StatelessWidget {
  const SleepRecommendationScreen({super.key});

  final String username = "최예름";

  final String monthlySleepAnalysis = 
    "지난 한 달 평균 수면은 6.5시간, 수면 효율은 83.7%로 양호했습니다. "
    "깊은 수면은 22%, 하루 평균 활동량은 65.3분으로 비교적 건강한 패턴을 보였습니다.";

  final String yesterdaySleepAnalysis = 
    "어제 수면은 6시간, 수면 효율은 79.8%로 평균보다 낮았습니다. "
    "깊은 수면은 14.8%, 활동량은 62분이었습니다.";

  final String sleepTips = 
      "깊은 수면을 늘리기 위해 수면 전 명상이나 가벼운 스트레칭을 추천합니다. "
      "수면 중 자주 깨어난다면, 침실 온도 및 습도를 조절하고 빛과 소음이 없는 환경을 조성하는 것이 중요합니다. "
      "평균 수면 효율을 높이기 위해 일정한 수면 루틴을 유지하고, 자기 전 스마트폰 사용을 줄이는 것이 도움이 될 수 있습니다. "
      "어제의 활동량(62분)이 충분하지 않았다면, 낮 동안의 가벼운 운동을 추가하는 것이 수면 질을 향상시킬 수 있습니다. "
      "스트레스 지수가 높다면, 취침 전 이완 기술을 활용하여 긴장을 풀어주는 것이 효과적입니다.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "$username 님 수면 행동 추천"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              _buildBox("✅ 한달 간 수면 분석", monthlySleepAnalysis),
              SizedBox(height: 20),
              _buildBox("✅ 어제의 수면 분석", yesterdaySleepAnalysis),
              SizedBox(height: 20),
              _buildBox("✅ 양질의 수면을 위한 행동 / 주의사항", sleepTips),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade400, width: 1.5),
          ),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
