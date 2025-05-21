import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PdfReportViewerScreen extends StatefulWidget {
  const PdfReportViewerScreen({super.key});

  @override
  State<PdfReportViewerScreen> createState() => _PdfReportViewerScreenState();
}

class _PdfReportViewerScreenState extends State<PdfReportViewerScreen> {
  String? _localPath;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndLoadPdf();
  }

  Future<void> _fetchAndLoadPdf() async {
    try {
      final encodedId = await FitbitAuthService.getUserId();
      final dateParam = Uri.base.queryParameters['date'];

      if (encodedId == null || dateParam == null) {
        throw Exception('사용자 정보 또는 날짜가 없습니다.');
      }

      final reportDate = _formatDate(dateParam);

      final response = await http.post(
        Uri.parse('https://gz96dflvf2.execute-api.ap-northeast-2.amazonaws.com/default/get-pdf-report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'encodedId': encodedId,
          'report_date': reportDate,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('PDF 링크 요청 실패: ${response.body}');
      }

      final presignedUrl = jsonDecode(response.body)['presignedUrl'];

      final pdfResponse = await http.get(Uri.parse(presignedUrl));
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/temp_report.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfResponse.bodyBytes);

      setState(() {
        _localPath = filePath;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatDate(String input) {
    try {
      final parsed = DateTime.parse(input.replaceAll('/', '-'));
      return parsed.toIso8601String().split('T')[0];
    } catch (_) {
      throw Exception('날짜 형식 오류');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('건강 리포트')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('오류 발생: $_error'))
              : _localPath != null
                  ? PDFView(
                      filePath: _localPath!,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: true,
                    )
                  : const Center(child: Text('PDF 파일을 불러올 수 없습니다.')),
    );
  }
}
