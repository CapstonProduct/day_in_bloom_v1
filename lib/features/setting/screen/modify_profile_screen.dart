import 'dart:convert';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class ModifyProfileScreen extends StatefulWidget {
  const ModifyProfileScreen({super.key});

  @override
  _ModifyProfileScreenState createState() => _ModifyProfileScreenState();
}

class _ModifyProfileScreenState extends State<ModifyProfileScreen> {
  final List<bool> _isGenderSelected = [true, false];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  final TextEditingController _phone3Controller = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _breakfastController = TextEditingController();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();

  String encodedId = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    encodedId = await FitbitAuthService.getUserId() ?? '';
    if (encodedId.isEmpty) return;

    final response = await http.post(
      Uri.parse('https://kqaqrbzkhg.execute-api.ap-northeast-2.amazonaws.com/default/view-profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'encodedId': encodedId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _nameController.text = data['username'] ?? '';
        _birthController.text = (data['birth_date'] ?? '').toString().split('T').first;
        _isGenderSelected[0] = data['gender'] == '남성';
        _isGenderSelected[1] = data['gender'] == '여성';
        _addressController.text = data['address'] ?? '';

        final phoneParts = (data['phone_number'] ?? '').split('-');
        if (phoneParts.length == 3) {
          _phone1Controller.text = phoneParts[0];
          _phone2Controller.text = phoneParts[1];
          _phone3Controller.text = phoneParts[2];
        }

        final height = data['height'];
        _heightController.text = height is num ? height.toStringAsFixed(1) : '';

        _weightController.text = data['weight']?.toString() ?? '';
        _breakfastController.text = data['breakfast_time'] ?? '';
        _lunchController.text = data['lunch_time'] ?? '';
        _dinnerController.text = data['dinner_time'] ?? '';
      });
    }
  }

  Future<void> _submitProfile() async {
    final response = await http.post(
      Uri.parse('https://270f8pu826.execute-api.ap-northeast-2.amazonaws.com/dev/modify-profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'encodedId': encodedId,
        'username': _nameController.text,
        'birth_date': _birthController.text,
        'gender': _isGenderSelected[0] ? '남성' : '여성',
        'address': _addressController.text,
        'phone_number': '${_phone1Controller.text}-${_phone2Controller.text}-${_phone3Controller.text}',
        'height': double.tryParse(_heightController.text),
        'weight': double.tryParse(_weightController.text),
        'breakfast_time': _breakfastController.text,
        'lunch_time': _lunchController.text,
        'dinner_time': _dinnerController.text,
      }),
    );

    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 성공적으로 수정되었습니다.')),
      );
      context.pushReplacement('/homeSetting/viewProfile');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정 실패: ${response.body}')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _addressController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _phone3Controller.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '내 정보 수정', showBackButton: true),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildSection('기본 정보', [
              _buildTextField('이름         ', _nameController),
              const SizedBox(height: 10),
              _buildTextField('생년월일  ', _birthController),
              const SizedBox(height: 10),
              _buildToggleLabel('성별         ', _isGenderSelected, ['남성', '여성'], (index) {
                setState(() {
                  for (int i = 0; i < _isGenderSelected.length; i++) {
                    _isGenderSelected[i] = (i == index);
                  }
                });
              }),
              const SizedBox(height: 10),
              _buildTextField('주소         ', _addressController),
              _buildPhoneNumberField(),
              _buildHeightWeightField(),
            ]),
            const SizedBox(height: 16),
            _buildSection('추가 정보', [
              _buildTextField('아침시간 ', _breakfastController),
              _buildTextField('점심시간 ', _lunchController),
              _buildTextField('저녁시간 ', _dinnerController),
            ]),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submitProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                ),
                child: const Text('정보 수정 완료', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/profile_icon/green_profile.png'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text('이미지 삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleLabel(String label, List<bool> isSelected, List<String> labels, Function(int) onPressed) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        ToggleButtons(
          borderRadius: BorderRadius.circular(8),
          constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
          isSelected: isSelected,
          onPressed: onPressed,
          children: labels.map((e) => Text(e)).toList(),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Row(
      children: [
        const Text("전화번호", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: _buildTextField('', _phone1Controller)),
        const SizedBox(width: 10),
        const Text("-"),
        Expanded(child: _buildTextField('', _phone2Controller)),
        const SizedBox(width: 10),
        const Text("-"),
        Expanded(child: _buildTextField('', _phone3Controller)),
      ],
    );
  }

  Widget _buildHeightWeightField() {
    return Row(
      children: [
        Expanded(child: _buildTextField('신장 (cm)', _heightController)),
        const SizedBox(width: 10),
        Expanded(child: _buildTextField('체중 (kg)', _weightController)),
      ],
    );
  }
}
