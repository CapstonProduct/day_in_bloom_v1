import 'dart:convert';

import 'package:day_in_bloom_v1/utils/fcm_service.dart';
import 'package:day_in_bloom_v1/utils/router_without_animation.dart';
import 'package:day_in_bloom_v1/widgets/navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final token = message.data['access_token'];
  if (token != null) {
    final storage = FlutterSecureStorage();
    await storage.write(key: 'access_token', value: token);
    print('[FCM] Access token updated in background.');
    
    final savedToken = await storage.read(key: 'access_token');
    print('[Storage] Saved access token: $savedToken');   
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  await FitbitAuthService.clearIfNotAutoLogin(); 

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );  

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterNativeSplash.remove();
 
  await FCMService.init();

  runApp(const MyApp());
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
          locale: const Locale('ko', 'KR'),
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