import 'dart:convert';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'http_login.dart' as httpLogin;
import 'login_shared_function.dart' as sharedFunction;


const String googleClientId = "103045365743-ovcqu07t65n0aakdn4oq5v7noivskl7f.apps.googleusercontent.com";
const String googleRedirectUri = "http://10.0.2.2:8080/login/oauth2/code/google";
const String googleDiscoveryUrl = "https://accounts.google.com/.well-known/openid-configuration";
const String baseUrl = 'http://10.0.2.2:8080';

// Google 로그인 함수
Future<Map<String, dynamic>> googleLogin() async {
  final FlutterAppAuth appAuth = FlutterAppAuth();

  try {
    final AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        googleClientId,
        googleRedirectUri,
        discoveryUrl: googleDiscoveryUrl,
        scopes: ['openid', 'profile', 'email'],
        promptValues: ['consent', 'select_account'],
        additionalParameters: {
          'device_id': 'emulator_device',
          'device_name': 'android_emulator',
        },
      ),
    );

    if (result != null && result.accessToken != null) {
      return await loginWithGoogleToken(result.accessToken!);
    } else {
      return {"error": "Google 로그인 실패: 액세스 토큰을 받을 수 없습니다.", "statusCode": 401};
    }
  } catch (e) {
    return {"error": "Google 로그인 오류: $e", "statusCode": 503};
  }
}

// Google 토큰으로 백엔드 로그인 요청
Future<Map<String, dynamic>> loginWithGoogleToken(String accessToken) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login/oauth2/google'),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
    );

    final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && responseData.containsKey('token')) {
      await httpLogin.saveToken(responseData['token']);
      await sharedFunction.saveUserInfo(responseData);
      return responseData;
    } else {
      return {"error": "Google 로그인 실패: ${responseData['error'] ?? '알 수 없는 오류'}", "statusCode": response.statusCode};
    }
  } catch (e) {
    return {"error": "Google 백엔드 로그인 오류: $e", "statusCode": 503};
  }
}
