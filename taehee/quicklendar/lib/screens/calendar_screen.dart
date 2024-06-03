import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database_helper.dart';

class Event {
  final String title;
  final String description;

  Event(this.title, this.description);
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
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
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
    _titleController.dispose();
    _descriptionController.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _loadEventsForDay(selectedDay);
      });
    }
  }

  Future<void> _loadEvents() async {
    final events = await _dbHelper.queryAllEvents();
    setState(() {
      _events.clear();
      for (var event in events) {
        final date = DateTime.parse(event['date']);
        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add(Event(event['title'], event['description']));
      }
    });
    print("Events loaded: $_events");  // 로그 출력
  }

  Future<void> _loadEventsForDay(DateTime day) async {
    final events = await _dbHelper.queryAllEvents();
    setState(() {
      _selectedEvents.value = events
          .where((event) => isSameDay(DateTime.parse(event['date']), day))
          .map((event) => Event(event['title'], event['description']))
          .toList();
    });
    print("Events for day $day loaded: ${_selectedEvents.value}");  // 로그 출력
  }

  Future<void> _addEvent() async {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      final event = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': _selectedDay!.toIso8601String(),
      };
      await _dbHelper.insertEvent(event);
      _titleController.clear();
      _descriptionController.clear();
      await _loadEvents();
      await _loadEventsForDay(_selectedDay!);
      setState(() {});
      print("Event added successfully");  // 로그 출력
    } else {
      print("Title or Description is empty");  // 로그 출력
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('달력'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: const Text("이벤트 추가"),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(hintText: "이벤트 제목"),
                      ),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(hintText: "이벤트 내용"),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      print("Add button pressed");  // 로그 출력
                      await _addEvent();
                      Navigator.of(context).pop();
                    },
                    child: const Text("추가"),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(
          Icons.add,
          color: Colors.white,
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
            startingDayOfWeek: StartingDayOfWeek.sunday,
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: true,
              weekendTextStyle: TextStyle(color: Colors.red), // 주말 텍스트 스타일
              defaultTextStyle: TextStyle(color: Colors.black), // 기본 텍스트 스타일
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red), // 주말 요일 스타일
              weekdayStyle: TextStyle(color: Colors.black), // 기본 요일 스타일
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
                    return ListTile(
                      title: Text(value[index].title),
                      subtitle: Text(value[index].description),
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
