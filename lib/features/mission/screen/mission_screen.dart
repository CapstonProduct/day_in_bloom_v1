import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '오늘 할 일'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSettingOption(
              context,
              title: '의사 양반과 대화하기',
              imagePath: 'assets/mission_icon/doctor.png',
              onTap: () {
                context.go('/homeSetting/detail');
              },
            ),
            _buildSettingOption(
              context,
              title: '맞춤 운동 5분 하기',
              imagePath: 'assets/mission_icon/runner.png',
              onTap: () {
                context.go('/homeSetting/detail');
              },
            ),
            _buildSettingOption(
              context,
              title: '매일 운동 따라하기',
              imagePath: 'assets/mission_icon/elderly.png',
              onTap: () {
                context.go('/homeSetting/detail');
              },
            ),
            _buildSettingOption(
              context,
              title: '리포트 확인하기',
              imagePath: 'assets/mission_icon/report.png',
              onTap: () {
                context.go('/homeSetting/detail');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption(
    BuildContext context, {
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFFf6f9f7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
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
                color: Color(0xFF41af7a),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Image.asset(
                      imagePath,
                      width: 45,
                      height: 45,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
