import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart'; // 데이터베이스 사용을 위한 헬퍼 파일
import 'package:http/http.dart' as http;
import '../env/env.dart'; // env 파일을 import하여 API 키를 사용

class Event {
  final String title;
  final String description;
  final DateTime date;

  Event(this.title, this.description, this.date);
}

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  OCRScreenState createState() => OCRScreenState();
}

class OCRScreenState extends State<OCRScreen> {
  XFile? _image;
  final ImagePicker picker = ImagePicker();
  String scannedText = "";
  String? detectedTitle;
  DateTime? detectedDate;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // 이미지 선택 및 텍스트 인식 함수
  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
      await getRecognizedText(_image!);
    }
  }

  // 텍스트 인식 및 제목과 날짜 추출
  Future<void> getRecognizedText(XFile image) async {
    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.korean);
    RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    // OCR 텍스트의 줄바꿈을 공백으로 변환하여 한 줄로 정리
    scannedText = recognizedText.text.replaceAll('\n', ' ');

    setState(() {});

    // 제목을 정규식으로 먼저 추출
    detectedTitle = extractContestTitle(scannedText);

    // 제목을 찾지 못한 경우에만 OpenAI API 호출
    final refinedData = await extractTitleAndDateWithOpenAI(scannedText);
    if (detectedTitle == null || detectedTitle!.isEmpty) {
      detectedTitle = refinedData['title'];
    }

    // OpenAI API에서 날짜 추출 및 파싱
    detectedDate = refinedData['date'] != null ? _parseDate(refinedData['date']!) : null;

    if (detectedTitle != null || detectedDate != null) {
      _showConfirmationDialog();
    }
  }


  // 공모전 제목을 파싱하는 함수
  String? extractContestTitle(String text) {
    RegExp titleExp = RegExp(r"(제\s?\d{1,2}\s?회\s?.*?공모전|\d{4}\s?.*?공모전)", caseSensitive: false);
    final match = titleExp.firstMatch(text);
    return match?.group(0)?.trim();
  }

  // 다양한 날짜 형식 파싱 함수
  DateTime? _parseDate(String date) {
    List<String> formats = [
      'yyyy-MM-dd', 'yyyy.MM.dd', 'yyyy/MM/dd', 'yyyy년 MM월 dd일'
    ];

    for (String format in formats) {
      try {
        return DateFormat(format).parse(date);
      } catch (_) {
        continue;
      }
    }

    print('날짜 형식을 파싱할 수 없습니다: $date');
    return null;
  }

  // OpenAI API로 제목과 날짜를 추출하는 함수
  Future<Map<String, String?>> extractTitleAndDateWithOpenAI(String text) async {
    final apiKey = Env.apiKey;
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': 'Extract the contest date and title from the following text in Korean:\n$text\n\nPlease return the output in this format:\n공모전 제목: <title>\n공모전 날짜: <date>'}
        ],
        'max_tokens': 100,
        'temperature': 0.2,
      }),
    );

    final responseBody = utf8.decode(response.bodyBytes);
    final responseData = jsonDecode(responseBody);

    if (responseData.containsKey('error')) {
      print('API 오류: ${responseData['error']['message']}');
      return {'title': null, 'date': null};
    }

    final completionText = responseData['choices'][0]['message']['content'];
    print('API 응답 텍스트: $completionText');

    final title = RegExp(r'공모전 제목: (.+)').firstMatch(completionText)?.group(1)?.trim();
    final dateString = RegExp(r'공모전 날짜: (.+)').firstMatch(completionText)?.group(1)?.trim();

    return {'title': title, 'date': dateString};
  }

  // 사용자 확인 다이얼로그
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("일정을 추가하시겠습니까?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (detectedTitle != null) Text("공모전 제목: $detectedTitle"),
              if (detectedDate != null) Text("공모전 일정: ${DateFormat('yyyy-MM-dd').format(detectedDate!)}"),
              if (detectedTitle == null && detectedDate == null)
                Text("공모전 정보가 없습니다."),
              SizedBox(height: 20),
              Text("이 정보가 맞습니까?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showManualInputDialog();
              },
              child: Text("아니요"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addEventToCalendar();
              },
              child: Text("예"),
            ),
          ],
        );
      },
    );
  }

  // 수동 입력 다이얼로그
  void _showManualInputDialog() {
    _titleController.clear();
    _dateController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("일정 정보 입력"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: "공모전 제목을 입력하세요"),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(hintText: "날짜를 입력하세요 (YYYY-MM-DD)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                _addManualEventToCalendar();
                Navigator.pop(context);
              },
              child: Text("추가"),
            ),
          ],
        );
      },
    );
  }

  // 수동 입력 이벤트 추가 함수
  void _addManualEventToCalendar() async {
    final manualTitle = _titleController.text;
    final manualDateText = _dateController.text;

    if (manualTitle.isNotEmpty && manualDateText.isNotEmpty) {
      try {
        final manualDate = DateFormat('yyyy-MM-dd').parse(manualDateText);
        final event = {'title': manualTitle, 'description': '사용자가 입력한 공모전', 'date': manualDate.toIso8601String()};

        await _dbHelper.insertEvent(event);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('일정이 추가되었습니다!')));
        _clearDetectedData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('날짜 형식이 올바르지 않습니다.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 정보를 입력해주세요.')));
    }
  }

  // 캘린더에 이벤트 추가
  Future<void> _addEventToCalendar() async {
    if (detectedTitle != null && detectedDate != null) {
      final event = {'title': detectedTitle!, 'description': 'OCR로 인식된 공모전', 'date': detectedDate!.toIso8601String()};
      await _dbHelper.insertEvent(event);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('일정이 추가되었습니다!')));
      _clearDetectedData();
    }
  }

  // 인식된 데이터 초기화
  void _clearDetectedData() {
    setState(() {
      detectedTitle = null;
      detectedDate = null;
      _titleController.clear();
      _dateController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30, width: double.infinity),
            _buildPhotoArea(),
            _buildRecognizedText(),
            SizedBox(height: 20),
            _buildButton(),
          ],
        ),
      ),
    );
  }
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

  // 인식된 텍스트를 화면에 표시하는 위젯
  Widget _buildRecognizedText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        scannedText.isNotEmpty ? scannedText : "인식된 텍스트가 없습니다.",
        textAlign: TextAlign.center,
      ),
    );
  }

  // 버튼 빌드 함수 (카메라, 갤러리)
  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            getImage(ImageSource.camera);
          },
          icon: Icon(Icons.camera_alt),
          label: Text("카메라"),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery);
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