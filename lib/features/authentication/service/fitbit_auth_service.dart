import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: "myapp",
    );

    final code = Uri.parse(result).queryParameters['code'];

    final response = await http.post(
      Uri.parse('https://api.fitbit.com/oauth2/token'),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
        'code': code,
      },
    );

    if (response.statusCode == 200) {
      final tokenData = jsonDecode(response.body);
      final accessToken = tokenData['access_token'];
      final refreshToken = tokenData['refresh_token'];

      await _storage.write(key: 'access_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      await _storage.write(key: 'is_first_login', value: 'true');
      await _storage.write(key: 'auto_login', value: autoLogin.toString());

      return {
        "access_token": accessToken,
        "refresh_token": refreshToken,
      };
    } else {
      throw Exception('토큰 교환 실패: ${response.body}');
    }
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  static Future<bool> isFirstLogin() async {
    final flag = await _storage.read(key: 'is_first_login');
    return flag == 'true';
  }

  static Future<void> setFirstLoginDone() async {
    await _storage.write(key: 'is_first_login', value: 'false');
  }


  static Future<String?> getAccessToken() async {
  return await _storage.read(key: 'access_token');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<String?> getUserId() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/user/-/profile.json'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['user']['encodedId'];
    } else {
      print('사용자 정보 요청 실패: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
