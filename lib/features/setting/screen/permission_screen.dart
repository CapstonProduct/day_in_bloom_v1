import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  late Future<Map<String, bool>> _alertPermissions;

  final String getPermissionUrl = dotenv.env['GET_PERMISSION_API_GATEWAY_URL']!;
  final String updatePermissionUrl = dotenv.env['UPDATE_PERMISSION_API_GATEWAY_URL']!;

  @override
  void initState() {
    super.initState();
    _alertPermissions = fetchAlertPermissions();
  }

  Future<Map<String, bool>> fetchAlertPermissions() async {
    final encodedId = await FitbitAuthService.getUserId();

    final response = await http.post(
      Uri.parse(getPermissionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'encodedId': encodedId}),
    );

    if (response.statusCode != 200) {
      throw Exception('알림 데이터를 불러오지 못했습니다.');
    }

    final List<dynamic> alerts = jsonDecode(response.body)['alerts'];

    return {
      for (var alert in alerts)
        _translateAlertType(alert['alert_type']): alert['is_enabled'] == 1,
    };
  }

  Future<void> updateAlert(String alertType, bool isEnabled) async {
    final encodedId = await FitbitAuthService.getUserId();

    await http.post(
      Uri.parse(updatePermissionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'encodedId': encodedId,
        'alert_type': alertType,
        'is_enabled': isEnabled,
      }),
    );
  }

  String _translateAlertType(String type) {
    switch (type) {
      case 'meal_reminder':
        return '식사 시간 알림';
      case 'morning_alert':
        return '아침 안부 알림';
      case 'report_ready':
        return '리포트 생성 알림';
      case 'anomaly_alert':
        return '이상 징후 알림';
      case 'advice_alert':
        return '조언 추가 알림';
      case 'sleep_alert':
        return '수면 알림';             
      case 'exercise_alert':
        return '운동 알림';            
      case 'device_connect':
        return '기기 연결 알림';   
      case 'device_battery':
        return '기기 배터리 알림'; 
      default:
        return type;
    }
  }

  String _translateToEnum(String display) {
    switch (display) {
      case '식사 시간 알림':
        return 'meal_reminder';
      case '아침 안부 알림':
        return 'morning_alert';
      case '리포트 생성 알림':
        return 'report_ready';
      case '이상 징후 알림':
        return 'anomaly_alert';
      case '조언 추가 알림':
        return 'advice_alert';
      case '수면 알림':
        return 'sleep_alert';  
      case '운동 알림':
        return 'exercise_alert';   
      case '기기 연결 알림':
        return 'device_connect';  
      case '기기 배터리 알림':
        return 'device_battery';   
      default:
        return display;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _alertPermissions = fetchAlertPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '알림 설정', showBackButton: true),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<Map<String, bool>>(
          future: _alertPermissions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            } else if (snapshot.hasError) {
              return Center(child: Text('오류: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('데이터 없음'));
            }

            final permissions = snapshot.data!;
            final keys = permissions.keys.toList();

            return ListView.builder(
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final label = keys[index];
                final value = permissions[label]!;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                  color: index.isEven ? Colors.grey[200] : Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 16)),
                      Switch(
                        value: value,
                        onChanged: (bool newValue) {
                          final updatedType = _translateToEnum(label);
                          setState(() {
                            permissions[label] = newValue;
                          });
                          updateAlert(updatedType, newValue);
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
