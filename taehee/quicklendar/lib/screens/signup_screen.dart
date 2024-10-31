import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  final Function() onSignupSuccess;

  const SignupScreen({Key? key, required this.onSignupSuccess}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signup() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('email', email);
      await prefs.setString('password', password);

      widget.onSignupSuccess();
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor, // 다크 모드 대응
          title: const Text('회원가입 실패'),
          content: const Text('올바르지 않은 이메일입니다.'),
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
    Color containerColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    Color buttonColor = isDarkMode ? Colors.grey : Color(0xFF2196F3);
    Color hintColor = isDarkMode ? Colors.white54 : Color(0xFF333333);
    Color textFieldColor = isDarkMode ? Colors.grey[700]! : Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor, // 배경색을 다크 모드에 따라 설정
      body: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '회원가입',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '새 계정을 만들어주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: containerColor, // 컨테이너 색상 설정
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      if (!isDarkMode)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(_emailController, '이메일을 입력해주세요', hintColor, textFieldColor, textColor),
                      const SizedBox(height: 16),
                      _buildTextField(_passwordController, '비밀번호를 입력해주세요', hintColor, textFieldColor, textColor, obscureText: true),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor, // 버튼 색상 설정
                          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          '회원가입',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: RichText(
                    text: TextSpan(
                      text: '이미 계정이 있으신가요? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                      children: [
                        TextSpan(
                          text: '로그인 해주세요.',
                          style: TextStyle(
                            color: buttonColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
        fillColor: fillColor, // 입력 필드 색상 설정
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF2196F3)),
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
