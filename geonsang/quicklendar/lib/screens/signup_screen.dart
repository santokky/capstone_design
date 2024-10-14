import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  final Function() onSignupSuccess; // 회원가입 성공 시 호출할 콜백

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

      // 회원가입 시 이메일과 비밀번호 저장
      await prefs.setString('email', email);
      await prefs.setString('password', password);

      widget.onSignupSuccess(); // 회원가입 성공 시 콜백 호출
      Navigator.pop(context); // 회원가입 후 로그인 화면으로 돌아가기
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입'), backgroundColor: Color(0xFF2196F3)),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField(_emailController, '이메일을 입력해주세요'),
              const SizedBox(height: 16.0),
              _buildTextField(_passwordController, '비밀번호를 입력해주세요', obscureText: true),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                ),
                child: const Text('회원가입', style: TextStyle(color: Colors.white)),
              ),
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
