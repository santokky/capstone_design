import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/google_login.dart';
import '../utils/http_login.dart'; // http_login.dart 파일을 import
import '../main.dart'; // 홈 화면이 정의된 파일
import '../utils/naver_login.dart';
import 'signup_screen.dart'; // 회원가입 화면이 정의된 파일
import '../utils/http_login.dart' as httpLogin;
import '../utils/login_shared_function.dart' as sharedFunction;


class LoginScreen extends StatefulWidget {
  final Function(bool) onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;


  //final FlutterAppAuth appAuth = FlutterAppAuth();

  // // OAuth 클라이언트 정보
  // // 구글
  // static const String googleClientId = "103045365743-ovcqu07t65n0aakdn4oq5v7noivskl7f.apps.googleusercontent.com";
  // static const String googleRedirectUri = "quicklendar://oauth2redirect";
  // static const String googleDiscoveryUrl = "https://accounts.google.com/.well-known/openid-configuration";
  // // 네이버
  // static const String naverClientId = "rFe2vahJ2u3T896kiX1c";
  // static const String naverClientSecret = "BvIF44t_QL";
  // static const String naverRedirectUri = "quicklendar://oauth2redirect";
  // static const String naverAuthorizationEndpoint = "https://nid.naver.com/oauth2.0/authorize";
  // static const String naverTokenEndpoint = "https://nid.naver.com/oauth2.0/token";
  // static const String naverUserInfoEndpoint = "https://openapi.naver.com/v1/nid/me";

  // Future<void> _login() async {
  //   String email = _emailController.text;
  //   String password = _passwordController.text;
  //
  //   final response = await loginUser(email, password);
  //
  //   if (response.containsKey('token') && response['token'] != null) {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('token', response['token'] ?? "");
  //     await prefs.setString('userEmail', response['email'] ?? "");
  //     await prefs.setString('userName', response['name'] ?? "");
  //     await prefs.setBool('isLoggedIn', true);
  //     widget.onLoginSuccess(true);
  //
  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
  //   } else {
  //     _showErrorDialog(response['error'] ?? '알 수 없는 오류가 발생했습니다.');
  //   }
  // }


  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    final response = await loginUser(email, password);

    if (response.containsKey('token') && response['token'] != null) {
      // httpLogin과 sharedFunction을 사용하여 충돌 해결
      await httpLogin.saveToken(response['token']);
      await sharedFunction.saveUserInfo(response);

      widget.onLoginSuccess(true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
    } else {
      _showErrorDialog(response['error'] ?? '알 수 없는 오류가 발생했습니다.');
    }
  }


  // Future<void> _googleLogin() async {
  //   try {
  //     final AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(
  //       AuthorizationTokenRequest(
  //         googleClientId,
  //         googleRedirectUri,
  //         discoveryUrl: googleDiscoveryUrl,
  //         scopes: ['openid', 'profile', 'email'],
  //         promptValues: ['consent'], // 사용자 동의를 명시적으로 요청
  //       ),
  //     );
  //
  //     if (result != null && result.accessToken != null) {
  //       await _loginWithBackend(result.accessToken!, 'google');
  //     } else {
  //       _showErrorDialog("Google 로그인 실패: 액세스 토큰을 받을 수 없습니다.");
  //     }
  //   } catch (e) {
  //     _showErrorDialog("Google 로그인 오류: $e");
  //   }
  // }
  //
  // Future<void> _naverLogin() async {
  //   try {
  //     final AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(
  //       AuthorizationTokenRequest(
  //         naverClientId,
  //         naverRedirectUri,
  //         clientSecret: naverClientSecret,
  //         serviceConfiguration: AuthorizationServiceConfiguration(
  //           authorizationEndpoint: naverAuthorizationEndpoint,
  //           tokenEndpoint: naverTokenEndpoint,
  //         ),
  //         scopes: ['name', 'email'],
  //       ),
  //     );
  //
  //     if (result != null && result.accessToken != null) {
  //       await _loginWithBackend(result.accessToken!, 'naver');
  //     } else {
  //       _showErrorDialog("Naver 로그인 실패: 액세스 토큰을 받을 수 없습니다.");
  //     }
  //   } catch (e) {
  //     _showErrorDialog("Naver 로그인 오류: $e");
  //   }
  // }
  //
  // Future<void> _loginWithBackend(String accessToken, String provider) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://10.0.2.2:8080/login/oauth2/$provider'),
  //       headers: {"Authorization": "Bearer $accessToken"},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('token', responseData['token'] ?? "");
  //       await prefs.setString('userEmail', responseData['email'] ?? "");
  //       await prefs.setString('userName', responseData['name'] ?? "");
  //       widget.onLoginSuccess(true);
  //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
  //     } else {
  //       _showErrorDialog("서버 인증 실패: ${response.body}");
  //     }
  //   } catch (e) {
  //     _showErrorDialog("백엔드 로그인 오류: $e");
  //   }
  // }

  // Google 로그인 호출
  Future<void> _handleGoogleLogin() async {
    final response = await googleLogin();
    if (response.containsKey('token')) {
      widget.onLoginSuccess(true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
    } else {
      _showErrorDialog(response['error'] ?? "Google 로그인에 실패했습니다.");
    }
  }

  // Naver 로그인 호출
  Future<void> _handleNaverLogin() async {
    final response = await naverLogin();
    if (response.containsKey('token')) {
      widget.onLoginSuccess(true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
    } else {
      _showErrorDialog(response['error'] ?? "Naver 로그인에 실패했습니다.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: const Text('로그인 실패'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('확인'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Color(0xFF333333);
    Color hintColor = isDarkMode ? Colors.white70 : Color(0xFF333333);
    Color buttonColor = isDarkMode ? Colors.grey : Colors.blueAccent;
    Color textFieldColor = isDarkMode ? Colors.grey[700]! : Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 3),
            Image.asset('assets/img/logo.png', height: 100),
            const SizedBox(height: 5),
            Text(
              'Login',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(_emailController, '이메일을 입력해주세요', hintColor, textFieldColor, textColor),
            const SizedBox(height: 15),
            _buildTextField(_passwordController, '비밀번호를 입력해주세요', hintColor, textFieldColor, textColor, obscureText: true),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    Text('아이디 저장하기', style: TextStyle(color: textColor)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // 비밀번호 찾기 기능 추가 예정
                  },
                  child: Text('pw 찾기', style: TextStyle(color: textColor)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: const Text('로그인', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignupScreen(
                      onSignupSuccess: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('회원가입이 완료되었습니다.')),
                        );
                      },
                    ),
                  ),
                );
              },
              child: RichText(
                text: TextSpan(
                  text: '계정이 없으신가요? ',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                  children: [
                    TextSpan(
                      text: '가입하기',
                      style: TextStyle(
                        color: buttonColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Text(
              '소셜 로그인',
              style: TextStyle(color: textColor, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _handleGoogleLogin,
                  child: _buildSocialIcon('assets/img/google_logo.png', isDarkMode),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: _handleNaverLogin,
                  child: _buildSocialIcon('assets/img/naver_logo.png', isDarkMode),
                ),
              ],
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      Color hintColor,
      Color fillColor,
      Color textColor, {
        bool obscureText = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String assetPath, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode ? Colors.grey[700] : Colors.white,
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.asset(
          assetPath,
          height: 30,
          width: 30,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
