import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'http_login.dart';

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
      final responseData = jsonDecode(response.body);

      // 응답 데이터에 token과 user 정보가 있는지 확인 후 파싱
      if (responseData.containsKey('token') && responseData.containsKey('user')) {
        String token = responseData['token'];
        String userName = responseData['user']['name'];
        String userEmail = responseData['user']['email'];

        await saveToken(token); // 토큰 저장

        // 반환 데이터에 token, name, email 포함
        return {
          "token": token,
          "name": userName,
          "email": userEmail,
        };
      } else {
        return {
          "error": "응답 데이터에 필요한 정보가 없습니다.",
          "statusCode": 500
        };
      }
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
