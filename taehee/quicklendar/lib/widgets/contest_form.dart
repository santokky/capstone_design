import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../utils/http_contest.dart';

class ContestForm extends StatefulWidget {
  final Function(
      String imageUrl,
      String title,
      String organizer,
      String description,
      String location,
      DateTime applicationStart,
      DateTime applicationEnd,
      DateTime startDate,
      DateTime endDate,
      String applicationLink,
      String contact,
      String category,
      String activityType) onSubmit;

  const ContestForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _ContestFormState createState() => _ContestFormState();
}

class _ContestFormState extends State<ContestForm> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController organizerController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController applicationLinkController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  DateTime? applicationStartDate;
  DateTime? applicationEndDate;
  DateTime? startDate;
  DateTime? endDate;
  File? _selectedImage;

  String? selectedCategory = "예술 및 디자인 분야"; // 기본 카테고리 설정
  String? selectedActivityType = "공모전"; // 기본 활동 분야 설정

  // 카테고리 및 활동 분야 매핑
  final Map<String, String> categoryMapping = {
    "예술 및 디자인 분야": "CREATIVE_ARTS_AND_DESIGN",
    "기술 및 공학": "TECHNOLOGY_AND_ENGINEERING",
    "기타": "BUSINESS_AND_ACADEMIC", // '기타'를 매핑
  };

// 활동 분야 매핑
  final Map<String, String> activityTypeMapping = {
    "공모전": "COMPETITION",
    "대외활동": "ACTIVITY",
  };


  final List<String> categories = ["예술 및 디자인 분야", "기술 및 공학", "기타"];
  final List<String> activityTypes = ["공모전", "대외활동"];

  // 이미지 선택 함수
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 날짜 선택 함수
  Future<void> selectDate(BuildContext context, Function(DateTime) onDateSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 이미지 첨부
          _selectedImage != null
              ? Column(
            children: [
              Image.file(
                _selectedImage!,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('다른 이미지 선택'),
              ),
            ],
          )
              : ElevatedButton(
            onPressed: pickImage,
            child: const Text('포스터 이미지 선택'),
          ),
          const SizedBox(height: 16),

          // 공모전 제목 입력
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: '공모전 제목'),
          ),
          const SizedBox(height: 8),

          // 주최자 입력
          TextField(
            controller: organizerController,
            decoration: const InputDecoration(labelText: '주최자'),
          ),
          const SizedBox(height: 8),

          // 공모전 상세 설명
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: '공모전 상세 설명'),
            maxLines: 3,
          ),
          const SizedBox(height: 8),

          // 공모전 장소 입력
          TextField(
            controller: locationController,
            decoration: const InputDecoration(labelText: '공모전 장소'),
          ),
          const SizedBox(height: 8),

          // 신청 시작 날짜
          TextField(
            readOnly: true,
            decoration: const InputDecoration(labelText: '신청 시작 날짜'),
            onTap: () => selectDate(context, (date) => setState(() => applicationStartDate = date)),
            controller: TextEditingController(
              text: applicationStartDate != null
                  ? DateFormat('yyyy-MM-dd').format(applicationStartDate!)
                  : '',
            ),
          ),
          const SizedBox(height: 8),

          // 신청 종료 날짜
          TextField(
            readOnly: true,
            decoration: const InputDecoration(labelText: '신청 종료 날짜'),
            onTap: () => selectDate(context, (date) => setState(() => applicationEndDate = date)),
            controller: TextEditingController(
              text: applicationEndDate != null
                  ? DateFormat('yyyy-MM-dd').format(applicationEndDate!)
                  : '',
            ),
          ),
          const SizedBox(height: 8),

          // 공모전 시작 날짜
          TextField(
            readOnly: true,
            decoration: const InputDecoration(labelText: '공모전 시작 날짜'),
            onTap: () => selectDate(context, (date) => setState(() => startDate = date)),
            controller: TextEditingController(
              text: startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : '',
            ),
          ),
          const SizedBox(height: 8),

          // 공모전 종료 날짜
          TextField(
            readOnly: true,
            decoration: const InputDecoration(labelText: '공모전 종료 날짜'),
            onTap: () => selectDate(context, (date) => setState(() => endDate = date)),
            controller: TextEditingController(
              text: endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : '',
            ),
          ),
          const SizedBox(height: 8),

          // 신청 경로 입력
          TextField(
            controller: applicationLinkController,
            decoration: const InputDecoration(labelText: '신청 경로'),
          ),
          const SizedBox(height: 8),

          // 지원 연락처 입력
          TextField(
            controller: contactController,
            decoration: const InputDecoration(labelText: '지원 연락처'),
          ),
          const SizedBox(height: 16),

          // 카테고리 선택 (드롭다운)
          DropdownButtonFormField<String>(
            value: selectedCategory,
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
            decoration: const InputDecoration(labelText: '카테고리 선택'),
          ),
          const SizedBox(height: 16),

          // 활동 분야 선택 (드롭다운)
          DropdownButtonFormField<String>(
            value: selectedActivityType,
            items: activityTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedActivityType = value!;
              });
            },
            decoration: const InputDecoration(labelText: '활동 분야 선택'),
          ),
          const SizedBox(height: 16),

          // 제출 버튼
          // ... 기존 코드 생략 ...

// 제출 버튼
          ElevatedButton(
            onPressed: () {
              if (_selectedImage != null &&
                  titleController.text.isNotEmpty &&
                  organizerController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  locationController.text.isNotEmpty &&
                  applicationStartDate != null &&
                  applicationEndDate != null &&
                  startDate != null &&
                  endDate != null &&
                  applicationLinkController.text.isNotEmpty &&
                  contactController.text.isNotEmpty &&
                  selectedCategory != null &&
                  selectedActivityType != null) {
                final contestData = {
                  'imageUrl': _selectedImage!.path,
                  'name': titleController.text,
                  'host': organizerController.text,
                  'description': descriptionController.text,
                  'location': locationController.text,
                  'requestStartDate': applicationStartDate!.toIso8601String(),
                  'requestEndDate': applicationEndDate!.toIso8601String(),
                  'startDate': startDate!.toIso8601String(),
                  'endDate': endDate!.toIso8601String(),
                  'requestPath': applicationLinkController.text,
                  'support': contactController.text,
                  'category': categoryMapping[selectedCategory]!, // 카테고리 매핑
                  'competitionType': activityTypeMapping[selectedActivityType]!, // 활동 분야 매핑 (COMPETITION or ACTIVITY)
                };

                // 서버로 데이터 전송
                createContestWithImage(contestData, _selectedImage!).then((response) {
                  if (response['statusCode'] == 201) {
                    print('서버에 공모전 등록 성공');
                    widget.onSubmit(
                      _selectedImage!.path,
                      titleController.text,
                      organizerController.text,
                      descriptionController.text,
                      locationController.text,
                      applicationStartDate!,
                      applicationEndDate!,
                      startDate!,
                      endDate!,
                      applicationLinkController.text,
                      contactController.text,
                      selectedCategory!,
                      selectedActivityType!,
                    );
                    Navigator.of(context).pop();
                  } else {
                    print('서버 등록 실패: ${response['error']}');
                  }
                });
              } else {
                print('입력되지 않은 필드가 있습니다.');
              }
            },
            child: const Text('공모전 추가'),
          ),

        ],
      ),
    );
  }
}
