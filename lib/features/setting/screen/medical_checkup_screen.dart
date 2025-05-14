import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:intl/intl.dart';

class MedicalCheckupScreen extends StatefulWidget {
  const MedicalCheckupScreen({super.key});

  @override
  State<MedicalCheckupScreen> createState() => _MedicalCheckupScreenState();
}

class _MedicalCheckupScreenState extends State<MedicalCheckupScreen> {
  Map<String, dynamic>? checkupData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCheckupData();
  }

  Future<void> _fetchCheckupData() async {
    final encodedId = await FitbitAuthService.getUserId();
    if (encodedId == null) return;

    final response = await http.post(
      Uri.parse('https://8z2vi9uqb9.execute-api.ap-northeast-2.amazonaws.com/dev/medical-checkup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'encodedId': encodedId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        checkupData = jsonDecode(response.body);
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
    await _fetchCheckupData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '건강검진 내역', showBackButton: true),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.green,
        backgroundColor: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : checkupData == null
                ? const Center(child: Text('건강검진 데이터를 불러올 수 없습니다.'))
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildItem('이름', checkupData!['username']),
                      _buildItem('검진 날짜', _formatDate(checkupData!['checkup_date'])),
                      _buildItem('신장', _format(checkupData!['height'], 'cm')),
                      _buildItem('체중', _format(checkupData!['weight'], 'kg')),
                      _buildItem('체질량 지수', _format(checkupData!['bmi'], 'kg/m²')),
                      _buildItem('혈압 (최고/최저)', '${checkupData!['blood_pressure']} mmHg'),
                      _buildItem('공복 혈당', _format(checkupData!['fasting_blood_sugar'], 'mg/dL')),
                      _buildItem('총 콜레스테롤', _format(checkupData!['total_cholesterol'], 'mg/dL')),
                      _buildItem('HDL 콜레스테롤', _format(checkupData!['hdl_cholesterol'], 'mg/dL')),
                      _buildItem('LDL 콜레스테롤', _format(checkupData!['ldl_cholesterol'], 'mg/dL')),
                      _buildItem('중성지방', _format(checkupData!['triglyceride'], 'mg/dL')),
                      _buildItem('신사구체 여과율 (GFR)', _format(checkupData!['gfr'], 'mL/min/1.73m²')),
                      _buildItem('AST (간 기능)', _format(checkupData!['ast'], 'U/L')),
                      _buildItem('ALT (간 기능)', _format(checkupData!['alt'], 'U/L')),
                    ],
                  ),
      ),
    );
  }

  String _format(dynamic value, String unit) {
    if (value == null) return '-';
    if (value is num) {
      return '${value.toStringAsFixed(1)} $unit';
    }
    return '$value $unit';
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return rawDate;
    }
  }

  Widget _buildItem(String label, String value) {
    return Container(
      color: (label.hashCode % 2 == 0) ? Colors.grey[100] : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '• $label',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
