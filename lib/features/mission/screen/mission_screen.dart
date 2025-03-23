import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '오늘 할 일'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingOption(
                context,
                title: '오늘의 문답 완료',
                imagePath: 'assets/mission_icon/doctor.png',
                onTap: () {
                  context.go('/homeQna');
                },
                isChecked: true,
              ),
              _buildSettingOption(
                context,
                title: '어제의 건강 리포트 확인하기',
                imagePath: 'assets/mission_icon/report.png',
                onTap: () {
                  final yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
                  context.go('/homeCalendar/report?date=$yesterday');
                },     
                isChecked: false,           
              ),
              _buildSettingOption(
                context,
                title: '맞춤형 운동 추천 확인',
                imagePath: 'assets/mission_icon/runner.png',
                onTap: () {
                  context.go('/homeCalendar/exerciseRecommendation');
                },
                isChecked: true,
              ),
              _buildSettingOption(
                context,
                title: '수면패턴에 따른 행동 추천 확인',
                imagePath: 'assets/mission_icon/recommendation.png',
                onTap: () {
                  context.go('/homeCalendar/sleepRecommendation');
                },
                isChecked: false,
              ),
            ],
          ),
        ),
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
        margin: const EdgeInsets.symmetric(vertical: 12),
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
              decoration: BoxDecoration(
                color: const Color(0xFF41af7a),
                borderRadius: const BorderRadius.only(
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
                          Opacity(
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
                          fontSize: 15,
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

}
