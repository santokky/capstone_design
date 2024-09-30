import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart'; // 데이터베이스 사용을 위한 헬퍼 파일

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
  final DatabaseHelper _dbHelper = DatabaseHelper();
  DateTime? detectedDate;  // 인식된 날짜
  String? detectedTitle;   // 인식된 제목

  TextEditingController _titleController = TextEditingController();
  TextEditingController _dateController = TextEditingController();  // 날짜 입력 컨트롤러

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // OCR로 텍스트 인식 함수
  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
      getRecognizedText(_image!);
    }
  }

  // OCR로 텍스트 인식하고 날짜 및 제목 추출
  void getRecognizedText(XFile image) async {
    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer =
    GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.korean);
    RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
      }
    }

    // 제목과 날짜 추출 (예시)
    detectedTitle = _extractTitle(scannedText);
    detectedDate = _extractDate(scannedText);

    if (detectedTitle != null || detectedDate != null) {
      _showConfirmationDialog();
    }

    setState(() {});
  }

  // 텍스트에서 공모전 제목 추출 (고급 로직)
  String? _extractTitle(String text) {
    // "몇 회" 또는 "yyyy" 연도와 함께 "공모전"을 포함하는 정규 표현식
    RegExp specificTitleExp = RegExp(r"(\d{1,2}회\s+[\s\S]*?공모전|\d{4}\s+[\s\S]*?공모전)", multiLine: true);
    Iterable<Match> specificMatches = specificTitleExp.allMatches(text);

    // 특정 패턴에 맞는 제목이 있다면 반환
    for (var match in specificMatches) {
      // 줄바꿈 문자를 공백으로 대체하여 반환
      return match.group(0)?.replaceAll('\n', ' ')?.trim();
    }

    // 위의 특정 형식에 맞지 않을 경우, 공모전 앞의 최대 10자 추출로 변경하여 더 많은 컨텍스트를 포함
    RegExp generalTitleExp = RegExp(r".{0,15}\s*공모전", dotAll: true); // dotAll: true는 줄바꿈 문자를 포함하여 모든 문자를 .에 포함시킴
    Iterable<Match> generalMatches = generalTitleExp.allMatches(text);

    for (var match in generalMatches) {
      return match.group(0)?.trim();
    }

    // 적합한 제목이 없으면 null 반환
    return null;
  }


  // 텍스트에서 날짜 추출 (예시)
  DateTime? _extractDate(String text) {
    // 여러 형식의 날짜를 인식하도록 정규식 확장 (yyyy-mm-dd, yyyy.mm.dd, yyyy/mm/dd, yyyy년 mm월 dd일)
    RegExp dateExp = RegExp(r"\d{4}[-/.]\d{1,2}[-/.]\d{1,2}|\d{4}년\s?\d{1,2}월\s?\d{1,2}일");
    Match? match = dateExp.firstMatch(text);
    if (match != null) {
      String matchedDate = match.group(0)!;

      try {
        // '-' 또는 '/' 또는 '.'을 구분자로 사용하여 날짜 형식 변환
        if (matchedDate.contains('년')) {
          // "yyyy년 mm월 dd일" 형식일 경우 처리
          return DateFormat('yyyy년 MM월 dd일').parse(matchedDate);
        } else {
          // 일반 형식 처리 ("yyyy-MM-dd", "yyyy.MM.dd", "yyyy/MM/dd")
          return DateFormat('yyyy-MM-dd').parse(matchedDate.replaceAll('.', '-').replaceAll('/', '-'));
        }
      } catch (e) {
        print('날짜 변환 오류: $e');
      }
    }
    return null;
  }

  // 사용자에게 제목과 날짜를 함께 묻는 다이얼로그
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
              if (detectedDate != null)
                Text("공모전 일정: ${DateFormat('yyyy-MM-dd').format(detectedDate!)}"),
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
                _showManualInputDialog(); // 사용자가 직접 입력하는 창을 표시
              },
              child: Text("아니요"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addEventToCalendar(); // 캘린더에 일정 추가
              },
              child: Text("예"),
            ),
          ],
        );
      },
    );
  }

  // 직접 입력할 수 있는 창을 표시하는 함수
  void _showManualInputDialog() {
    _titleController.clear();  // 제목 필드 초기화
    _dateController.clear();   // 날짜 필드 초기화

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
                Navigator.pop(context); // 취소 버튼
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                _addManualEventToCalendar(); // 직접 입력한 정보로 캘린더에 일정 추가
                Navigator.pop(context);
              },
              child: Text("추가"),
            ),
          ],
        );
      },
    );
  }

  // 직접 입력한 이벤트를 캘린더에 추가하는 함수
  void _addManualEventToCalendar() async {
    final manualTitle = _titleController.text;
    final manualDateText = _dateController.text;

    if (manualTitle.isNotEmpty && manualDateText.isNotEmpty) {
      try {
        final manualDate = DateFormat('yyyy-MM-dd').parse(manualDateText);

        final event = {
          'title': manualTitle,
          'description': '사용자가 입력한 공모전',
          'date': manualDate.toIso8601String(),
        };
        await _dbHelper.insertEvent(event);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일정이 추가되었습니다!')),
        );
        _clearDetectedData(); // 인식된 데이터 초기화
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('날짜 형식이 올바르지 않습니다.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 정보를 입력해주세요.')),
      );
    }
  }

  // 캘린더에 이벤트 추가
  Future<void> _addEventToCalendar() async {
    if (detectedTitle != null && detectedDate != null) {
      final event = {
        'title': detectedTitle!,
        'description': 'OCR로 인식된 공모전',
        'date': detectedDate!.toIso8601String(),
      };
      await _dbHelper.insertEvent(event);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정이 추가되었습니다!')),
      );
      _clearDetectedData(); // 인식된 데이터 초기화
    }
  }

  // 인식된 데이터 초기화
  void _clearDetectedData() {
    setState(() {
      detectedTitle = null;
      detectedDate = null;
      _titleController.clear(); // 수동 입력 필드 초기화
      _dateController.clear(); // 날짜 필드 초기화
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
