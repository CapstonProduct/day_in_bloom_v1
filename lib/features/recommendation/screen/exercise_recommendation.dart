import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';

class ExerciseRecommendationScreen extends StatefulWidget {
  const ExerciseRecommendationScreen({super.key});

  @override
  State<ExerciseRecommendationScreen> createState() =>
      _ExerciseRecommendationScreenState();
}

class _ExerciseRecommendationScreenState
    extends State<ExerciseRecommendationScreen> {
  late Future<Map<String, String>> _exerciseData;
  late final String _selectedDate;

  static const _defaultMessage = "데이터를 로딩할 수 없습니다. 네트워크 연결을 확인하세요.";
  static const _apiUrl =
      "https://l7p03a7vy0.execute-api.ap-northeast-2.amazonaws.com/dev/exercise-recommendation";

  static const Map<String, String> _defaultExerciseData = {
    "monthly": _defaultMessage,
    "yesterday": _defaultMessage,
    "recommendation": _defaultMessage,
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = _getTodayDateFormatted();
    _exerciseData = _loadExerciseData();
  }

  String _getTodayDateFormatted() {
    final today = DateTime.now();
    return "${today.year.toString().padLeft(4, '0')}-"
        "${today.month.toString().padLeft(2, '0')}-"
        "${today.day.toString().padLeft(2, '0')}";
  }

  Future<Map<String, String>> _loadExerciseData() async {
    try {
      final encodedId = await FitbitAuthService.getUserId();
      if (encodedId == null) throw Exception("User ID is null");
      return await _fetchExerciseData(encodedId);
    } catch (e) {
      debugPrint('Error fetching exercise data: $e');
      return _defaultExerciseData;
    }
  }

  Future<Map<String, String>> _fetchExerciseData(String encodedId) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "encodedId": encodedId,
          "date": _selectedDate,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to load data. Status: ${response.statusCode}");
      }

      final jsonData = json.decode(response.body);
      return {
        "monthly": jsonData['exercise_month_analysis'] ?? _defaultMessage,
        "yesterday": jsonData['exercise_yesterday_analysis'] ?? _defaultMessage,
        "recommendation": jsonData['exercise_recommendation'] ?? _defaultMessage,
      };
    } catch (e) {
      debugPrint('API error: $e');
      return _defaultExerciseData;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _exerciseData = _loadExerciseData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "맞춤 운동 추천"),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<Map<String, String>>(
          future: _exerciseData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ?? _defaultExerciseData;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  _buildExerciseBox("✅ 한달 간 운동 분석", data["monthly"]!),
                  const SizedBox(height: 20),
                  _buildExerciseBox("✅ 어제의 운동 분석", data["yesterday"]!),
                  const SizedBox(height: 20),
                  _buildExerciseBox("✅ 추천하는 운동 / 주의사항", data["recommendation"]!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExerciseBox(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade400, width: 1.5),
          ),
          child: Text(
            description,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
