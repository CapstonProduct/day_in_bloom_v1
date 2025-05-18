import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final encodedId = await FitbitAuthService.getUserId();
    if (encodedId == null) return;

    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    final response = await http.post(
      Uri.parse('https://d8ive2hn0h.execute-api.ap-northeast-2.amazonaws.com/dev/notification-list'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'encodedId': encodedId, 'date': today}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        setState(() {
          _notifications = decoded.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('알림 불러오기 실패: ${response.body}')),
      );
    }
  }

  String _formatTime(String dateTime) {
    final parsedTime = DateTime.parse(dateTime);
    return DateFormat('MM월 dd일 HH:mm').format(parsedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '알림 목록', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              color: Colors.green,
              child: ListView.builder(
                itemCount: _notifications.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final isRead = notification['is_read'] == true || notification['is_read'] == 1;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.grey[200] : Colors.yellow[100],
                      border: const Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['message'],
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification['sent_at']),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
