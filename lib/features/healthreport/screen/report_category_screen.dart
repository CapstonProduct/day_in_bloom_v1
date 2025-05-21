import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:day_in_bloom_v1/features/healthreport/screen/pdf_download_modal.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';

class ReportCategoryScreen extends StatefulWidget {
  const ReportCategoryScreen({super.key});

  @override
  State<ReportCategoryScreen> createState() => _ReportCategoryScreenState();
}

class _ReportCategoryScreenState extends State<ReportCategoryScreen> {
  late Future<Map<String, dynamic>> _reportData;

  @override
  void initState() {
    super.initState();
    _reportData = fetchReportData();
  }

  Future<Map<String, dynamic>> fetchReportData() async {
    final encodedId = await FitbitAuthService.getUserId();
    final reportDateRaw = GoRouterState.of(context).uri.queryParameters['date'];

    if (encodedId == null || reportDateRaw == null) {
      throw Exception('사용자 정보 또는 날짜가 없습니다.');
    }

    final formattedDate = _parseReportDate(reportDateRaw);

    debugPrint('=== API 요청 정보 ===');
    debugPrint('Headers: {Content-Type: application/json}');
    debugPrint('Body: ${jsonEncode({
        'encodedId': encodedId,
        'report_date': formattedDate,
      })}');
    debugPrint('=====================');

    final response = await http.post(
      Uri.parse('https://w3labpvlec.execute-api.ap-northeast-2.amazonaws.com/prod/report-category'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'encodedId': encodedId,
        'report_date': formattedDate,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('데이터 로드 실패: ${response.body}');
    }

    return json.decode(response.body);
  }

  String _parseReportDate(String rawDate) {
    try {
      final sanitized = rawDate.replaceAll('/', '-').replaceAll(' ', '');
      final parsedDate = DateTime.parse(sanitized);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (_) {
      throw Exception('날짜 파싱 실패: $rawDate');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _reportData = fetchReportData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '날짜가 선택되지 않았습니다.';

    return Scaffold(
      appBar: const CustomAppBar(title: '건강 리포트', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.green,
          backgroundColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                selectedDate,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _reportData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.green));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text('No data found.'));
                    }

                    final data = snapshot.data!;
                    final overallHealthScore = data['overall_health_score'] ?? 0;
                    final stressScore = data['stress_score'] ?? 0;

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        if (index == 0 || index == 1) {
                          return ScoreReportCategoryTile(
                            category: category.copyWith(
                              score: index == 0 ? overallHealthScore : stressScore,
                            ),
                            color: index == 0 ? Colors.yellow.shade100 : Colors.grey.shade200,
                          );
                        }
                        return ReportCategoryTile(category: category);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const DownloadReportButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportCategoryTile extends StatelessWidget {
  final ReportCategory category;

  const ReportCategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '';

    return GestureDetector(
      onTap: () => context.go('${category.route}?date=$selectedDate'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                category.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(category.imagePath, width: 60, height: 60),
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreReportCategoryTile extends StatelessWidget {
  final ReportCategory category;
  final Color color;

  const ScoreReportCategoryTile({
    super.key,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDate = GoRouterState.of(context).uri.queryParameters['date'] ?? '';

    return GestureDetector(
      onTap: () => context.go('${category.route}?date=$selectedDate'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                category.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                category.score.toString(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: category.color ?? Colors.black,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DownloadReportButton extends StatelessWidget {
  const DownloadReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PdfDownloadModal.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '리포트 PDF 다운로드 (본인용)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(width: 14),
            Image.asset('assets/report_icon/green_pdf.png', width: 40, height: 40),
          ],
        ),
      ),
    );
  }
}

class ReportCategory {
  final String title;
  final String imagePath;
  final int score;
  final Color? color;
  final String route;

  const ReportCategory({
    required this.title,
    required this.imagePath,
    this.score = 0,
    this.color,
    required this.route,
  });

  ReportCategory copyWith({int? score}) {
    return ReportCategory(
      title: title,
      imagePath: imagePath,
      score: score ?? this.score,
      color: color,
      route: route,
    );
  }
}

const List<ReportCategory> _categories = [
  ReportCategory(title: '전체 종합 점수', imagePath: '', score: 0, route: '/homeCalendar/report/totalScore'),
  ReportCategory(title: '스트레스 점수', imagePath: '', score: 0, color: Colors.red, route: '/homeCalendar/report/stressScore'),
  ReportCategory(title: '운동', imagePath: 'assets/report_icon/dumbell.png', route: '/homeCalendar/report/exercise'),
  ReportCategory(title: '수면', imagePath: 'assets/report_icon/pillow.png', route: '/homeCalendar/report/sleep'),
  ReportCategory(title: '보호자님\n조언', imagePath: 'assets/report_icon/family_talk.png', route: '/homeCalendar/report/familyAdvice'),
  ReportCategory(title: '의사 선생님\n조언', imagePath: 'assets/report_icon/doctor_talk.png', route: '/homeCalendar/report/doctorAdvice'),
];
