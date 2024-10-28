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
  late final ValueNotifier<List<Event>> _selectedHolidayEvents; // 공휴일 정보를 저장하는 변수
  late Map<DateTime, List<Event>> _events;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 공휴일 이벤트 맵 (시간 정보 제거)
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
    DateTime(2025, 1, 1): [Event(title: '새해')],
    DateTime(2025, 2, 10): [Event(title: '설날')],
    DateTime(2025, 3, 1): [Event(title: '삼일절')],
    DateTime(2025, 5, 5): [Event(title: '어린이날')],
    DateTime(2025, 6, 6): [Event(title: '현충일')],
    DateTime(2025, 8, 15): [Event(title: '광복절')],
    DateTime(2025, 10, 3): [Event(title: '개천절')],
    DateTime(2025, 10, 9): [Event(title: '한글날')],
    DateTime(2025, 12, 25): [Event(title: '기독탄신일')],
    // 추가 공휴일
  };

  @override
  void initState() {
    super.initState();
    _loadCalendarSettings();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _selectedHolidayEvents = ValueNotifier([]); // 공휴일 정보를 초기화
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

        // 공휴일인 경우 공휴일 정보를 _selectedHolidayEvents에 저장
        DateTime normalizedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
        if (holidayEvents.containsKey(normalizedDay)) {
          _selectedHolidayEvents.value = holidayEvents[normalizedDay]!;
        } else {
          _selectedHolidayEvents.value = []; // 공휴일이 아닌 경우 초기화
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

    // 공휴일 표시가 활성화된 경우 공휴일 추가
    if (_showHolidays && holidayEvents.containsKey(eventDate)) {
      events.addAll(holidayEvents[eventDate]!);
    }
    return _events[eventDate] ?? [];
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              event.title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.organizer.isNotEmpty) _buildDetailRow(
                    '주최자', event.organizer),
                if (event.description.isNotEmpty) _buildDetailRow(
                    '상세 설명', event.description),
                if (event.location.isNotEmpty) _buildDetailRow(
                    '장소', event.location),
                if (event.applicationStartDate.isNotEmpty) _buildDetailRow(
                    '신청 시작 날짜', event.applicationStartDate),
                if (event.applicationEndDate.isNotEmpty) _buildDetailRow(
                    '신청 종료 날짜', event.applicationEndDate),
                if (event.contestStartDate.isNotEmpty) _buildDetailRow(
                    '공모전 시작 날짜', event.contestStartDate),
                if (event.contestEndDate.isNotEmpty) _buildDetailRow(
                    '공모전 종료 날짜', event.contestEndDate),
                if (event.applicationLink.isNotEmpty) _buildDetailRow(
                    '신청 경로', event.applicationLink),
                if (event.contact.isNotEmpty) _buildDetailRow(
                    '지원 연락처', event.contact),
                if (event.category.isNotEmpty) _buildDetailRow(
                    '카테고리', event.category),
                if (event.field.isNotEmpty) _buildDetailRow(
                    '활동 분야', event.field),
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
    // 다크 모드 여부를 확인
    bool isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;

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
            holidayPredicate: (day) {
              // 날짜 비교를 위한 시간 정보 제거
              DateTime normalizedDay = DateTime(day.year, day.month, day.day);
              return _showHolidays && holidayEvents.keys.any((holiday) => isSameDay(normalizedDay, holiday));
            },
            // 달력의 스타일을 다크모드와 라이트모드에 따라 다르게 설정
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,
              weekendTextStyle: TextStyle(color: Colors.red),
              holidayTextStyle: TextStyle(
                color: _showHolidays ? Colors.red : (isDarkMode ? Colors.white : Colors.black),
              ),
              defaultTextStyle: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black),
              holidayDecoration: BoxDecoration(),
              // 다크모드일 때 흰색으로 변경
              markersAlignment: Alignment.bottomCenter,
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red),
              weekdayStyle: TextStyle(color: isDarkMode ? Colors.white : Colors
                  .black), // 다크모드일 때 흰색으로 변경
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
          // 선택한 날짜의 공휴일 정보를 표시
          ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedHolidayEvents,
            builder: (context, holidayEvents, _) {
              return ListView.builder(
                shrinkWrap: true, // ListView의 크기를 자식 항목에 맞춤
                physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
                itemCount: holidayEvents.length,
                itemBuilder: (context, index) {
                  final holiday = holidayEvents[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        holiday.title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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
                      subtitle: Text(event.organizer.isNotEmpty ? '주최자: ${event
                          .organizer}' : '주최자 정보 없음'),
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