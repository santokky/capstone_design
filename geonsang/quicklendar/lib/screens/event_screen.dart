import 'package:flutter/material.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 100, color: Colors.pink),
          Text('이벤트', style: TextStyle(fontSize: 30)),
        ],
      ),
    );
  }
}
