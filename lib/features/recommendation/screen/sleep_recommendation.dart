import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class SleepRecommendationScreen extends StatefulWidget {
  const SleepRecommendationScreen({super.key});

  @override
  State<SleepRecommendationScreen> createState() => _SleepRecommendationScreenState();
}

class _SleepRecommendationScreenState extends State<SleepRecommendationScreen> {
  late Future<Map<String, String>> _sleepData;
  final String _selectedDate = _formattedToday;

  static const String _defaultMessage = "데이터를 불러올 수 없습니다. 네트워크를 확인해주세요.";
  static const String _apiUrl =
      "https://qrb5wu1rjh.execute-api.ap-northeast-2.amazonaws.com/dev/sleep-recommendation";

  static const Map<String, String> _defaultSleepData = {
    "monthly": _defaultMessage,
    "yesterday": _defaultMessage,
    "recommendation": _defaultMessage,
  };

  static String get _formattedToday {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

  double _progressValue = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _startFakeProgress();
    _sleepData = _fetchSleepData();
  }

  void _startFakeProgress() {
    _progressValue = 0.0;
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      setState(() {
        if (_progressValue < 1.0) {
          _progressValue += 0.02;
        } else {
          _progressTimer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<Map<String, String>> _fetchSleepData() async {
    try {
      final encodedId = await FitbitAuthService.getUserId();
      if (encodedId == null) throw Exception("사용자 ID를 찾을 수 없습니다.");

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "encodedId": encodedId,
          "date": _selectedDate,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("수면 데이터를 불러오지 못했습니다.");
      }

      final jsonData = json.decode(response.body);

      return {
        "monthly": jsonData['sleep_month_analysis'] ?? _defaultMessage,
        "yesterday": jsonData['sleep_yesterday_analysis'] ?? _defaultMessage,
        "recommendation": jsonData['sleep_recommendation'] ?? _defaultMessage,
      };
    } catch (_) {
      return _defaultSleepData;
    }
  }

  Future<void> _refreshSleepData() async {
    setState(() {
      _startFakeProgress();
      _sleepData = _fetchSleepData();
    });
  }

  Widget _buildBox(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green, width: 1.5),
          ),
          child: Text(
            description,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "수면 행동 추천"),
      body: RefreshIndicator(
        onRefresh: _refreshSleepData,
        color: Colors.green,
        child: FutureBuilder<Map<String, String>>(
          future: _sleepData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "수면 추천 데이터를 불러오는 중이에요...\n최대 30초 정도 걸릴 수 있어요!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: _progressValue,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${(_progressValue * 100).toInt()}% 완료",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data ?? _defaultSleepData;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  _buildBox("✅ 한 달 간 수면 분석", data["monthly"]!),
                  const SizedBox(height: 20),
                  _buildBox("✅ 어제의 수면 분석", data["yesterday"]!),
                  const SizedBox(height: 20),
                  _buildBox("✅ 양질의 수면을 위한 행동 / 주의사항", data["recommendation"]!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
