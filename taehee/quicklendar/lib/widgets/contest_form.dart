import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
      ) onSubmit;

  const ContestForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _ContestFormState createState() => _ContestFormState();
}

class _ContestFormState extends State<ContestForm> {
  File? _selectedImage;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController organizerController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController applicationLinkController = TextEditingController();
  DateTime? applicationStartDate;
  DateTime? applicationEndDate;
  DateTime? startDate;
  DateTime? endDate;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> selectDate(BuildContext context, TextEditingController controller, Function(DateTime) onDatePicked) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        onDatePicked(pickedDate);
      });
    }
  }

  void submitForm() {
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
        contactController.text.isNotEmpty) {
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
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

          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: '공모전 제목',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: organizerController,
            decoration: const InputDecoration(
              labelText: '주최자',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: '공모전 상세 설명',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            maxLines: 7,
          ),
          const SizedBox(height: 8),

          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: '공모전 장소',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            readOnly: true,
            decoration: const InputDecoration(
              labelText: '신청 시작 날짜',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            controller: TextEditingController(
              text: applicationStartDate != null
                  ? DateFormat('yyyy-MM-dd').format(applicationStartDate!)
                  : '',
            ),
            onTap: () {
              selectDate(context, TextEditingController(), (date) {
                applicationStartDate = date;
              });
            },
          ),
          const SizedBox(height: 8),

          TextField(
            readOnly: true,
            decoration: const InputDecoration(
              labelText: '신청 종료 날짜',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            controller: TextEditingController(
              text: applicationEndDate != null
                  ? DateFormat('yyyy-MM-dd').format(applicationEndDate!)
                  : '',
            ),
            onTap: () {
              selectDate(context, TextEditingController(), (date) {
                applicationEndDate = date;
              });
            },
          ),
          const SizedBox(height: 8),

          TextField(
            readOnly: true,
            decoration: const InputDecoration(
              labelText: '공모전 시작 날짜',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            controller: TextEditingController(
              text: startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : '',
            ),
            onTap: () {
              selectDate(context, TextEditingController(), (date) {
                startDate = date;
              });
            },
          ),
          const SizedBox(height: 8),

          TextField(
            readOnly: true,
            decoration: const InputDecoration(
              labelText: '공모전 종료 날짜',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            controller: TextEditingController(
              text: endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : '',
            ),
            onTap: () {
              selectDate(context, TextEditingController(), (date) {
                endDate = date;
              });
            },
          ),
          const SizedBox(height: 8),

          TextField(
            controller: applicationLinkController,
            decoration: const InputDecoration(
              labelText: '신청 경로',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: contactController,
            decoration: const InputDecoration(
              labelText: '지원 연락처',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: submitForm,
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}
