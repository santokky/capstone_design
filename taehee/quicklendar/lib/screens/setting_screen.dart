import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quicklendar/main.dart'; // MyApp 클래스 임포트

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = '한국어';
  bool _darkTheme = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs?.getBool('notificationsEnabled') ?? true;
      _selectedLanguage = _prefs?.getString('selectedLanguage') ?? '한국어';
      _darkTheme = _prefs?.getBool('darkTheme') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    await _prefs?.setBool('notificationsEnabled', _notificationsEnabled);
    await _prefs?.setString('selectedLanguage', _selectedLanguage);
    await _prefs?.setBool('darkTheme', _darkTheme);
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // 로그인 상태를 false로 설정

    // 로그아웃 후 로그인 화면으로 이동
    Navigator.pushReplacementNamed(context, '/login');
  }

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
              _saveSettings();
            },
          ),
          ListTile(
            title: const Text('앱 언어 설정'),
            subtitle: const Text('앱 인터페이스 언어 설정'),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          ListTile(
            title: const Text('달력 설정'),
            subtitle: const Text('기본 보기 설정 및 공휴일 표시'),
            onTap: () {
              _showCalendarSettingsDialog();
            },
          ),
          ListTile(
            title: const Text('백업 및 복원'),
            onTap: () {
              _showBackupDialog();
            },
          ),
          SwitchListTile(
            title: const Text('테마 설정'),
            value: _darkTheme,
            onChanged: (bool value) {
              setState(() {
                _darkTheme = value;
              });
              _saveSettings();
            },
          ),
          ListTile(
            title: const Text('계정 정보'),
            onTap: () {
              _showAccountInfoDialog();
            },
          ),
          ListTile(
            title: const Text('도움말 및 지원'),
            onTap: () {
              _showHelpDialog();
            },
          ),
          ListTile(
            title: const Text('로그아웃'),
            onTap: _logout, // 로그아웃 함수 호출
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
              if (newValue != null) {
                setState(() {
                  _selectedLanguage = newValue;
                });
                _saveSettings();
                _changeLanguage(newValue);
                Navigator.of(context).pop();
              }
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

  void _changeLanguage(String language) {
    if (language == '한국어') {
      MyApp.setLocale(context, const Locale('ko', 'KR'));
    } else {
      MyApp.setLocale(context, const Locale('en', 'US'));
    }
  }

  void _showCalendarSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('달력 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('기본 보기'),
                trailing: DropdownButton<String>(
                  value: '월간',
                  onChanged: (String? newValue) {
                    // 기본 보기 설정 변경
                  },
                  items: <String>['월간', '주간', '일간']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SwitchListTile(
                title: const Text('공휴일 표시'),
                value: true,
                onChanged: (bool value) {
                  // 공휴일 표시 설정 변경
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('백업 및 복원'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('백업 위치'),
                trailing: DropdownButton<String>(
                  value: 'Google Drive',
                  onChanged: (String? newValue) {
                    // 백업 위치 설정 변경
                  },
                  items: <String>['Google Drive', '로컬 저장소']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // 수동 백업 실행
                },
                child: const Text('지금 백업'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 데이터 복원 실행
                },
                child: const Text('복원하기'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccountInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('계정 정보'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('사용자 이름'),
                subtitle: const Text('사용자 이름 예시'),
              ),
              ListTile(
                title: const Text('이메일'),
                subtitle: const Text('example@example.com'),
              ),
              ElevatedButton(
                onPressed: _logout, // 로그아웃 실행
                child: const Text('로그아웃'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 계정 삭제 실행
                },
                child: const Text('계정 삭제'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('도움말 및 지원'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('자주 묻는 질문'),
                onTap: () {
                  // 자주 묻는 질문 화면으로 이동
                },
              ),
              ListTile(
                title: const Text('사용 설명서'),
                onTap: () {
                  // 사용 설명서 화면으로 이동
                },
              ),
              ListTile(
                title: const Text('고객 지원'),
                onTap: () {
                  // 고객 지원 연락처 화면으로 이동
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
