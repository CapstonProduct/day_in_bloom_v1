import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InputUserInfoScreen extends StatefulWidget {
  const InputUserInfoScreen({super.key});

  @override
  _InputUserInfoScreenState createState() => _InputUserInfoScreenState();
}

class _InputUserInfoScreenState extends State<InputUserInfoScreen> {
  final Map<String, TextEditingController> _controllers = {
    "이름": TextEditingController(),
    "키 (cm)": TextEditingController(),
    "체중 (kg)": TextEditingController(),
  };

  String? _selectedGender;
  final List<String> _genders = ["남성", "여성"];
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1960, 1, 1),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.orange,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _onComplete() async {
    if (_controllers.values.any((controller) => controller.text.isEmpty) || 
        _selectedGender == null || 
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 정보를 입력해주세요.")),
      );
      return;
    }

    final encodedId = await FitbitAuthService.getUserId();

    final userInfo = {
      "username": _controllers["이름"]!.text.trim(),
      "height": _controllers["키 (cm)"]!.text.trim(),
      "weight": _controllers["체중 (kg)"]!.text.trim(),
      "birth_date": _formatDate(_selectedDate!),
      "gender": _selectedGender,
      "encodedId": encodedId,
      "role": "senior",
      "login_provider": "fitbit",
    };
    
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['USER_INFO_API_GATEWAY_URL']!), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userInfo),
      );

      final decodedBody = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        context.go('/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버 전송 실패: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("API 호출 에러: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("오류 발생: 서버와 통신 실패")),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                      TextSpan(text: "필수 사용자 정보", style: TextStyle(color: Colors.orange)),
                      TextSpan(text: "를 입력해주세요!"),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                for (var entry in _controllers.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: entry.key,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: entry.key == "이름" ? TextInputType.text : TextInputType.number,
                    ),
                  ),
                const SizedBox(height: 8),
                // 생년월일 선택 필드
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null 
                              ? "생년월일" 
                              : _formatDate(_selectedDate!),
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDate == null ? Colors.grey[600] : Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: _genders
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "성별 선택",
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                  ),
                  isDense: true,
                  isExpanded: true,
                  alignment: AlignmentDirectional.bottomStart,
                  dropdownColor: Colors.white,
                ),
                const SizedBox(height: 30),
                Text(
                  "입력하신 정보는 건강 분석에 활용되오니,\n반드시 정확한 정보를 입력해주세요 ^_^",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: _onComplete,
                    child: const Text(
                      "입력 완료",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}