import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/widgets/calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeCalendarScreen extends StatelessWidget {
  const HomeCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '꽃이 되는 하루'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.go('/homeCalendar/mission');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Text(
                      '오늘 할 일',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CalendarWidget(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.6,
                children: [
                  _imgCard('내 건강 꽃발 일지\n보러 가기', 'assets/home_icon/flower_icon.png', Color(0xFFfff6d4), () {}),
                  _imgCard('데일리\n운동 영상', 'assets/home_icon/green_youtube.png', Color(0xFFdbf2e6), 
                            () {context.go('/homeCalendar/exvideo');}),
                  _imgCard('맞춤 운동\n추천', 'assets/home_icon/dumbell.png', Color(0xFFdbf2e6), () {}),
                  _imgCard('수면 패턴에\n따른 행동 추천', 'assets/home_icon/pillow.png', Color(0xFFfff6d4), () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgCard(String title, String imagePath, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(imagePath, width: 40, height: 40, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
