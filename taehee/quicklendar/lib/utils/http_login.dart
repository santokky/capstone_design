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
      try {
        final responseData = jsonDecode(response.body);

        // 토큰 및 사용자 정보가 응답에 포함되어 있는지 확인
        if (responseData['token'] != null) {
          await saveToken(responseData['token']);

          // 사용자 정보가 포함된 경우 SharedPreferences에 저장
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (responseData.containsKey('user')) {
            final user = responseData['user'];
            await prefs.setString('userName', user['name'] ?? ''); // 사용자 이름 저장
            await prefs.setString('userEmail', user['email'] ?? ''); // 사용자 이메일 저장
          } else {
            return {
              "error": "사용자 정보가 응답에 포함되지 않았습니다.",
              "statusCode": 500
            };
          }

          return responseData;
        } else {
          return {
            "error": "로그인에 실패했습니다. 토큰이 없습니다.",
            "statusCode": 500
          };
        }
      } catch (e) {
        // JSON 파싱 오류 처리
        return {
          "error": "응답을 처리하는 중 오류가 발생했습니다: $e",
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
