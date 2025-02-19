import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Screen1Detail extends StatelessWidget {
  const Screen1Detail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Detail1', showBackButton: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Screen 1 Detail View'),
            ElevatedButton(
              onPressed: () {
                context.go('/homeCalendar/detail/deeptail');
              },
              child: Text('Go to Deep Detail'),
            ),
          ],
        ),
      ),      
    );
  }
}