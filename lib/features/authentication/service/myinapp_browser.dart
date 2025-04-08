import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  final void Function(String url) onRedirect;
  bool _handled = false; 

  MyInAppBrowser({required this.onRedirect});

  void _handleRedirect(String url) async {
    if (_handled) return;
    _handled = true;

    onRedirect(url);
    await _safeClose();
  }

  @override
  void onLoadStop(WebUri? url) async {
    if (url != null && url.toString().startsWith('myapp://callback')) {
      _handleRedirect(url.toString());
    }
  }

  @override
  void onUpdateVisitedHistory(WebUri? url, bool? isReload) async {
    if (url != null && url.toString().startsWith('myapp://callback')) {
      _handleRedirect(url.toString());
    }
  }

  Future<void> _safeClose() async {
    try {
      await close();
    } catch (e) {
      print('InAppBrowser close() 오류: $e');
    }
  }
}

