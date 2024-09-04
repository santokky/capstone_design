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
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _signup,
              child: const Text('회원가입'),
            ),
          ],
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