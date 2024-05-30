import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool vibration = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('공통'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('언어'),
                value: Text('한국어'),
                onPressed: ((context) {}),
              ),
              SettingsTile.switchTile(
                title: Text('진동'),
                initialValue: vibration,
                onToggle: (value) {
                  setState(() {
                    vibration = value;
                  });
                },
                leading: Icon(Icons.vibration),
              ),
            ],
          ),
          SettingsSection(
            title: Text('계정'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.logout),
                title: Text('로그아웃'),
                onPressed: ((context) {}),
              ),
            ],
          ),
          SettingsSection(
            title: Text('기타'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.star),
                title: Text('앱 평가하기'),
                onPressed: ((context) {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
