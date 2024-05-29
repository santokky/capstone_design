import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import "package:camera/camera.dart";

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  OCRScreenState createState() => OCRScreenState();
}

class OCRScreenState extends State<OCRScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> cameras;
  late CameraDescription firstCamera;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {}); // 초기화된 컨트롤러를 반영하기 위해 위젯을 다시 빌드
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('퀵린더'),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: null,),
        actions: [
          //IconButton(icon: Icon(Icons.search), onPressed: null,),
          IconButton(icon: Icon(Icons.notifications), onPressed: null,),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 미리보기
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(0.0), // 원하는 패딩 값 설정
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF33FF33), width: 3.0), // 초록색 경계선 설정
                    ),
                    child: CameraPreview(_controller),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
      // 버튼 누를 시 카메라 화면의 캡쳐본을 보여주는 화면으로 이동
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            // 현재 카메라 화면 캡쳐
            final image = await _controller.takePicture();

            if (!mounted) return;

            // 사진 보여주기
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// --------------------------------
// 찍은 사진 보여주는 위젯
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('캡쳐 화면')),
      body: Center(
        child: kIsWeb
            ? Image.network(imagePath) // 웹에서는 네트워크 이미지를 사용
            : Image.file(File(imagePath)), // 모바일에서는 파일 이미지를 사용
      ),
    );
  }
}
