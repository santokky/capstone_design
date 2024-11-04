// http_login.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.0.2.2:8080';

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    // 로그인 성공 시 서버 응답 반환
    return jsonDecode(response.body);
  } else {
    // 로그인 실패 시 에러 메시지 반환
    return {
      "error": "로그인에 실패했습니다. 다시 시도해주세요.",
      "statusCode": response.statusCode
    };
  }
}
