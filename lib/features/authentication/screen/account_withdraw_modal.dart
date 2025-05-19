import 'dart:convert';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AccountWithdrawModal extends StatelessWidget {
  final BuildContext parentContext;

  const AccountWithdrawModal({super.key, required this.parentContext});

  static void show(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AccountWithdrawModal(parentContext: parentContext);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: const Text(
        '탈퇴 시 주의사항',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '회원 탈퇴를 진행하시면\n다음 사항이 적용됩니다:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 12),
          Text(
            '• 계정 및 모든 개인 정보가 영구적으로 삭제됩니다.\n'
            '• 저장된 데이터(건강 기록, 대화 내역 등)는 복구할 수 없습니다.\n'
            '• 가입된 서비스 및 혜택을 다시 이용하려면 새로운 계정이 필요합니다.\n',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            '정말 탈퇴하시겠습니까? 😢',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '※ 탈퇴 후에도 관련 법령에 따라 일정 기간 보관되는 정보가 있을 수 있습니다.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); 
            await deleteUserAndLogout(); 
          },
          child: const Text('예', style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('돌아가기', style: TextStyle(color: Colors.purple)),
        ),
      ],
    );
  }

  Future<void> deleteUserAndLogout() async {
    try {
      final encodedId = await FitbitAuthService.getUserId();

      final response = await http.post(
        Uri.parse(dotenv.env['DELETE_USER_API_GATEWAY_URL']!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"encodedId": encodedId}),
      );

      if (response.statusCode == 200) {
        await FitbitAuthService.logout();
        if (parentContext.mounted) {
          parentContext.go('/login');
        }
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(content: Text("탈퇴 실패: ${error['message'] ?? response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text("에러 발생: $e")),
      );
    }
  }
}
