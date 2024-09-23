import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  OCRScreenState createState() => OCRScreenState();
}

class OCRScreenState extends State<OCRScreen> {
  XFile? _image; // 이미지를 저장할 변수
  final ImagePicker picker = ImagePicker(); // ImagePicker 초기화
  String scannedText = ""; // textRecognizer로 인식된 텍스트를 담을 String

  // 이미지 선택 함수 (갤러리 or 카메라)
  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); // 가져온 이미지를 _image에 저장
      });
      getRecognizedText(_image!); // 이미지를 가져온 뒤 텍스트 인식 실행
    }
  }

  // 텍스트 인식 함수
  void getRecognizedText(XFile image) async {
    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer =
    GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.latin);
    RecognizedText recognizedText =
    await textRecognizer.processImage(inputImage);


    await textRecognizer.close();

    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
      }
    }

    setState(() {}); // 상태를 갱신해 화면에 표시
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30, width: double.infinity),
          _buildPhotoArea(),
          _buildRecognizedText(),
          SizedBox(height: 20),
          _buildButton(),
        ],
      ),
    );
  }

  // 갤러리에서 선택한 사진을 표시하는 영역
  Widget _buildPhotoArea() {
    return _image != null
        ? Container(
      width: 320,
      height: 400,
      child: Image.file(File(_image!.path)),
    )
        : Container(
      width: 320,
      height: 400,
      color: Colors.grey,
    );
  }

  // 인식된 텍스트를 화면에 표시하는 영역
  Widget _buildRecognizedText() {
    return Text(
      scannedText.isNotEmpty ? scannedText : "인식된 텍스트가 없습니다.",
      textAlign: TextAlign.center,
    );
  }

  // 버튼 빌드 함수 (카메라, 갤러리)
  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            getImage(ImageSource.camera); // 카메라로 이미지 가져오기
          },
          icon: Icon(Icons.camera_alt),
          label: Text("카메라"),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery); // 갤러리에서 이미지 가져오기
          },
          child: Row(
            children: [
              Icon(Icons.photo_library),
              SizedBox(width: 5),
              Text("갤러리"),
            ],
          ),
        ),
      ],
    );
  }
}
