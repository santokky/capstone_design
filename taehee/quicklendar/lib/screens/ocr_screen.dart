import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../database_helper.dart'; // 데이터베이스 사용을 위한 헬퍼 파일 추가
import '/env/env.dart'; // 환경 변수 파일 import

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  OCRScreenState createState() => OCRScreenState();
}

class OCRScreenState extends State<OCRScreen> {
  XFile? _image;
  final ImagePicker picker = ImagePicker();
  Map<String, String?> detectedData = {};
  List<Map<String, dynamic>> textMetadata = [];
  final DatabaseHelper _dbHelper = DatabaseHelper(); // 데이터베이스 헬퍼 객체 생성
  String? selectedCategory;
  String? selectedField;
  bool isLoading = false;

  final List<String> categories = ['예술 및 디자인 분야', '기술 및 공학', '기타'];
  final List<String> fields = ['공모전', '대외활동'];

  @override
  void dispose() {
    super.dispose();
  }

  // 이미지 선택 함수
  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
        isLoading = true;
      });
      await getRecognizedText(_image!);
      setState(() {
        isLoading = false;
      });
    }
  }

  // Google Vision API를 사용한 텍스트 인식 함수
  Future<void> getRecognizedText(XFile image) async {
    try {
      final extractedData = await analyzeImageWithVisionAPI(image.path);
      setState(() {
        textMetadata = extractedData['metadata'];
      });

      // 추출된 텍스트를 OpenAI API로 분석
      detectedData = await extractContestDetailsWithOpenAI(extractedData['text'], textMetadata);

      if (detectedData.isNotEmpty) {
        _showConfirmationDialog();
      }
    } catch (e) {
      print('텍스트 추출 중 오류 발생: $e');
    }
  }

  // Google Vision API 호출 함수
  Future<Map<String, dynamic>> analyzeImageWithVisionAPI(String imagePath) async {
    final String apiKey = Env.googleVisionApiKey;  // 환경 변수 파일에서 Google Vision API 키 로드
    final String url = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';

    // 이미지 파일을 base64 인코딩
    final bytes = await File(imagePath).readAsBytes();
    final String base64Image = base64Encode(bytes);

    // 요청 페이로드 구성
    final Map<String, dynamic> requestPayload = {
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'TEXT_DETECTION'},
          ],
        },
      ],
    };

    // HTTP POST 요청
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestPayload),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['responses'] != null && responseData['responses'].isNotEmpty) {
        final fullTextAnnotation = responseData['responses'][0]['fullTextAnnotation'];
        final text = fullTextAnnotation?['text'] ?? '';
        final List<dynamic> annotations = responseData['responses'][0]['textAnnotations'] ?? [];
        final List<Map<String, dynamic>> metadata = annotations.map((annotation) {
          return {
            'boundingBox': annotation['boundingPoly'],
            'text': annotation['description'] ?? '',
          };
        }).toList();
        return {'text': text, 'metadata': metadata};
      } else {
        throw Exception('Google Vision API에서 유효한 응답을 받지 못했습니다.');
      }
    } else {
      throw Exception('Google Vision API 호출에 실패했습니다: ${response.body}');
    }
  }

  // OpenAI API로 텍스트 파싱 함수
  Future<Map<String, String?>> extractContestDetailsWithOpenAI(String text, List<Map<String, dynamic>> metadata) async {
    final apiKey = Env.openAiApiKey;
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
          {
            'role': 'user',
            'content': '''
다음은 공모전 포스터 이미지에서 추출된 텍스트와 위치 정보입니다. 이 정보를 바탕으로 공모전 제목, 주최자, 날짜 등을 파싱해주세요.

텍스트:
$text

텍스트의 메타정보 (위치 및 레이아웃 정보 포함):
$metadata

형식:
- 공모전 제목: <title>
- 주최자: <organizer>
- 상세 설명: <description>
- 장소: <location>
- 신청 시작 날짜: <application_start_date>
- 신청 종료 날짜: <application_end_date>
- 공모전 시작 날짜: <contest_start_date>
- 공모전 종료 날짜: <contest_end_date>
- 신청 경로: <application_link>
- 지원 연락처: <contact>
- 카테고리: <category>
- 활동 분야: <field>
'''
          }
        ],
        'max_tokens': 350,
        'temperature': 0.2,
      }),
    );

    final responseBody = utf8.decode(response.bodyBytes);
    final responseData = jsonDecode(responseBody);

    if (responseData.containsKey('error')) {
      print('API 오류: ${responseData['error']['message']}');
      return {};
    }

    final completionText = responseData['choices'][0]['message']['content'];
    print('API 응답 텍스트: $completionText');

    final Map<String, String?> extractedData = {
      'title': RegExp(r'공모전 제목: (.+)').firstMatch(completionText)?.group(1)?.trim(),
      'organizer': RegExp(r'주최자: (.+)').firstMatch(completionText)?.group(1)?.trim(),
      'description': RegExp(r'상세 설명: (.+)').firstMatch(completionText)?.group(1)?.trim(),
      'location': RegExp(r'장소: (.+)').firstMatch(completionText)?.group(1)?.trim(),
      'application_start_date': RegExp(r'신청 시작 날짜: (.+)').firstMatch(completionText)?.group(1)?.trim(),
      'application_end_date': RegExp(r'신청 종료 날짜: (.+)').firstMatch(completionText)?.group(1)?.trim(),
      'contest_start_date': RegExp(r'공모전 시작 날짜: (.+)').firstMatch(completionText)?.group(1)?.trim(),
      'contest_end_date': RegExp(r'공모전 종료 날짜: (.+)').firstMatch(completionText)?.group(1)?.trim(),
      'application_link': RegExp(r'신청 경로: (.+)').firstMatch(completionText)?.group(1)?.trim(),
      'contact': RegExp(r'지원 연락처: (.+)').firstMatch(completionText)?.group(1)?.trim(),
      'category': RegExp(r'카테고리: (.+)').firstMatch(completionText)?.group(1)?.trim(),
      'field': RegExp(r'활동 분야: (.+)').firstMatch(completionText)?.group(1)?.trim(),
    };

    // 특정 패턴 보강: 이메일, 전화번호, URL 정규식 추가
    final emailPattern = RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w+\b');
    final phonePattern = RegExp(r'\b\d{2,3}-\d{3,4}-\d{4}\b');
    final urlPattern = RegExp(r'\bhttps?://[\w\.-]+\.[a-z]{2,}(?:/[\w\.-]*)*\b');

    if (extractedData['application_link'] == null || !urlPattern.hasMatch(extractedData['application_link']!)) {
      final urlMatch = urlPattern.firstMatch(text);
      if (urlMatch != null) {
        extractedData['application_link'] = urlMatch.group(0)?.trim();
      }
    }

    if (extractedData['contact'] == null || (!phonePattern.hasMatch(extractedData['contact']!) && !emailPattern.hasMatch(extractedData['contact']!))) {
      final phoneMatch = phonePattern.firstMatch(text);
      final emailMatch = emailPattern.firstMatch(text);
      extractedData['contact'] = phoneMatch?.group(0)?.trim() ?? emailMatch?.group(0)?.trim();
    }

    return extractedData;
  }

  // 사용자 확인 다이얼로그
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("추출된 정보가 맞습니까?"),
          content: isLoading
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('텍스트 추출 중...'),
            ],
          )
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...detectedData.entries.map((entry) {
                  if (entry.key == 'category') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: '카테고리',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedCategory ?? entry.value,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedCategory = value),
                      ),
                    );
                  } else if (entry.key == 'field') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: '활동 분야',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedField ?? entry.value,
                        items: fields.map((field) {
                          return DropdownMenuItem(
                            value: field,
                            child: Text(field),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedField = value),
                      ),
                    );
                  } else if (entry.key == 'title' || entry.key == 'description' || entry.key == 'organizer' || entry.key == 'location') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        maxLines: entry.key == 'title' ? 2 : entry.key == 'description' ? 8 : 2,
                        decoration: InputDecoration(
                          labelText: _getLabelText(entry.key),
                          border: OutlineInputBorder(),
                        ),
                        initialValue: entry.value,
                        onChanged: (value) => detectedData[entry.key] = value,
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: _getLabelText(entry.key),
                          border: OutlineInputBorder(),
                        ),
                        initialValue: entry.value,
                        onChanged: (value) => detectedData[entry.key] = value,
                      ),
                    );
                  }
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addEventToCalendar(detectedData);
              },
              child: Text("저장"),
            ),
          ],
        );
      },
    );
  }

  String _getLabelText(String key) {
    switch (key) {
      case 'organizer':
        return '주최자';
      case 'location':
        return '장소';
      case 'application_start_date':
        return '신청 시작 날짜';
      case 'application_end_date':
        return '신청 종료 날짜';
      case 'contest_start_date':
        return '공모전 시작 날짜';
      case 'contest_end_date':
        return '공모전 종료 날짜';
      case 'application_link':
        return '신청 경로';
      case 'contact':
        return '지원 연락처';
      default:
        return key;
    }
  }

  // 이벤트 추가 함수
  Future<void> _addEventToCalendar(Map<String, String?> contestData) async {
    if (contestData['title'] != null && contestData['contest_start_date'] != null) {
      final event = {
      'title': contestData['title'],
      'organizer': contestData['organizer'],
      'description': contestData['description'],
        'location': contestData['location'],
        'application_start_date': contestData['application_start_date'],
        'application_end_date': contestData['application_end_date'],
        'contest_start_date': contestData['contest_start_date'],
        'contest_end_date': contestData['contest_end_date'],
        'application_link': contestData['application_link'],
        'contact': contestData['contact'],
        'category': selectedCategory ?? contestData['category'],
        'field': selectedField ?? contestData['field'],
        'imageUrl': _image?.path,  // 이미지 파일 경로 추가
      };
      try {
        await _dbHelper.insertEvent(event);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('공모전 이벤트가 저장되었습니다!')));
      } catch (e) {
        print('저장 중 오류 발생: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 중 오류가 발생했습니다.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('필수 정보가 없습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('텍스트 추출 중...'),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30, width: double.infinity),
            _buildPhotoArea(),
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