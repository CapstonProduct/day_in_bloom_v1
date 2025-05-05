import 'dart:convert';

import 'package:day_in_bloom_v1/utils/router_without_animation.dart';
import 'package:day_in_bloom_v1/widgets/navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  await FitbitAuthService.clearIfNotAutoLogin(); 

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );  

  FlutterNativeSplash.remove();
 
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  final fcmToken = await messaging.getToken();
  if (settings.authorizationStatus == AuthorizationStatus.authorized && fcmToken != null) {
    print('FCM Token: $fcmToken');
    await sendTokenToLambda(fcmToken);
  } else {
    print('FCM Token: null');
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _initializeLocalNotifications();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
		print('Got a message whilst in the foreground!');
		print('Message data: ${message.data}');
 
		if (message.notification != null) {
			print('Message also contained a notification: ${message.notification}');

      flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel_id',
            '기본 채널',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );

		}
	});

  runApp(const MyApp());
}

Future<void> sendTokenToLambda(String fcmToken) async {
  final url = Uri.parse('https://jxy6l8mwbh.execute-api.ap-northeast-2.amazonaws.com/dev/save-fcm-device-token');
  
  final Map<String, dynamic> data = {
    'fcmToken': fcmToken,
    'userId': 1,
    'platform': 'android',
  };

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    print('Token successfully sent to Lambda');
  } else {
    print('Failed to send token to Lambda: ${response.statusCode}');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: FitbitAuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final initialLocation = snapshot.data! ? '/main' : '/login';

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter(initialLocation),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko', 'KR'),
          ],
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const List<String> _routes = ['/main', '/homeCalendar', '/homeQna', '/homeSetting'];

  void _onItemTapped(int index) {
    context.go(_routes[index]);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}