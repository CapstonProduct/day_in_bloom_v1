import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class MedicalCheckupScreen extends StatelessWidget {
  const MedicalCheckupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> checkupItems = [
      {'label': '이름', 'value': '최예름'},
      {'label': '검진 날짜', 'value': '2025-03-15'},
      {'label': '신장', 'value': '160.5 cm'},
      {'label': '체중', 'value': '52.3 kg'},
      {'label': '체질량 지수', 'value': '20.3 kg/m²'},
      {'label': '혈압 (최고/최저)', 'value': '120 / 80 mmHg'},
      {'label': '공복 혈당', 'value': '92.5 mg/dL'},
      {'label': '총 콜레스테롤', 'value': '178.0 mg/dL'},
      {'label': 'HDL 콜레스테롤', 'value': '60.2 mg/dL'},
      {'label': 'LDL 콜레스테롤', 'value': '98.5 mg/dL'},
      {'label': '중성지방', 'value': '110.7 mg/dL'},
      {'label': '신사구체 여과율 (GFR)', 'value': '95.4 mL/min/1.73m²'},
      {'label': 'AST (간 기능)', 'value': '22.0 U/L'},
      {'label': 'ALT (간 기능)', 'value': '19.5 U/L'}
    ];

    return Scaffold(
      appBar: CustomAppBar(title: '건강검진 내역', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: checkupItems.length,
          itemBuilder: (context, index) {
            return Container(
              color: index.isOdd ? Colors.white : Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '• ${checkupItems[index]['label']!}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
                  ),
                  Text(
                    checkupItems[index]['value']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
