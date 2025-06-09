import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
  });

  Color _getBatteryIndicatorColor() {
    int batteryStatus = 90;
    if (batteryStatus > 60) {
      return Colors.green;
    } else if (batteryStatus > 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  int _getBatteryLevel() {
    return 90; // 실제로는 배터리 상태를 가져오는 로직이 필요
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
                  // 배터리 레벨 텍스트
                  Text(
                    '${_getBatteryLevel()}%',
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
          // 앱 제목
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
      leading: showBackButton ? const BackButton(color: Colors.black) : null,
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}