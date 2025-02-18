import 'package:day_in_bloom_v1/features/home/screen/screen2_detail.dart';
import 'package:day_in_bloom_v1/features/home/screen/screen3_detail.dart';
import 'package:day_in_bloom_v1/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:day_in_bloom_v1/features/home/screen/screen1.dart';
import 'package:day_in_bloom_v1/features/home/screen/screen1_detail.dart';
import 'package:day_in_bloom_v1/features/home/screen/screen2.dart';
import 'package:day_in_bloom_v1/features/home/screen/screen3.dart';
import 'package:day_in_bloom_v1/features/home/screen/screen1_deeptail.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => NoTransitionPage(child: Screen1()),
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
          path: '/screen2',
          pageBuilder: (context, state) => NoTransitionPage(child: Screen2()),
          routes: [
            GoRoute(
              path: 'detail',
              pageBuilder: (context, state) => NoTransitionPage(child: Screen2Detail()),
            ),
          ],
        ),
        GoRoute(
          path: '/screen3',
          pageBuilder: (context, state) => NoTransitionPage(child: Screen3()),
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
