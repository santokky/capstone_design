import 'package:flutter/material.dart';
import 'package:quicklendar/main.dart'; // MyApp 클래스 임포트
import 'package:quicklendar/screens/user_guide_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';
import 'calendar_screen.dart';
import 'customer_support_screen.dart';
import 'faq_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notificationsEnabled = true;
  bool _darkTheme = false;
  String _userName = '홍길동'; // 기본 이름
  String _userEmail = 'example@example.com'; // 기본 이메일
  SharedPreferences? _prefs;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs?.getBool('notificationsEnabled') ?? true;
      _darkTheme = _prefs?.getBool('darkTheme') ?? false;
      _userName = _prefs?.getString('name') ?? '홍길동'; // 로그인된 사용자 이름 불러오기
      _userEmail = _prefs?.getString('email') ?? 'example@example.com'; // 로그인된 사용자 이메일 불러오기
    });
  }

  Future<void> _saveSettings() async {
    await _prefs?.setBool('notificationsEnabled', _notificationsEnabled);
    await _prefs?.setBool('darkTheme', _darkTheme);

    if (_notificationsEnabled) {
      _scheduleAllNotifications();  // 모든 알림을 다시 예약
    } else {
      await _dbHelper.cancelAllNotifications();  // 모든 알림 취소
    }
  }

  Future<void> _scheduleAllNotifications() async {
    final events = await _dbHelper.queryAllEvents();
    for (var event in events) {
      final eventObj = Event(
        title: event['title'] ?? '',
        organizer: event['organizer'] ?? '',
        description: event['description'] ?? '',
        location: event['location'] ?? '',
        applicationStartDate: event['application_start_date'] ?? '',
        applicationEndDate: event['application_end_date'] ?? '',
        contestStartDate: event['contest_start_date'] ?? '',
        contestEndDate: event['contest_end_date'] ?? '',
        applicationLink: event['application_link'] ?? '',
        contact: event['contact'] ?? '',
        category: event['category'] ?? '',
        field: event['field'] ?? '',
      );
      await _dbHelper.scheduleNotification(eventObj);
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _showAccountInfoDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('계정 정보'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/img/default_profile.png'),
                ),
                title: Text(_userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text('한신대학교', style: TextStyle(fontSize: 16)),
              ),
              ListTile(
                title: Text('이메일'),
                subtitle: Text(_userEmail),
              ),
              ListTile(
                title: Text('가입 날짜'),
                subtitle: Text('2023년 1월 1일'), // 예시로 고정된 값 사용
              ),
              ListTile(
                title: Text('계정 유형'),
                subtitle: Text('구글 회원'), // 예시로 고정된 값 사용
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('로그아웃'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 120, // 카드의 높이를 원하는 만큼 조정
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.grey[200],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center( // 카드 내의 콘텐츠를 가운데 정렬
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/img/default_profile.png'),
                    ),
                    title: Text(_userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('한신대학교', style: TextStyle(fontSize: 16)),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: _showAccountInfoDialog,
                  ),
                ),
              ),
            ),
          ),
          // ... 기존 설정 항목들
        ],
      ),
    );
  }

// 기존 코드 유지: _showNotificationDialog, _showCalendarSettingsDialog, _showBackupDialog, _showHelpDialog
}
