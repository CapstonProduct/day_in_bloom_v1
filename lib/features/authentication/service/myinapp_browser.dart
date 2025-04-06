import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  final void Function(String url) onRedirect;

  MyInAppBrowser({required this.onRedirect});

  // Android
  @override
  void onLoadStop(WebUri? url) async {
    if (url != null && url.toString().startsWith('myapp://callback')) {
      onRedirect(url.toString());
      await close();
    }
  }

  // iOS
  @override
  void onUpdateVisitedHistory(WebUri? url, bool? isReload) async {
    if (url != null && url.toString().startsWith('myapp://callback')) {
      onRedirect(url.toString());
      await close();
    }
  }
}
