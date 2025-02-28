import 'package:day_in_bloom_v1/features/healthreport/screen/report_category_screen.dart';
import 'package:day_in_bloom_v1/features/healthreport/screen/report_doctor_advice_screen.dart';
import 'package:day_in_bloom_v1/features/healthreport/screen/report_exercise_screen.dart';
import 'package:day_in_bloom_v1/features/healthreport/screen/report_family_advice_screen.dart';
import 'package:day_in_bloom_v1/features/healthreport/screen/report_sleep_screen.dart';
import 'package:day_in_bloom_v1/features/healthreport/screen/report_stress_score_screen.dart';
import 'package:day_in_bloom_v1/features/healthreport/screen/report_total_score_screen.dart';
import 'package:day_in_bloom_v1/features/mission/screen/exvideo_screen.dart';
import 'package:day_in_bloom_v1/features/mission/screen/mission_screen.dart';
import 'package:day_in_bloom_v1/features/notification/screen/notification_list_screen.dart';
import 'package:day_in_bloom_v1/features/setting/screen/logout_cancel_screen.dart';
import 'package:day_in_bloom_v1/features/setting/screen/medical_checkup_screen.dart';
import 'package:day_in_bloom_v1/features/setting/screen/modify_profile_screen.dart';
import 'package:day_in_bloom_v1/features/setting/screen/permission_screen.dart';
import 'package:day_in_bloom_v1/features/setting/screen/view_profile_screen.dart';
import 'package:day_in_bloom_v1/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:day_in_bloom_v1/features/home/screen/home_calender_screen.dart';
import 'package:day_in_bloom_v1/features/home/screen/home_qna_screen.dart';
import 'package:day_in_bloom_v1/features/home/screen/home_setting_screen.dart';

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
              path: 'mission',
              pageBuilder: (context, state) => NoTransitionPage(child: MissionScreen()),
            ),
            GoRoute(
              path: 'exvideo',
              pageBuilder: (context, state) => NoTransitionPage(child: ExvideoScreen()),
            ),
            GoRoute(
              path: 'notiList',
              pageBuilder: (context, state) => NoTransitionPage(child: NotificationListScreen()),
            ),
            GoRoute(
              path: 'report',
              pageBuilder: (context, state) => NoTransitionPage(child: ReportCategoryScreen()),
              routes: [
                GoRoute(
                  path: 'totalScore',
                  pageBuilder: (context, state) => NoTransitionPage(child: ReportTotalScoreScreen()),
                ),
                GoRoute(
                  path: 'stressScore',
                  pageBuilder: (context, state) => NoTransitionPage(child: ReportStressScoreScreen()),
                ),
                GoRoute(
                  path: 'exercise',
                  pageBuilder: (context, state) => NoTransitionPage(child: ReportExerciseScreen()),
                ),
                GoRoute(
                  path: 'sleep',
                  pageBuilder: (context, state) => NoTransitionPage(child: ReportSleepScreen()),
                ),
                GoRoute(
                  path: 'familyAdvice',
                  pageBuilder: (context, state) => NoTransitionPage(child: ReportFamilyAdviceScreen()),
                ),
                GoRoute(
                  path: 'doctorAdvice',
                  pageBuilder: (context, state) => NoTransitionPage(child: ReportDoctorAdviceScreen()),
                ),                                                       
              ]
            ),
          ],
        ),
        GoRoute(
          path: '/homeQna',
          pageBuilder: (context, state) => NoTransitionPage(child: HomeQnaScreen()),
        ),
        GoRoute(
          path: '/homeSetting',
          pageBuilder: (context, state) => NoTransitionPage(child: HomeSettingScreen()),
          routes: [
            GoRoute(
              path: 'viewProfile',
              pageBuilder: (context, state) => NoTransitionPage(child: ViewProfileScreen()),
              routes: [
                GoRoute(
                  path: 'modifyProfile',
                  pageBuilder: (context, state) => NoTransitionPage(child: ModifyProfileScreen()),
                ),
                GoRoute(
                  path: 'medCheckup',
                  pageBuilder: (context, state) => NoTransitionPage(child: MedicalCheckupScreen()),
                ),
              ]
            ),
            GoRoute(
              path: 'permission',
              pageBuilder: (context, state) => NoTransitionPage(child: PermissionScreen()),
            ),
            GoRoute(
              path: 'logoutAndCancel',
              pageBuilder: (context, state) => NoTransitionPage(child: LogoutCancelScreen()),
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
