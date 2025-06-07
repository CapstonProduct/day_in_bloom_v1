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
    "1. 하단 주황색 Fitbit 로그인 버튼을\n누른 후, 'Google로 계속' 버튼을\n클릭하세요",
    "2. Google 계정 정보를\n입력하세요.",
    "3. 첫 로그인 이후에는\n저장된 Google 계정으로\n간편하게 로그인 할 수 있어요.",
  ];
  
  bool _autoLogin = false;
  bool _isLoading = false;

  // 예쁜 로딩 모달을 띄우는 함수
  void _showLoadingModal() {
    showDialog(
      context: context,
      barrierDismissible: false, // 뒤로가기나 바깥 터치로 닫히지 않게
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 로딩 애니메이션
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 메시지
                const Text(
                  "잠시만 기다려주세요",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "로그인 정보를 확인하고 있어요",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 로딩 모달을 닫는 함수
  void _hideLoadingModal() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

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
                                  width: double.infinity,
                                  height: 240,
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
                const Text(
                  "Fitbit 기기를 사용하셔야,\n정상적으로 서비스 이용이 가능합니다",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
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
                        backgroundColor: _isLoading ? Colors.grey : Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: _isLoading ? null : () async {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          final result = await FitbitAuthService.loginWithFitbit(autoLogin: _autoLogin);
                          
                          // 로그인 성공 후 모달 표시
                          if (mounted) {
                            _showLoadingModal();
                          }
                          
                          // 잠시 대기 (필요시 조정)
                          await Future.delayed(const Duration(milliseconds: 500));
                          
                          final userInfoEntered = await FitbitAuthService.checkUserInfoEnteredFromServer();
                          debugPrint("userInfoEntered: $userInfoEntered");
                          
                          if (!mounted) return;
                          
                          // 로딩 모달 닫기
                          _hideLoadingModal();
                          
                          // 페이지 이동
                          if (!userInfoEntered) {
                            context.go('/login/inputUserInfo');
                          } else {
                            context.go('/main');
                          }
                        } catch (e) {
                          print("로그인 에러: $e");
                          
                          // 로딩 모달이 열려있다면 닫기
                          if (mounted) {
                            _hideLoadingModal();
                          }
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("로그인 실패. 다시 시도해주세요.")),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      child: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
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