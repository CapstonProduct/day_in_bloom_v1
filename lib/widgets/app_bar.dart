import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  int _batteryLevel = 0;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchBatteryLevel();
  }

  Future<void> _fetchBatteryLevel() async {
    try {
      final encodedId = await FitbitAuthService.getUserId();
      if (encodedId == null) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('https://s7vy3inb6e.execute-api.ap-northeast-2.amazonaws.com/dev/battery-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'encodedId': encodedId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawBattery = data['battery_level'] ?? '';
        final batteryLevel = int.tryParse(rawBattery.toString().replaceAll('%', '')) ?? 0;
        
        setState(() {
          _batteryLevel = batteryLevel;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Color _getBatteryIndicatorColor() {
    if (_hasError || _isLoading) {
      return Colors.grey;
    }
    
    if (_batteryLevel > 60) {
      return Colors.green;
    } else if (_batteryLevel > 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String _getBatteryDisplayText() {
    if (_isLoading) {
      return '...';
    } else if (_hasError || _batteryLevel <= 0) {
      return '--';
    } else {
      return '${_batteryLevel}%';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/battery_img/watch.png",
            width: 20,
            height: 20,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.watch_later_outlined,
                size: 12,
                color: Colors.black54,
              );
            },
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              context.go('/homeCalendar/batteryStatus');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getBatteryIndicatorColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getBatteryDisplayText(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
      leading: widget.showBackButton ? const BackButton(color: Colors.black) : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
          onPressed: () {
            context.go('/homeCalendar/notiList');
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.black),
          onPressed: () {
            context.go('/homeSetting/viewProfile');
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.grey[300],
          height: 1,
        ),
      ),
    );
  }
}