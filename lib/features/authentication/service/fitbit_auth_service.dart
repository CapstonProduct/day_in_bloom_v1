import 'dart:async';
import 'dart:convert';
import 'package:day_in_bloom_v1/features/authentication/service/myinapp_browser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class FitbitAuthService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> clearIfNotAutoLogin() async {
    final autoLogin = await _storage.read(key: 'auto_login');
    if (autoLogin != 'true') {
      await logout();
    }
  }

  static Future<bool> isLoggedIn() async {
    final autoLogin = await _storage.read(key: 'auto_login');
    final token = await _storage.read(key: 'access_token');
    return autoLogin == 'true' && token != null;
  }

  static Future<Map<String, dynamic>?> loginWithFitbit({required bool autoLogin}) async {
    final clientId = dotenv.env['FITBIT_CLIENT_ID']!;
    final clientSecret = dotenv.env['FITBIT_CLIENT_SECRET']!;
    const redirectUri = 'myapp://callback';
    const scopes = 'activity heartrate sleep profile';

    final authUrl =
        'https://www.fitbit.com/oauth2/authorize'
        '?response_type=code'
        '&client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&scope=$scopes'
        '&prompt=login';

    final completer = Completer<Map<String, dynamic>?>();
    
    final browser = MyInAppBrowser(onRedirect: (url) async {
      if (completer.isCompleted) return;

      final code = Uri.parse(url).queryParameters['code'];
      if (code == null) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('코드가 없음'));
        }
        return;
      }

      final tokenResponse = await http.post(
        Uri.parse('https://api.fitbit.com/oauth2/token'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': clientId,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUri,
          'code': code,
        },
      );

      if (tokenResponse.statusCode != 200) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('토큰 교환 실패: ${tokenResponse.body}'));
        }
        return;
      }

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];
      final refreshToken = tokenData['refresh_token'];
      final tokenType = tokenData['token_type'];
      final expiresIn = tokenData['expires_in'];

      final fitbitUserId = await _getUserId(accessToken);
      if (fitbitUserId == null) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('Fitbit 사용자 정보 가져오기 실패'));
        }
        return;
      }

      await _storage.write(key: 'access_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      await _storage.write(key: 'is_first_login', value: 'true');
      await _storage.write(key: 'auto_login', value: autoLogin.toString());

      final sendingJsonData = {
        "userId": "my_user_123",
        "fitbit_user_id": fitbitUserId,
        "access_token": accessToken,
        "refresh_token": refreshToken,
        "token_type": tokenType,
        "expires_in": expiresIn,
      };

      final prettyJson = const JsonEncoder.withIndent('  ').convert(sendingJsonData);
      print(prettyJson);

      try {
        final response = await http.post(
          Uri.parse(dotenv.env['AUTH_API_GATEWAY_URL']!),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(sendingJsonData),
        );

        final decodedBody = utf8.decode(response.bodyBytes);

        if (response.statusCode == 200) {
          print("람다 전송 성공: $decodedBody");
        } else {
          print("람다 전송 실패: ${response.statusCode} - $decodedBody");
        }
      } catch (e) {
        print("람다 호출 에러: $e");
      }


      if (!completer.isCompleted) {
        completer.complete(sendingJsonData);
      }
    });

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(authUrl)),
    );

    return completer.future;
  }

  static Future<String?> _getUserId(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/user/-/profile.json'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['user']['encodedId'];
    } else {
      print('사용자 정보 요청 실패: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<String?> getUserId() async {
    final token = await getAccessToken();
    if (token == null) return null;
    return await _getUserId(token);
  }

  static Future<bool> isUserInfoEntered() async {
    final result = await _storage.read(key: 'user_info_entered');
    return result == 'true';
  }

  static Future<void> setUserInfoEntered() async {
    await _storage.write(key: 'user_info_entered', value: 'true');
  }
}
