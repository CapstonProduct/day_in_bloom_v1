import 'package:day_in_bloom_v1/features/home/screen/screen2_detail.dart';
import 'package:day_in_bloom_v1/features/home/screen/screen3_detail.dart';
import 'package:day_in_bloom_v1/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:day_in_bloom_v1/features/home/screen/home_calender_screen.dart';
import 'package:day_in_bloom_v1/features/home/screen/screen1_detail.dart';
import 'package:day_in_bloom_v1/features/home/screen/home_qna_screen.dart';
import 'package:day_in_bloom_v1/features/home/screen/home_setting_screen.dart';
import 'package:day_in_bloom_v1/features/home/screen/screen1_deeptail.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/homeCalendar',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/homeCalendar',
          pageBuilder: (context, state) => NoTransitionPage(child: HomeCalendarScreen()),
          routes: [
            GoRoute(
              path: 'detail',
              pageBuilder: (context, state) => NoTransitionPage(child: Screen1Detail()),
              routes: [
                GoRoute(
                  path: 'deeptail',
                  pageBuilder: (context, state) => NoTransitionPage(child: Screen1DeepDetail()),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/homeQna',
          pageBuilder: (context, state) => NoTransitionPage(child: HomeQnaScreen()),
          routes: [
            GoRoute(
              path: 'detail',
              pageBuilder: (context, state) => NoTransitionPage(child: Screen2Detail()),
            ),
          ],
        ),
        GoRoute(
          path: '/homeSetting',
          pageBuilder: (context, state) => NoTransitionPage(child: HomeSettingScreen()),
          routes: [
            GoRoute(
              path: 'detail',
              pageBuilder: (context, state) => NoTransitionPage(child: Screen3Detail()),
            ),
          ],
        ),
      ],
    ),
  ],
);

class NoTransitionPage extends CustomTransitionPage {
  NoTransitionPage({required Widget child})
      : super(
          child: child,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
        );
}
