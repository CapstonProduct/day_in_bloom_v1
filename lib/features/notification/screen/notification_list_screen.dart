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

    try {
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
          
          // Debug: Check if notifications have IDs
          for (var notification in _notifications) {
            final id = notification['id'] ?? notification['notification_id'];
            if (id == null) {
              print('WARNING: Notification missing ID: $notification');
            }
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알림 불러오기 실패: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('알림 불러오기 중 오류 발생: $e')),
      );
    }
  }

  Future<void> _markAsRead(int notificationId, int index) async {
    final encodedId = await FitbitAuthService.getUserId();
    if (encodedId == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://e1tbu7jvyh.execute-api.ap-northeast-2.amazonaws.com/Prod/change-is-read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'encodedId': encodedId,
          'notificationId': notificationId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _notifications[index]['is_read'] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('알림을 읽음으로 처리했습니다'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Mark as read failed. Status: ${response.statusCode}, Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알림 읽음 처리 실패')),
        );
      }
    } catch (e) {
      print('Error in _markAsRead: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  String _formatTime(String dateTime) {
    try {
      final parsedTime = DateTime.parse(dateTime);
      return DateFormat('MM월 dd일 HH:mm').format(parsedTime);
    } catch (e) {
      print('Error parsing date: $dateTime, Error: $e');
      return dateTime; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '알림 목록', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    '알림이 없습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  color: Colors.green,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isRead = notification['is_read'] == true || notification['is_read'] == 1;
                      final notificationId = notification['id'] ?? notification['notification_id'];

                      return GestureDetector(
                        onTap: () async {
                          print('=== 알림 클릭됨 ===');
                          print('notification 전체 데이터: $notification');
                          print('isRead: $isRead');
                          print('notificationId: $notificationId');
                          
                          if (notificationId != null) {
                            print('notificationId가 존재함. API 호출 시작...');
                            await _markAsRead(notificationId, index);
                          } else {
                            print('ERROR: notificationId가 null입니다!');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('알림 ID를 찾을 수 없습니다. 서버 응답을 확인해주세요.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Container(
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
                                notification['message'] ?? '메시지가 없습니다',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(notification['sent_at'] ?? ''),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              // Only show debug info in debug mode
                              if (notificationId == null) 
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '알림 ID 누락 - 서버 응답 확인 필요',
                                    style: TextStyle(
                                      fontSize: 10, 
                                      color: Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}