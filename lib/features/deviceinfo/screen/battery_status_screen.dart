import 'package:flutter/material.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';

class BatteryStatusScreen extends StatelessWidget {
  const BatteryStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 기기 연결 데이터 예시
    final int batteryPercentage = 81;
    final String deviceName = "fitbit charge 5";
    final bool connectionStatus = true;
    final String lastSyncTime = "2024-03-24 08:15:00";

    // 기기 비연결 데이터 예시
    // final int batteryPercentage = 0;
    // final String deviceName = "--";
    // final bool connectionStatus = false;
    // final String lastSyncTime = "--";

    final String connectionMessage = connectionStatus
        ? "연결되어 있습니다"
        : "연결되지 않았습니다";

    final String batteryMessage = (batteryPercentage <= 0)
      ? "--"
      : (batteryPercentage <= 30)
          ? "배터리가 거의 없습니다.\n충전해주세요."
          : (batteryPercentage <= 60)
              ? "적당한 양의 배터리가 있습니다."
              : "배터리 레벨이 충분합니다!\n충전을 잘 해주셨네요.";

    return Scaffold(
      appBar: const CustomAppBar(title: "Fitbit 기기정보"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0E8E4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "$batteryPercentage%",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3C7),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                deviceName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: connectionStatus?Color(0xFFE2F0CB):Color(0xFFFFDAD9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    connectionMessage,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: connectionStatus?Color(0xFF2E7D32):Colors.red,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "마지막 동기화 시간: $lastSyncTime",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              batteryMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
