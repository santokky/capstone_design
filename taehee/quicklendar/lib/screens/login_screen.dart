import 'package:flutter/material.dart';
import 'package:quicklendar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';

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

  Future<void> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    String enteredEmail = _emailController.text;
    String enteredPassword = _passwordController.text;

    if (enteredEmail == savedEmail && enteredPassword == savedPassword) {
      await prefs.setBool('isLoggedIn', true);
      widget.onLoginSuccess(true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('로그인 실패'),
          content: const Text('이메일 또는 비밀번호가 잘못되었습니다.'),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFF2196F3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Spacer(flex: 400), // 상단 여백 추가
              Image.asset('assets/img/logo.png', height: 130),
              const SizedBox(height: 5),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 50),
              _buildTextField(_emailController, '이메일을 입력해주세요'),
              const SizedBox(height: 10),
              _buildTextField(_passwordController, '비밀번호를 입력해주세요', obscureText: true),
              const SizedBox(height: 2),
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
                      const Text('아이디 저장하기', style: TextStyle(color: Color(0xFF333333))),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // 비밀번호 찾기 기능
                    },
                    child: const Text('pw 찾기', style: TextStyle(color: Color(0xFF333333))),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                ),
                child: const Text('로그인', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 3),
              TextButton(
                onPressed: () {
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
                child: const Text(
                  '계정이 없으신가요? 가입하기',
                  style: TextStyle(color: Color(0xFF333333)),
                ),
              ),
              const Spacer(flex: 5), // 하단 여백 추가
              const Text(
                '소셜 로그인',
                style: TextStyle(color: Color(0xFF333333), fontSize: 14),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img/google_logo.png',
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    'assets/img/naver_logo.png',
                    height: 40,
                    width: 40,
                  ),
                ],
              ),
              const Spacer(flex: 100), // 추가 하단 여백
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFF333333)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF333333)),
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2196F3)),
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
