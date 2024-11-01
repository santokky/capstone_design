import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class GeneralEventDatabaseHelper {
  static final GeneralEventDatabaseHelper _instance = GeneralEventDatabaseHelper._internal();
  factory GeneralEventDatabaseHelper() => _instance;
  static Database? _database;

  GeneralEventDatabaseHelper._internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'general_events.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE general_events(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            location TEXT,
            start_time TEXT,
            end_time TEXT,
            reminder_time TEXT,
            created_at TEXT DEFAULT (datetime('now'))
          )
          ''',
        );
      },
    );
  }

  // 일반 일정 삽입 메서드
  Future<int> insertGeneralEvent(Map<String, dynamic> event) async {
    final db = await database;
    int newEventId = await db.insert('general_events', event);

    // 알림 예약 호출 (start_time 기준)
    if (event['start_time'] != null && event['start_time'].isNotEmpty) {
      DateTime startTime = DateTime.parse(event['start_time']);
      await scheduleNotification(newEventId, event['title'], startTime);
    }

    return newEventId;
  }

  // 일정 알림 예약 메서드
  Future<void> scheduleNotification(int id, String title, DateTime startTime) async {
    final notificationTimes = {
      'D-30': startTime.subtract(const Duration(days: 30)),
      'D-7': startTime.subtract(const Duration(days: 7)),
      'D-1': startTime.subtract(const Duration(days: 1)),
      'D-day': startTime,
    };

    for (final entry in notificationTimes.entries) {
      print('${entry.key} 알림이 ${entry.value}에 예약되었습니다.'); // 예약된 시간 확인

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id + entry.key.hashCode, // 고유 ID를 위해 ID와 해시코드 조합
        '${entry.key}: $title',
        '일정 "$title"이 곧 시작됩니다!',
        tz.TZDateTime.from(entry.value, tz.local), // 시간대와 예약 시간 설정
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'general_event_channel',
            'General Event Notifications',
            channelDescription: '일반 일정 알림',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  // 모든 일반 일정 조회 메서드
  Future<List<Map<String, dynamic>>> queryAllGeneralEvents() async {
    final db = await database;
    return await db.query('general_events');
  }

  // 특정 ID로 일반 일정 조회 메서드 추가
  Future<Map<String, dynamic>?> queryGeneralEventById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('general_events', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // 특정 일반 일정 삭제 메서드
  Future<int> deleteGeneralEvent(int id) async {
    final db = await database;
    return await db.delete('general_events', where: 'id = ?', whereArgs: [id]);
  }

  // 특정 일반 일정 수정 메서드
  Future<int> updateGeneralEvent(int id, Map<String, dynamic> event) async {
    final db = await database;
    return await db.update('general_events', event, where: 'id = ?', whereArgs: [id]);
  }

  // 알림 초기화
  Future<void> initializeNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}
