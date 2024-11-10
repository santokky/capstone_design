import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database_helper.dart';
import '../general_event_database.dart'; // 일반 일정 데이터베이스 헬퍼 불러오기
import 'package:klc/klc.dart';

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

class GeneralEvent {
  final String title;
  final String? description;
  final String? location;
  final String startTime;
  final String endTime;
  final String? reminderTime;
  final String createdAt;

  GeneralEvent({
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    this.reminderTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'start_time': startTime,
      'end_time': endTime,
      'reminder_time': reminderTime,
      'created_at': createdAt,
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
  late final ValueNotifier<List<dynamic>> _selectedEvents;
  late Map<DateTime, List<dynamic>> _events;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GeneralEventDatabaseHelper _generalDbHelper = GeneralEventDatabaseHelper(); // 일반 일정 DB 헬퍼 추가

  List<DateTime> _holidays = [];

  @override
  void initState() {
    super.initState();
    _loadCalendarSettings();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _events = {};
    _loadEvents();
    _loadGeneralEvents();
    _calculateHolidays();
  }

  void _calculateHolidays() {
    for (int year = 2000; year <= 2100; year++) {
      _holidays.addAll([
        DateTime(year, 1, 1),  // 신정
        DateTime(year, 3, 1),  // 3.1절
        DateTime(year, 5, 5),  // 어린이날
        DateTime(year, 6, 6),  // 현충일
        DateTime(year, 8, 15), // 광복절
        DateTime(year, 10, 3), // 개천절
        DateTime(year, 10, 9), // 한글날
        DateTime(year, 12, 25), // 크리스마스
      ]);

      setLunarDate(year, 1, 1, false); // 설날
      DateTime lunarNewYear = DateTime.parse(getSolarIsoFormat());
      setLunarDate(year, 4, 8, false); // 석가탄신일
      DateTime buddhasBirthday = DateTime.parse(getSolarIsoFormat());
      setLunarDate(year, 8, 15, false); // 추석
      DateTime chuseok = DateTime.parse(getSolarIsoFormat());

      _holidays.addAll([
        lunarNewYear,
        lunarNewYear.add(Duration(days: 1)),
        lunarNewYear.subtract(Duration(days: 1)),
        buddhasBirthday,
        chuseok,
        chuseok.add(Duration(days: 1)),
        chuseok.subtract(Duration(days: 1)),
      ]);
    }
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

  DateTime? parseEventDate(String dateString) {
    // 사용할 다양한 날짜 형식
    final List<DateFormat> formats = [
      DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR'), // 요일 포함 형식
      DateFormat('yyyy년 MM월 dd일'), // 요일 없는 형식
      DateFormat('yyyy.MM.dd'), // 점(.) 구분 형식
      DateFormat('yyyy.MM.dd.'), // 점(.) 구분 형식 +일자에 점하나 더
      DateFormat('yyyy-MM-dd'), // 대시(-) 구분 형식
    ];

    for (final format in formats) {
      try {
        return format.parse(dateString);
      } catch (e) {
        // 형식이 맞지 않을 경우 다음 형식으로 시도
        continue;
      }
    }

    // 모든 형식이 실패한 경우 null 반환
    print('Error parsing event date: unable to parse $dateString');
    return null;
  }

  Future<void> _loadEvents() async {
    final events = await _dbHelper.queryAllEvents();
    setState(() {
      _events.clear();
      for (var event in events) {
        // 날짜 파싱 시 parseEventDate 함수 사용
        final date = parseEventDate(event['contest_start_date']);
        if (date != null) {
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
        } else {
          print('Error parsing event date: unable to parse ${event['contest_start_date']}');
        }
      }
    });
  }

  Future<void> _loadGeneralEvents() async {
    final generalEvents = await _generalDbHelper.queryAllGeneralEvents();
    setState(() {
      for (var event in generalEvents) {
        // 날짜 파싱 시 parseEventDate 함수 사용
        final startDate = parseEventDate(event['start_time']);
        if (startDate != null) {
          final eventDate = DateTime.utc(startDate.year, startDate.month, startDate.day);
          if (_events[eventDate] == null) {
            _events[eventDate] = [];
          }
          _events[eventDate]!.add(GeneralEvent(
            title: event['title'] ?? '',
            description: event['description'],
            location: event['location'],
            startTime: event['start_time'] ?? '',
            endTime: event['end_time'] ?? '',
            reminderTime: event['reminder_time'],
            createdAt: event['created_at'] ?? '',
          ));
        } else {
          print('Error parsing general event date: unable to parse ${event['start_time']}');
        }
      }
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final eventDate = DateTime.utc(day.year, day.month, day.day);
    return _events[eventDate] ?? [];
  }

  bool _isHoliday(DateTime day) {
    return _holidays.contains(DateTime(day.year, day.month, day.day));
  }

  Future<void> _showAddGeneralEventDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("일반 일정 추가"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: '제목')),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: '상세 설명')),
              TextField(controller: locationController, decoration: InputDecoration(labelText: '장소')),
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
                final newEvent = GeneralEvent(
                  title: titleController.text,
                  description: descriptionController.text,
                  location: locationController.text,
                  startTime: startDateController.text,
                  endTime: endDateController.text,
                  createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                );

                await _generalDbHelper.insertGeneralEvent(newEvent.toMap());
                await _loadGeneralEvents(); // 새로 추가된 일반 일정 로드
                Navigator.pop(context);
              },
              child: Text("추가"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddContestEventDialog() async {
    final titleController = TextEditingController();
    final organizerController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final applicationStartController = TextEditingController();
    final applicationEndController = TextEditingController();
    final contestStartController = TextEditingController();
    final contestEndController = TextEditingController();
    final applicationLinkController = TextEditingController();
    final contactController = TextEditingController();
    final categoryController = TextEditingController();
    final fieldController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("공모전 일정 추가"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: InputDecoration(labelText: '제목')),
                TextField(controller: organizerController, decoration: InputDecoration(labelText: '주최자')),
                TextField(controller: descriptionController, decoration: InputDecoration(labelText: '상세 설명')),
                TextField(controller: locationController, decoration: InputDecoration(labelText: '장소')),
                const SizedBox(height: 8),

                // 신청 시작 날짜
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: '신청 시작 날짜'),
                  controller: applicationStartController,
                  onTap: () async {
                    final date = await selectDate(context);
                    if (date != null) {
                      applicationStartController.text = DateFormat('yyyy-MM-dd').format(date);
                    }
                  },
                ),
                const SizedBox(height: 8),

                // 신청 종료 날짜
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: '신청 종료 날짜'),
                  controller: applicationEndController,
                  onTap: () async {
                    final date = await selectDate(context);
                    if (date != null) {
                      applicationEndController.text = DateFormat('yyyy-MM-dd').format(date);
                    }
                  },
                ),
                const SizedBox(height: 8),

                // 공모전 시작 날짜
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: '공모전 시작 날짜'),
                  controller: contestStartController,
                  onTap: () async {
                    final date = await selectDate(context);
                    if (date != null) {
                      contestStartController.text = DateFormat('yyyy-MM-dd').format(date);
                    }
                  },
                ),
                const SizedBox(height: 8),

                // 공모전 종료 날짜
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: '공모전 종료 날짜'),
                  controller: contestEndController,
                  onTap: () async {
                    final date = await selectDate(context);
                    if (date != null) {
                      contestEndController.text = DateFormat('yyyy-MM-dd').format(date);
                    }
                  },
                ),
                const SizedBox(height: 8),

                TextField(controller: applicationLinkController, decoration: InputDecoration(labelText: '신청 경로')),
                TextField(controller: contactController, decoration: InputDecoration(labelText: '지원 연락처')),
                TextField(controller: categoryController, decoration: InputDecoration(labelText: '카테고리')),
                TextField(controller: fieldController, decoration: InputDecoration(labelText: '활동 분야')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("취소")),
            TextButton(
              onPressed: () async {
                final newEvent = Event(
                  title: titleController.text,
                  organizer: organizerController.text,
                  description: descriptionController.text,
                  location: locationController.text,
                  applicationStartDate: applicationStartController.text,
                  applicationEndDate: applicationEndController.text,
                  contestStartDate: contestStartController.text,
                  contestEndDate: contestEndController.text,
                  applicationLink: applicationLinkController.text,
                  contact: contactController.text,
                  category: categoryController.text,
                  field: fieldController.text,
                );

                await _dbHelper.insertEvent(newEvent.toMap());
                await _loadEvents(); // 새로 추가된 공모전 일정 로드
                Navigator.pop(context);
              },
              child: Text("추가"),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('ko'), // 한국어로 설정
    );
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            // 날짜 선택기 호출
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _focusedDay,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              locale: const Locale('ko', 'KR'), // 한국어 설정
            );

            if (pickedDate != null) {
              setState(() {
                _focusedDay = pickedDate;
                _selectedDay = pickedDate;
                _selectedEvents.value = _getEventsForDay(pickedDate);
              });
            }
          },
          child: Text(
            '달력',  // "달력"으로 변경
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
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
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents.value = _getEventsForDay(selectedDay);
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,
              weekendTextStyle: TextStyle(color: Colors.red),
              holidayTextStyle: TextStyle(color: Colors.red), // 공휴일 텍스트 색상 설정
              holidayDecoration: BoxDecoration(), // 공휴일 데코레이션을 비워서 테두리 제거
              markersAlignment: Alignment.bottomCenter,
              markerDecoration: BoxDecoration(
                color: Colors.lightBlue, // 일정 추가 시 마커 색상 변경 (하늘색)
                shape: BoxShape.circle,
              ),
            ),
            holidayPredicate: _isHoliday, // 공휴일을 식별하는 함수 지정
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          ),
          Expanded(
            child: ValueListenableBuilder<List<dynamic>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return ListTile(
                      title: Text(event.title),
                      subtitle: event is Event
                          ? Text(event.organizer.isNotEmpty ? '주최자: ${event.organizer}' : '주최자 정보 없음')
                          : (event is GeneralEvent && event.description != null ? Text('설명: ${event.description}') : Text('설명 없음')),
                      onTap: () => _showEventDetails(event),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGeneralEventDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showEventDetails(dynamic event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event is Event) ...[
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
                ] else if (event is GeneralEvent) ...[
                  if (event.description != null && event.description!.isNotEmpty) _buildDetailRow('상세 설명', event.description!),
                  if (event.location != null && event.location!.isNotEmpty) _buildDetailRow('장소', event.location!),
                  _buildDetailRow('시작 날짜', event.startTime),
                  _buildDetailRow('종료 날짜', event.endTime),
                ],
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
}
