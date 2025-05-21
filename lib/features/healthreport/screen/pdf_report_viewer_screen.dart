import 'dart:convert';
import 'dart:io';

import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

class PdfReportViewerScreen extends StatefulWidget {
  const PdfReportViewerScreen({super.key});

  @override
  State<PdfReportViewerScreen> createState() => _PdfReportViewerScreenState();
}

class _PdfReportViewerScreenState extends State<PdfReportViewerScreen> {
  PDFDocument? _pdfDocument;
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
      final dateParam = GoRouterState.of(context).uri.queryParameters['date'] ?? '';

      if (encodedId == null) throw Exception('사용자 정보가 없습니다.');
      final reportDate = _formatDate(dateParam);

      final uri = Uri.parse(
        'https://gz96dflvf2.execute-api.ap-northeast-2.amazonaws.com/default/get-pdf-report',
      );

      final requestBody = {
        'encodedId': encodedId,
        'report_date': reportDate,
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception('PDF 링크 요청 실패: ${response.body}');
      }

      final presignedUrl = jsonDecode(response.body)['presignedUrl'];
      if (presignedUrl == null) {
        throw Exception('presignedUrl이 응답에 없습니다.');
      }

      final pdfResponse = await http.get(Uri.parse(presignedUrl));
      if (pdfResponse.statusCode != 200) {
        throw Exception('PDF 다운로드 실패 (상태코드: ${pdfResponse.statusCode})');
      }

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/temp_report.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfResponse.bodyBytes);

      final document = await PDFDocument.fromFile(file);

      setState(() {
        _pdfDocument = document;
        _loading = false;
      });
    } catch (e, stack) {
      print('[에러] 예외 발생: $e');
      print('[스택트레이스] $stack');

      String displayMessage;
      final errorMessage = e.toString();
      if (errorMessage.contains('NoSuchKey') ||
          errorMessage.contains('AccessDenied') ||
          errorMessage.contains('PDF 다운로드 실패')) {
        displayMessage = '해당 날짜에는 리포트 파일이 없습니다.';
      } else {
        displayMessage = errorMessage;
      }

      setState(() {
        _error = displayMessage;
        _loading = false;
      });
    }
  }

  String _formatDate(String input) {
    try {
      final cleaned = input.trim().replaceAll(RegExp(r'\s*/\s*'), '-');
      final parsed = DateTime.parse(cleaned);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      throw Exception('날짜 형식 오류: $input');
    }
  }

  Widget _buildErrorMessage() {
    final isNoReport = _error != null &&
        (_error!.contains('해당 날짜에는 리포트 파일이 없습니다.') ||
         _error!.contains('NoSuchKey') ||
         _error!.contains('AccessDenied'));

    return Center(
      child: Text(
        isNoReport
            ? '해당 날짜에는 리포트 파일이 없습니다.'
            : '오류 발생: $_error',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isNoReport ? Colors.grey[800] : Colors.red,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '건강 리포트 뷰어', showBackButton: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _error != null
              ? _buildErrorMessage()
              : _pdfDocument != null
                  ? PDFViewer(
                      document: _pdfDocument!,
                      zoomSteps: 1,
                      lazyLoad: false,
                      scrollDirection: Axis.vertical,
                    )
                  : const Center(child: Text('PDF 파일을 불러올 수 없습니다.')),
    );
  }
}
