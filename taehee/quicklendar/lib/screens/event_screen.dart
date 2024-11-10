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
    final locationController = TextEditingController(text: event['location'] ?? '');
    final startDateController = TextEditingController(text: event['start_time'] ?? ''); // 정의 추가
    final endDateController = TextEditingController(text: event['end_time'] ?? ''); // 정의 추가

    final organizerController = TextEditingController(text: event['organizer'] ?? '');
    final applicationStartDateController = TextEditingController(text: event['application_start_date'] ?? '');
    final applicationEndDateController = TextEditingController(text: event['application_end_date'] ?? '');
    final contestStartDateController = TextEditingController(text: event['contest_start_date'] ?? '');
    final contestEndDateController = TextEditingController(text: event['contest_end_date'] ?? '');
    final applicationLinkController = TextEditingController(text: event['application_link'] ?? '');
    final contactController = TextEditingController(text: event['contact'] ?? '');

    // 기본값 설정 시 리스트 내에 있는지 확인 후 설정
    String? selectedCategory = event['category'];
    if (selectedCategory == null || !categories.contains(selectedCategory)) {
      selectedCategory = null; // 리스트에 없는 경우 null로 설정
    }

    String? selectedField = event['field'];
    if (selectedField == null || !fields.contains(selectedField)) {
      selectedField = null; // 리스트에 없는 경우 null로 설정
    }

    bool isGeneralEvent = event.containsKey('start_time');

    Future<void> _selectDate(TextEditingController controller) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        locale: const Locale('ko'), // 한국어로 설정
      );

      if (pickedDate != null) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        setState(() {
          controller.text = formattedDate;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isGeneralEvent ? '일반 일정 수정' : '공모전 일정 수정'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: '상세 설명'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: '장소'),
                ),
                if (isGeneralEvent) ...[
                  GestureDetector(
                    onTap: () => _selectDate(startDateController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: startDateController,
                        decoration: const InputDecoration(labelText: '시작 날짜'),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(endDateController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: endDateController,
                        decoration: const InputDecoration(labelText: '종료 날짜'),
                      ),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: organizerController,
                    decoration: const InputDecoration(labelText: '주최자'),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(applicationStartDateController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: applicationStartDateController,
                        decoration: const InputDecoration(labelText: '신청 시작 날짜'),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(applicationEndDateController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: applicationEndDateController,
                        decoration: const InputDecoration(labelText: '신청 종료 날짜'),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(contestStartDateController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: contestStartDateController,
                        decoration: const InputDecoration(labelText: '공모전 시작 날짜'),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(contestEndDateController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: contestEndDateController,
                        decoration: const InputDecoration(labelText: '공모전 종료 날짜'),
                      ),
                    ),
                  ),
                  TextField(
                    controller: applicationLinkController,
                    decoration: const InputDecoration(labelText: '신청 경로'),
                  ),
                  TextField(
                    controller: contactController,
                    decoration: const InputDecoration(labelText: '지원 연락처'),
                  ),
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
                  'location': locationController.text,
                };

                if (isGeneralEvent) {
                  updatedEvent.addAll({
                    'start_time': startDateController.text,
                    'end_time': endDateController.text,
                  });
                } else {
                  updatedEvent.addAll({
                    'organizer': organizerController.text,
                    'application_start_date': applicationStartDateController.text,
                    'application_end_date': applicationEndDateController.text,
                    'contest_start_date': contestStartDateController.text,
                    'contest_end_date': contestEndDateController.text,
                    'application_link': applicationLinkController.text,
                    'contact': contactController.text,
                    'category': selectedCategory ?? '',
                    'field': selectedField ?? '',
                  });
                }

                try {
                  int result;
                  if (isGeneralEvent) {
                    result = await _generalDbHelper.updateGeneralEvent(event['id'], updatedEvent);
                  } else {
                    result = await _dbHelper.updateEvent(event['id'], updatedEvent);
                  }

                  if (result > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${isGeneralEvent ? '일반' : '공모전'} 일정이 성공적으로 수정되었습니다.')),
                    );
                    Navigator.of(context).pop();
                    await _loadEvents(); // UI 갱신
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이벤트 수정에 실패했습니다. 다시 시도해 주세요.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('오류 발생: $e')),
                  );
                }
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
