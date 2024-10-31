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
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor, // 다크 모드 대응
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
    // 테마에 따라 색상 설정
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Color(0xFF333333);
    Color hintColor = isDarkMode ? Colors.white70 : Color(0xFF333333);
    Color buttonColor = isDarkMode ? Colors.grey : Color(0xFF2196F3);
    Color textFieldColor = isDarkMode ? Colors.grey[700]! : Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor, // 배경색을 다크 모드에 따라 설정
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
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
                      // 비밀번호 찾기 기능
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
                  _buildSocialIcon('assets/img/google_logo.png', isDarkMode),
                  const SizedBox(width: 15),
                  _buildSocialIcon('assets/img/naver_logo.png', isDarkMode),
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
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
          borderSide: const BorderSide(color: Color(0xFF2196F3)),
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
