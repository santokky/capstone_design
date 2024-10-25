import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<Map<String, dynamic>> _events = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  TextEditingController _searchController = TextEditingController();
  bool _showProgress = false;
  List<bool> _checked = [];

  final List<String> categories = ['예술 및 디자인 분야', '기술 및 공학', '기타'];
  final List<String> fields = ['공모전', '대외활동'];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _searchController.addListener(_filterEvents);
  }

  Future<void> _loadEvents() async {
    final events = await _dbHelper.queryAllEvents();
    setState(() {
      _events = events;
      _checked = List<bool>.filled(_events.length, false);
      _updateProgress();
    });
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _events = _events.where((event) {
        final title = event['title'].toLowerCase();
        final description = event['description'].toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    });
  }

  void _updateProgress() {
    final checkedCount = _checked.where((element) => element).length;
    setState(() {
      _showProgress = checkedCount > 0;
    });
  }

  Future<void> _deleteEvent(int id) async {
    await _dbHelper.deleteEvent(id);
    await _loadEvents();
  }

  Future<void> _editEvent(Map<String, dynamic> event) async {
    final titleController = TextEditingController(text: event['title']);
    final descriptionController = TextEditingController(text: event['description']);
    final organizerController = TextEditingController(text: event['organizer']);
    final locationController = TextEditingController(text: event['location']);
    final applicationStartDateController = TextEditingController(text: event['application_start_date']);
    final applicationEndDateController = TextEditingController(text: event['application_end_date']);
    final contestStartDateController = TextEditingController(text: event['contest_start_date']);
    final contestEndDateController = TextEditingController(text: event['contest_end_date']);
    final applicationLinkController = TextEditingController(text: event['application_link']);
    final contactController = TextEditingController(text: event['contact']);
    String? selectedCategory = event['category'];
    String? selectedField = event['field'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('이벤트 수정'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: '상세 설명'),
                ),
                TextField(controller: organizerController, decoration: const InputDecoration(labelText: '주최자')),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: '장소')),
                TextField(controller: applicationStartDateController, decoration: const InputDecoration(labelText: '신청 시작 날짜')),
                TextField(controller: applicationEndDateController, decoration: const InputDecoration(labelText: '신청 마감 날짜')),
                TextField(controller: contestStartDateController, decoration: const InputDecoration(labelText: '시작 날짜')),
                TextField(controller: contestEndDateController, decoration: const InputDecoration(labelText: '종료 날짜')),
                TextField(controller: applicationLinkController, decoration: const InputDecoration(labelText: '신청 경로')),
                TextField(controller: contactController, decoration: const InputDecoration(labelText: '문의처')),
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
                      selectedCategory = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: '카테고리'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedField,
                  items: fields.map((field) {
                    return DropdownMenuItem(
                      value: field,
                      child: Text(field),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedField = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: '활동 분야'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _dbHelper.updateEvent(
                  event['id'],
                  {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'organizer': organizerController.text,
                    'location': locationController.text,
                    'application_start_date': applicationStartDateController.text,
                    'application_end_date': applicationEndDateController.text,
                    'contest_start_date': contestStartDateController.text,
                    'contest_end_date': contestEndDateController.text,
                    'application_link': applicationLinkController.text,
                    'contact': contactController.text,
                    'category': selectedCategory ?? '',
                    'field': selectedField ?? '',
                  },
                );
                Navigator.of(context).pop();
                await _loadEvents();
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이벤트 목록'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '이벤트 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_showProgress)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: LinearProgressIndicator(
                color: Colors.blueAccent,
                value: _checked.where((element) => element).length / _events.length,
              ),
            ),
          Expanded(
            child: _events.isEmpty
                ? Center(
              child: Text(
                '이벤트가 없습니다.',
                style: TextStyle(fontSize: 24.0),
              ),
            )
                : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return ListTile(
                  leading: Checkbox(
                    activeColor: Colors.blueAccent,
                    checkColor: Colors.white,
                    value: _checked[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _checked[index] = value!;
                        _updateProgress();
                      });
                    },
                  ),
                  title: Text(event['title']),
                  subtitle: Text('날짜: ${event['contest_start_date'] ?? '날짜 없음'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.lightGreen),
                        onPressed: () {
                          _editEvent(event);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await _deleteEvent(event['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
