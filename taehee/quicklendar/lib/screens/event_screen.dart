import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../general_event_database.dart'; // 일반 일정 데이터베이스 헬퍼 추가

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<Map<String, dynamic>> _events = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GeneralEventDatabaseHelper _generalDbHelper = GeneralEventDatabaseHelper(); // 일반 일정 DB 헬퍼 추가
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
    final contestEvents = await _dbHelper.queryAllEvents();
    final generalEvents = await _generalDbHelper.queryAllGeneralEvents();

    // 일반 일정과 공모전 이벤트를 모두 합치기
    setState(() {
      _events = [...contestEvents, ...generalEvents];
      _checked = List<bool>.filled(_events.length, false);
      _updateProgress();
    });
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _events = _events.where((event) {
        final title = (event['title'] ?? '').toLowerCase();
        final description = (event['description'] ?? '').toLowerCase();
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
    await _generalDbHelper.deleteGeneralEvent(id); // 일반 일정 삭제도 추가
    await _loadEvents();
  }

  Future<void> _editEvent(Map<String, dynamic> event) async {
    final titleController = TextEditingController(text: event['title']);
    final descriptionController = TextEditingController(text: event['description']);
    final organizerController = TextEditingController(text: event['organizer'] ?? '');
    final locationController = TextEditingController(text: event['location'] ?? '');
    final startDateController = TextEditingController(
        text: event['start_time'] ?? event['contest_start_date'] ?? '');
    final endDateController = TextEditingController(
        text: event['end_time'] ?? event['contest_end_date'] ?? '');
    String? selectedCategory = event['category'];
    String? selectedField = event['field'];

    // 일반 일정인지 공모전 일정인지 구분
    bool isGeneralEvent = event.containsKey('start_time');

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
                TextField(controller: startDateController, decoration: const InputDecoration(labelText: '시작 날짜')),
                TextField(controller: endDateController, decoration: const InputDecoration(labelText: '종료 날짜')),

                // 공모전 일정일 때만 표시
                if (!isGeneralEvent) ...[
                  DropdownButtonFormField<String>(
                    value: (selectedCategory?.isEmpty ?? true) ? null : selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value ?? '';
                      });
                    },
                    decoration: const InputDecoration(labelText: '카테고리'),
                  ),
                  DropdownButtonFormField<String>(
                    value: (selectedField?.isEmpty ?? true) ? null : selectedField,
                    items: fields.map((field) {
                      return DropdownMenuItem(
                        value: field,
                        child: Text(field),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedField = value ?? '';
                      });
                    },
                    decoration: const InputDecoration(labelText: '활동 분야'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final updatedEvent = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'organizer': organizerController.text,
                  'location': locationController.text,
                  'start_time': event['start_time'] ?? '',
                  'end_time': event['end_time'] ?? '',
                  'category': !isGeneralEvent ? selectedCategory ?? '' : '',
                  'field': !isGeneralEvent ? selectedField ?? '' : '',
                };

                if (isGeneralEvent) {
                  await _generalDbHelper.updateGeneralEvent(event['id'], updatedEvent);
                } else {
                  await _dbHelper.updateEvent(event['id'], updatedEvent);
                }
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
                  subtitle: Text('날짜: ${event['start_time'] ?? event['contest_start_date'] ?? '날짜 없음'}'),
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
