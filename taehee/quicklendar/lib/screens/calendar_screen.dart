import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database_helper.dart';

class Event {
  final String title;
  final String organizer;
  final String description;
  final String location;
  final String applicationStartDate;
  final String applicationEndDate;
  final String contestStartDate;
  final String contestEndDate;
  final String applicationLink;
  final String contact;
  final String category;
  final String field;

  Event({
    required this.title,
    this.organizer = '',
    this.description = '',
    this.location = '',
    this.applicationStartDate = '',
    this.applicationEndDate = '',
    this.contestStartDate = '',
    this.contestEndDate = '',
    this.applicationLink = '',
    this.contact = '',
    this.category = '',
    this.field = '',
  });

  // Event 객체를 Map<String, dynamic>로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'organizer': organizer,
      'description': description,
      'location': location,
      'application_start_date': applicationStartDate,
      'application_end_date': applicationEndDate,
      'contest_start_date': contestStartDate,
      'contest_end_date': contestEndDate,
      'application_link': applicationLink,
      'contact': contact,
      'category': category,
      'field': field,
    };
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _showHolidays = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<Event>> _selectedEvents;
  late final ValueNotifier<List<Event>> _selectedHolidayEvents;
  late Map<DateTime, List<Event>> _events;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final Map<DateTime, List<Event>> holidayEvents = {
    DateTime(2024, 1, 1): [Event(title: '새해')],
    DateTime(2024, 2, 10): [Event(title: '설날')],
    DateTime(2024, 3, 1): [Event(title: '삼일절')],
    DateTime(2024, 5, 5): [Event(title: '어린이날')],
    DateTime(2024, 6, 6): [Event(title: '현충일')],
    DateTime(2024, 8, 15): [Event(title: '광복절')],
    DateTime(2024, 10, 3): [Event(title: '개천절')],
    DateTime(2024, 10, 9): [Event(title: '한글날')],
    DateTime(2024, 12, 25): [Event(title: '기독탄신일')],
  };

  @override
  void initState() {
    super.initState();
    _loadCalendarSettings();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _selectedHolidayEvents = ValueNotifier([]);
    _events = {};
    _loadEvents();
  }

  Future<void> _loadCalendarSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String calendarView = prefs.getString('calendarView') ?? '월간';
    setState(() {
      _calendarFormat = calendarView == '월간'
          ? CalendarFormat.month
          : calendarView == '2주간'
          ? CalendarFormat.twoWeeks
          : CalendarFormat.week;
      _showHolidays = prefs.getBool('showHolidays') ?? true;
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);

        DateTime normalizedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
        if (holidayEvents.containsKey(normalizedDay)) {
          _selectedHolidayEvents.value = holidayEvents[normalizedDay]!;
        } else {
          _selectedHolidayEvents.value = [];
        }
      });
    }
  }

  Future<void> _loadEvents() async {
    final events = await _dbHelper.queryAllEvents();
    setState(() {
      _events.clear();
      for (var event in events) {
        try {
          final date = DateFormat('yyyy년 MM월 dd일(E)', 'ko_KR').parse(
              event['contest_start_date']);
          final eventDate = DateTime.utc(date.year, date.month, date.day);
          if (_events[eventDate] == null) {
            _events[eventDate] = [];
          }
          _events[eventDate]!.add(Event(
            title: event['title'] ?? '',
            organizer: event['organizer'] ?? '',
            description: event['description'] ?? '',
            location: event['location'] ?? '',
            applicationStartDate: event['application_start_date'] ?? '',
            applicationEndDate: event['application_end_date'] ?? '',
            contestStartDate: event['contest_start_date'] ?? '',
            contestEndDate: event['contest_end_date'] ?? '',
            applicationLink: event['application_link'] ?? '',
            contact: event['contact'] ?? '',
            category: event['category'] ?? '',
            field: event['field'] ?? '',
          ));
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    final eventDate = DateTime.utc(day.year, day.month, day.day);
    List<Event> events = _events[eventDate] ?? [];

    if (_showHolidays && holidayEvents.containsKey(eventDate)) {
      events.addAll(holidayEvents[eventDate]!);
    }
    return events;
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.organizer.isNotEmpty) _buildDetailRow('주최자', event.organizer),
                if (event.description.isNotEmpty) _buildDetailRow('상세 설명', event.description),
                if (event.location.isNotEmpty) _buildDetailRow('장소', event.location),
                if (event.applicationStartDate.isNotEmpty) _buildDetailRow('신청 시작 날짜', event.applicationStartDate),
                if (event.applicationEndDate.isNotEmpty) _buildDetailRow('신청 종료 날짜', event.applicationEndDate),
                if (event.contestStartDate.isNotEmpty) _buildDetailRow('공모전 시작 날짜', event.contestStartDate),
                if (event.contestEndDate.isNotEmpty) _buildDetailRow('공모전 종료 날짜', event.contestEndDate),
                if (event.applicationLink.isNotEmpty) _buildDetailRow('신청 경로', event.applicationLink),
                if (event.contact.isNotEmpty) _buildDetailRow('지원 연락처', event.contact),
                if (event.category.isNotEmpty) _buildDetailRow('카테고리', event.category),
                if (event.field.isNotEmpty) _buildDetailRow('활동 분야', event.field),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  String? selectedCategory = "예술 및 디자인 분야";  // 기본 카테고리 설정
  String? selectedActivityType = "공모전";  // 기본 활동 분야 설정

  Future<void> _showAddEventDialog() async {
    final titleController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("일정 추가"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: '제목')),

              // 카테고리 선택
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: '카테고리 선택'),
                items: ['예술 및 디자인 분야', '기술 및 공학', '기타'].map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 8),

              // 활동 분야 선택
              DropdownButtonFormField<String>(
                value: selectedActivityType,
                decoration: const InputDecoration(labelText: '활동 분야 선택'),
                items: ['공모전', '대외활동'].map((activityType) {
                  return DropdownMenuItem(value: activityType, child: Text(activityType));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedActivityType = value;
                  });
                },
              ),
              const SizedBox(height: 8),

              // 시작 날짜
              TextField(
                readOnly: true,
                decoration: const InputDecoration(labelText: '시작 날짜'),
                controller: startDateController,
                onTap: () async {
                  final date = await selectDate(context);
                  if (date != null) {
                    startDateController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
              const SizedBox(height: 8),

              // 종료 날짜
              TextField(
                readOnly: true,
                decoration: const InputDecoration(labelText: '종료 날짜'),
                controller: endDateController,
                onTap: () async {
                  final date = await selectDate(context);
                  if (date != null) {
                    endDateController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("취소")),
            TextButton(
              onPressed: () async {
                final event = Event(
                  title: titleController.text,
                  category: selectedCategory!,
                  field: selectedActivityType!,
                  contestStartDate: startDateController.text,
                  contestEndDate: endDateController.text,
                );

                await _dbHelper.insertEvent(event.toMap());
                await _loadEvents();
                Navigator.pop(context);
              },
              child: Text("추가"),
            ),
          ],
        );
      },
    );
  }

// 날짜 선택 함수
  Future<DateTime?> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return picked;
  }


  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('달력')),
      body: Column(
        children: [
          TableCalendar(
            locale: "ko_KR",
            firstDay: DateTime.utc(2010, 3, 14),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            holidayPredicate: (day) {
              DateTime normalizedDay = DateTime(day.year, day.month, day.day);
              return _showHolidays && holidayEvents.keys.any((holiday) => isSameDay(normalizedDay, holiday));
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,
              weekendTextStyle: TextStyle(color: Colors.red),
              holidayTextStyle: TextStyle(color: _showHolidays ? Colors.red : (isDarkMode ? Colors.white : Colors.black)),
              defaultTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              holidayDecoration: BoxDecoration(),
              markersAlignment: Alignment.bottomCenter,
              markerDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              markersMaxCount: 3,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red),
              weekdayStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          ),
          const SizedBox(height: 8.0),
          ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedHolidayEvents,
            builder: (context, holidayEvents, _) {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: holidayEvents.length,
                itemBuilder: (context, index) {
                  final holiday = holidayEvents[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(holiday.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return ListTile(
                      title: Text(event.title),
                      subtitle: Text(event.organizer.isNotEmpty ? '주최자: ${event.organizer}' : '주최자 정보 없음'),
                      onTap: () => _showEventDetails(event),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddEventDialog, child: Icon(Icons.add)),
    );
  }
}
