import 'package:flutter/material.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:go_router/go_router.dart';

class BatteryStatusScreen extends StatelessWidget {
  const BatteryStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: const CustomAppBar(title: "Fitbit 기기정보"),
      body: Text("배터리 & 기기정보 화면"),
    );
  }
}