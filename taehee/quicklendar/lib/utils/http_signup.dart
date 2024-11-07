import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

    if (response.statusCode == 201) {
      return {
        "message": "회원가입이 성공적으로 완료되었습니다.",
        "statusCode": 201
      };
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
