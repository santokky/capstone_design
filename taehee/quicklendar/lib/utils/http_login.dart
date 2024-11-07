import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    final responseData = jsonDecode(response.body);
    await saveToken(responseData['token']);
    return responseData;
  } else {
    return {
      "error": "로그인에 실패했습니다. 다시 시도해주세요.",
      "statusCode": response.statusCode
    };
  }
}

Future<void> saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setBool('isLoggedIn', true);
}
