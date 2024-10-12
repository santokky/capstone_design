import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<Event>> _selectedEvents;
  late Map<DateTime, List<Event>> _events;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _events = {};
    _loadEvents();
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
      });
    }
  }

  Future<void> _loadEvents() async {
    final events = await _dbHelper.queryAllEvents();
    setState(() {
      _events.clear();
      for (var event in events) {
        try {
          final date = DateFormat('yyyy년 MM월 dd일(E)', 'ko_KR').parse(event['contest_start_date']);
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
    return _events[eventDate] ?? [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('달력'),
      ),
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
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: true,
              weekendTextStyle: TextStyle(color: Colors.red),
              defaultTextStyle: TextStyle(color: Colors.black),
              markersAlignment: Alignment.bottomCenter,
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red),
              weekdayStyle: TextStyle(color: Colors.black),
            ),
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
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
                      onTap: () {
                        _showEventDetails(event);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}