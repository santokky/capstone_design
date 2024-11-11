import 'package:shared_preferences/shared_preferences.dart';

// 토큰 저장 함수
Future<void> saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setBool('isLoggedIn', true);
}

// 사용자 정보 저장 함수
Future<void> saveUserInfo(Map<String, dynamic> responseData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userName = responseData['name'] ?? "";
  String userEmail = responseData['email'] ?? "";

  await prefs.setString('userName', userName);
  await prefs.setString('userEmail', userEmail);
}
