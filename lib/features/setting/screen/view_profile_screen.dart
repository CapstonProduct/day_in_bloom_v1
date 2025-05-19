import 'dart:convert';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  late Future<Map<String, dynamic>> _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = fetchProfileData();
  }

  Future<Map<String, dynamic>> fetchProfileData() async {
    final encodedId = await FitbitAuthService.getUserId();

    if (encodedId == null) {
      throw Exception("사용자 ID를 가져올 수 없습니다.");
    }

    final response = await http.post(
      Uri.parse('https://kqaqrbzkhg.execute-api.ap-northeast-2.amazonaws.com/default/view-profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'encodedId': encodedId}),
    );

    if (response.statusCode != 200) {
      throw Exception('프로필 로드 실패: ${response.body}');
    }

    return json.decode(response.body);
  }

  Future<void> _refreshData() async {
    setState(() {
      _profileData = fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '내 정보 보기', showBackButton: true),
      backgroundColor: Colors.grey[200],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.green,
        backgroundColor: Colors.white,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            } else if (snapshot.hasError) {
              return Center(child: Text('오류 발생: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('데이터가 없습니다.'));
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // pull-to-refresh 적용 위해 필요
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(data),
                  const SizedBox(height: 16),
                  _buildInfoSection(data),
                  const SizedBox(height: 16),
                  _buildMealAndCheckupRow(data),
                  const SizedBox(height: 16),
                  _buildCodeSection(data),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> data) {
    final birthDate = (data['birth_date'] ?? '').toString().split('T').first;

    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          backgroundImage: data['profile_image_url'] != null
              ? NetworkImage(data['profile_image_url'])
              : const AssetImage('assets/profile_icon/green_profile.png') as ImageProvider,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['username'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(birthDate),
            Text(data['gender']),
          ],
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            context.go('/homeSetting/viewProfile/modifyProfile');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.green,
            side: const BorderSide(color: Colors.green, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
          ),
          child: const Text('내 정보 수정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    final height = data['height'];
    final formattedHeight = height is num ? height.toStringAsFixed(1) : '-';

    return _buildInfoContainer('기본 정보', [
      _buildInfoItem('주소', data['address'] ?? '-'),
      _buildInfoItem('전화번호', data['phone_number'] ?? '-'),
      _buildInfoItem('신장 / 체중', '$formattedHeight cm / ${data['weight'] ?? '-'} kg'),
    ]);
  }

  Widget _buildMealAndCheckupRow(Map<String, dynamic> data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInfoContainer('추가 정보', [
            _buildInfoItem('아침시간', data['breakfast_time'] ?? '-'),
            _buildInfoItem('점심시간', data['lunch_time'] ?? '-'),
            _buildInfoItem('저녁시간', data['dinner_time'] ?? '-'),
          ]),
        ),
      ],
    );
  }

  Widget _buildCodeSection(Map<String, dynamic> data) {
    return _buildInfoContainer(
      '고유 코드 보기',
      [
        _buildInfoItem('보호자 고유 코드', data['guardian_code'] ?? '-'),
        _buildInfoItem('의사 고유 코드', data['doctor_code'] ?? '-'),
      ],
      onHelpPressed: () => _showHelpDialog(context),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '보호자 고유 코드란?',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [          
            Text(
              '• 보호자에게는 보호자 고유코드(형식: xxx112),\n'
              '• 의사에게는 의사 고유코드(형식: ddd112)를\n  제공하세요.',
            ),
            SizedBox(height: 10),
            Text(
              '어르신의 고유 코드를 받은 사용자는\n어르신의 건강 정보를 열람하고, 어르신께 '
              '건강 관련 조언 및 응원을 남길 수 있습니다!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              '⚠ 주의사항  ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              textAlign: TextAlign.center,
            ),
            Text(
              '보호자나 의사가 아닌 사람에게 고유 코드를\n제공하지 마세요!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
            ),
            child: const Text(
              '확인', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(String title, List<Widget> children, {VoidCallback? onHelpPressed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (onHelpPressed != null)
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: onHelpPressed,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: ListTile.divideTiles(
              context: context,
              color: Colors.grey.shade300,
              tiles: children,
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}
