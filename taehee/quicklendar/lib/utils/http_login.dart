import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2:8080';

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  try {
    // 요청 시작 로그
    print("Sending login request for email: $email");

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    // 서버 응답 상태 코드 및 응답 내용 로그
    print("Response status code: ${response.statusCode}");
    print("Raw response body: ${response.body}");

    // 응답 본문을 UTF-8로 디코딩
    final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));

    print("Decoded response data: $responseData");

    if (response.statusCode == 200) {
      // 토큰 및 사용자 정보가 포함되었는지 확인
      if (responseData.containsKey('token') && responseData['token'] != null) {
        print("Login successful, token received: ${responseData['token']}");

        // 토큰을 저장하는 함수 호출 및 로그
        await saveToken(responseData['token']);

        SharedPreferences prefs = await SharedPreferences.getInstance();

        // null 값이 올 경우 대비하여 빈 문자열 할당
        String userName = responseData['name'] ?? "";
        String userEmail = responseData['email'] ?? "";

        // SharedPreferences에 사용자 정보 저장
        await prefs.setString('userName', userName);
        await prefs.setString('userEmail', userEmail);

        print("User information saved: name=$userName, email=$userEmail");

        // 정상적으로 사용자 정보 반환
        return responseData;
      } else {
        print("Error: Token or user information is missing in the response.");
        return {
          "error": "사용자 정보가 응답에 포함되지 않았습니다.",
          "statusCode": 500
        };
      }
    } else {
      print("Login failed with status code: ${response.statusCode}");
      return {
        "error": "로그인에 실패했습니다. 다시 시도해주세요.",
        "statusCode": response.statusCode
      };
    }
  } catch (e) {
    print("Exception occurred during login: $e");
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
  print("Token saved to SharedPreferences: $token");
}
