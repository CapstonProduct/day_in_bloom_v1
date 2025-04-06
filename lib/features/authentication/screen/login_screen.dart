import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  final List<String> guideTexts = [
    "1. Fitbit 로그인 버튼을 누른 후\nGoogle 아이디로 로그인하세요.",
    "2. Google 계정의 비밀번호를 입력하세요.",
    "3. Google 서비스 약관을 확인하고,\n필요한 부분에 동의하세요.",
    "4. Fitbit 추가 서비스 약관과\n개인정보에 관한 사항을 확인하세요."
  ];

  bool isFirstLogin = true;

  bool _autoLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                      TextSpan(text: "Fitbit 로그인 가이드", style: TextStyle(color: Colors.orange)),
                      TextSpan(text: "를 확인하고\n로그인해 보세요!"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: guideTexts.length,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  guideTexts[index],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/login_guide_img/guide${index + 1}.png',
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: guideTexts.length,
                  effect: const WormEffect(
                    activeDotColor: Colors.orange,
                    dotHeight: 6,
                    dotWidth: 6,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _autoLogin,
                      onChanged: (value) {
                        setState(() {
                          _autoLogin = value!;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                    const Text(
                      "자동 로그인은 네모를 클릭해주세요.",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),                      
                      onPressed: () async {
                        try {
                          final result = await FitbitAuthService.loginWithFitbit(autoLogin: _autoLogin);
                          final alreadyEntered = await FitbitAuthService.isUserInfoEntered();
                          if (!mounted) return;

                          if (!alreadyEntered) {
                            context.go('/login/inputUserInfo');
                          } else {
                            context.go('/main');
                          }
                        } catch (e) {
                          print("로그인 에러: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("로그인 실패. 다시 시도해주세요.")),
                          );
                        }
                      },
                      child: const Text(
                        "Fitbit 로그인",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
