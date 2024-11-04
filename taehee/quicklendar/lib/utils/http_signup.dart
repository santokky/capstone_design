import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.0.2.2:8080';

Future<Map<String, dynamic>> signupUser(String name, String email, String password, String phone) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "phoneNumber": phone,
      }),
    );

    print("서버 응답 상태 코드: ${response.statusCode}");
    print("서버 응답 본문: ${response.body}");

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "error": "회원가입에 실패했습니다. 다시 시도해주세요.",
        "statusCode": response.statusCode
      };
    }
  } catch (e) {
    return {
      "error": "서버와 연결할 수 없습니다.",
      "statusCode": 503
    };
  }
}
