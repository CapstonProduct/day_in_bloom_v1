import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Text("로그인 정보 없음");
          }

          final accessToken = snapshot.data![0] as String?;
          final userId = snapshot.data![1] as String?;
          final refreshToken = snapshot.data![2] as String?;

          return Column(
            children: [
              if (accessToken != null)
                Text(
                  "Access Token: $accessToken",
                  style: const TextStyle(fontSize: 12),
                ),
              if (refreshToken != null)
                Text(
                  "Refresh Token: $refreshToken",
                  style: const TextStyle(fontSize: 12),
                ),
              if (userId != null)
                Text(
                  "User ID: $userId",
                  style: const TextStyle(fontSize: 12),
                ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            final yesterday = DateFormat('yyyy-MM-dd').format(
                              DateTime.now().subtract(const Duration(days: 1)),
                            );
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
              ),
            ],
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
}
