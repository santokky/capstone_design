import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2:8080';

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // 토큰 및 사용자 정보가 응답에 포함되어 있는지 확인
      if (responseData.containsKey('token') && responseData.containsKey('name') && responseData.containsKey('email')) {
        await saveToken(responseData['token']); // 토큰 저장

        // 사용자 정보가 포함된 경우 SharedPreferences에 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', responseData['name']); // 사용자 이름 저장
        await prefs.setString('userEmail', responseData['email']); // 사용자 이메일 저장

        return responseData; // 성공적으로 사용자 정보 반환
      } else {
        return {
          "error": "사용자 정보가 응답에 포함되지 않았습니다.",
          "statusCode": 500
        };
      }
    } else {
      return {
        "error": "로그인에 실패했습니다. 다시 시도해주세요.",
        "statusCode": response.statusCode
      };
    }
  } catch (e) {
    return {
      "error": "서버와 연결할 수 없습니다: $e",
      "statusCode": 503
    };
  }
}

Future<void> saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setBool('isLoggedIn', true);
}
