import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = '한국어';
  bool _darkTheme = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('알림 설정'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          ListTile(
            title: const Text('이미지 분석 설정'),
            subtitle: const Text('OCR 언어 설정'),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          ListTile(
            title: const Text('달력 설정'),
            subtitle: const Text('기본 보기 설정 및 공휴일 표시'),
            onTap: () {
              // 달력 설정 화면으로 이동
            },
          ),
          ListTile(
            title: const Text('백업 및 복원'),
            onTap: () {
              // 백업 및 복원 화면으로 이동
            },
          ),
          SwitchListTile(
            title: const Text('테마 설정'),
            value: _darkTheme,
            onChanged: (bool value) {
              setState(() {
                _darkTheme = value;
              });
            },
          ),
          ListTile(
            title: const Text('계정 정보'),
            onTap: () {
              // 계정 정보 화면으로 이동
            },
          ),
          ListTile(
            title: const Text('도움말 및 지원'),
            onTap: () {
              // 도움말 및 지원 화면으로 이동
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('언어 선택'),
          content: DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: (String? newValue) {
              setState(() {
                _selectedLanguage = newValue!;
              });
              Navigator.of(context).pop();
            },
            items: <String>['한국어', 'English']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
