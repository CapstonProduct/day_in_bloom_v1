import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class BatteryStatusScreen extends StatefulWidget {
  const BatteryStatusScreen({super.key});

  @override
  State<BatteryStatusScreen> createState() => _BatteryStatusScreenState();
}

class _BatteryStatusScreenState extends State<BatteryStatusScreen> {
  Map<String, dynamic>? deviceData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDeviceData();
  }

  Future<void> _fetchDeviceData() async {
    final encodedId = await FitbitAuthService.getUserId();
    if (encodedId == null) return;

    final response = await http.post(
      Uri.parse('https://s7vy3inb6e.execute-api.ap-northeast-2.amazonaws.com/dev/battery-status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'encodedId': encodedId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        deviceData = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오지 못했습니다: ${response.body}')),
      );
    }
  }

  Future<void> _refreshData() async {
    await _fetchDeviceData();
  }

  @override
  Widget build(BuildContext context) {
    final rawBattery = deviceData?['battery_level'] ?? '';
    final batteryLevel = int.tryParse(rawBattery.replaceAll('%', '')) ?? 0;
    final deviceName = deviceData?['device_version'] ?? '--';
    final rawSyncTime = deviceData?['last_sync_time']?.toString() ?? '--';
    final lastSync = rawSyncTime.replaceFirst('T', ' ').split('.')[0];
    final isConnected = batteryLevel > 0;

    final connectionMessage = isConnected ? "연결되어 있습니다" : "연결되지 않았습니다";
    final batteryMessage = (batteryLevel <= 0)
        ? "--"
        : (batteryLevel <= 30)
            ? "배터리가 거의 없습니다.\n충전해주세요."
            : (batteryLevel <= 60)
                ? "적당한 양의 배터리가 있습니다."
                : "배터리 레벨이 충분합니다!\n충전을 잘 해주셨네요.";

    return Scaffold(
      appBar: const CustomAppBar(title: "Fitbit 기기정보"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.green,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                            "$batteryLevel%",
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
                        color: isConnected ? const Color(0xFFE2F0CB) : const Color(0xFFFFDAD9),
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
                              color: isConnected ? const Color(0xFF2E7D32) : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "마지막 동기화 시간: $lastSync",
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
            ),
    );
  }
}
