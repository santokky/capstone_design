import 'dart:async'; // Timer 클래스를 사용하기 위해 dart:async 임포트
import 'package:flutter/material.dart';

// SplashScreen 클래스 - 애플리케이션 시작 시 표시되는 스플래시 화면
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 5초 후에 홈 화면으로 전환
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // 화면 중앙에 위치한 Column 위젯
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // '퀵 린 더' 텍스트 표시, 폰트 크기와 굵기 설정
            const Text(
              '퀵 린 더',
              style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20), // 텍스트와 이미지 사이의 간격
            Image.asset(
              'assets/calendar.png',
              width: 400,
              height: 400,
            ),
          ],
        ),
      ),
    );
  }
}
