import 'package:flutter/material.dart';

class OCRScreen extends StatelessWidget {
  const OCRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 100, color: Colors.purple),
          Text('퀵린더', style: TextStyle(fontSize: 30)),
        ],
      ),
    );
  }
}
