import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_applications, size: 100, color: Colors.teal),
          Text('설정', style: TextStyle(fontSize: 30)),
        ],
      ),
    );
  }
}
