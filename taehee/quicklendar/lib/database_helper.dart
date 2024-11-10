import 'package:quicklendar/screens/calendar_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contest_database.dart'; // contest_database.dart를 불러옵니다.
import '/models/contest.dart'; // Contest 클래스를 불러옵니다.
import 'package:intl/intl.dart'; // 날짜 파싱을 위한 intl 패키지 추가
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'events.db');
    return openDatabase(
      path,
      version: 4, // 버전 업그레이드
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE events(
            id INTEGER PRIMARY KEY,
            title TEXT,
            organizer TEXT,
            description TEXT,
            location TEXT,
            application_start_date TEXT,
            application_end_date TEXT,
            contest_start_date TEXT,
            contest_end_date TEXT,
            application_link TEXT,
            contact TEXT,
            category TEXT,
            field TEXT,
            imageUrl TEXT  -- 이미지 경로를 저장할 필드 추가
          )
          ''',
        );
        // notifications 테이블 생성
        await db.execute(
          '''
        CREATE TABLE notifications(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          body TEXT,
          timestamp TEXT
        )
        ''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          db.execute('ALTER TABLE events ADD COLUMN organizer TEXT');
          db.execute('ALTER TABLE events ADD COLUMN description TEXT');
          db.execute('ALTER TABLE events ADD COLUMN location TEXT');
          db.execute('ALTER TABLE events ADD COLUMN application_start_date TEXT');
          db.execute('ALTER TABLE events ADD COLUMN application_end_date TEXT');
          db.execute('ALTER TABLE events ADD COLUMN contest_start_date TEXT');
          db.execute('ALTER TABLE events ADD COLUMN contest_end_date TEXT');
          db.execute('ALTER TABLE events ADD COLUMN application_link TEXT');
          db.execute('ALTER TABLE events ADD COLUMN contact TEXT');
          db.execute('ALTER TABLE events ADD COLUMN category TEXT');
          db.execute('ALTER TABLE events ADD COLUMN field TEXT');
          db.execute('ALTER TABLE events ADD COLUMN imageUrl TEXT');
          await db.execute(
            '''
          CREATE TABLE IF NOT EXISTS notifications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            body TEXT,
            timestamp TEXT
          )
          ''',
          );
        }
      },
    );
  }

  // 알림 초기화
  Future<void> initializeNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 알림 예약 함수
  Future<void> scheduleNotification(Event event) async {
    final DateFormat dateFormat = DateFormat('yyyy년 MM월 dd일', 'ko_KR');

    try {
      final contestStartDate = dateFormat.parse(event.contestStartDate);
      final notificationTimes = {
        'D-30': contestStartDate.subtract(const Duration(days: 30)),
        'D-7': contestStartDate.subtract(const Duration(days: 7)),
        'D-1': contestStartDate.subtract(const Duration(days: 1)),
        'D-day': contestStartDate,
      };

      for (final entry in notificationTimes.entries) {
        print('${entry.key} 알림이 ${entry.value}에 예약되었습니다.'); // 예약된 시간 확인

        await flutterLocalNotificationsPlugin.zonedSchedule(
          entry.key.hashCode, // 고유 ID로 날짜 코드 사용
          '${entry.key}: ${event.title}',
          '공모전 "${event.title}"의 마감이 다가왔습니다!',
          tz.TZDateTime.from(entry.value, tz.local), // 시간대와 예약 시간 설정
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'contest_reminder_channel',
              'Contest Reminders',
              channelDescription: '알림 채널',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      }
    } catch (e) {
      print('알림 예약 오류: $e');
    }
  }

  // 이벤트 삽입
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    int result = await db.insert('events', event); // 이벤트 삽입
    await transferEventsToContestDatabase(); // 이벤트 삽입 후 데이터 전송

    final newEvent = Event(
      title: event['title'] ?? '',
      contestStartDate: event['contest_start_date'] ?? '',
      // 필요한 필드 추가
    );
    await scheduleNotification(newEvent); // 알림 예약

    return result;
  }

  // 모든 이벤트 조회
  Future<List<Map<String, dynamic>>> queryAllEvents() async {
    final db = await database;
    return await db.query('events');
  }

  // 특정 이벤트 삭제
  Future<int> deleteEvent(int id) async {
    final db = await database;
    await flutterLocalNotificationsPlugin.cancel(id); // 해당 이벤트 알림 취소
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // 특정 이벤트 수정
  Future<int> updateEvent(int id, Map<String, dynamic> event) async {
    final db = await database;
    final result = await db.update('events', event, where: 'id = ?', whereArgs: [id]);

    final updatedEvent = Event(
      title: event['title'] ?? '',
      contestStartDate: event['contest_start_date'] ?? '',
      // 필요한 필드 추가
    );
    await scheduleNotification(updatedEvent); // 알림 예약

    return result;
  }

  // 알림 내역 저장
  Future<void> saveNotification(String title, String body) async {
    final db = await database;
    await db.insert('notifications', {
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toString(),
    });
  }

  // 알림 내역 조회
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query('notifications', orderBy: 'timestamp DESC');
  }

  Future<void> transferEventsToContestDatabase() async {
    final contestDB = ContestDatabase.instance; // contest_database 객체 생성
    final List<Map<String, dynamic>> events = await queryAllEvents(); // 모든 이벤트 가져오기

    // 여러 가지 날짜 형식을 처리하기 위한 DateFormat
    final List<DateFormat> dateFormats = [
      DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR'), // 요일 포함 형식
      DateFormat('yyyy년 MM월 dd일'), // 요일 없는 형식
      DateFormat('yyyy.MM.dd'), // 점(.) 구분 형식
      DateFormat('yyyy.MM.dd.'), // 점(.) 구분 형식 +일자에 점하나 더
      DateFormat('yyyy-MM-dd'), // 대시(-) 구분 형식
    ];

    // 날짜 파싱 함수: 여러 형식을 시도
    DateTime parseDate(String dateStr) {
      for (var format in dateFormats) {
        try {
          return format.parse(dateStr);
        } catch (e) {
          continue; // 다음 형식으로 시도
        }
      }
      throw FormatException('지원하지 않는 날짜 형식: $dateStr'); // 모든 형식이 실패할 경우
    }

    for (var event in events) {
      try {
        // 각 날짜 필드를 독립적으로 파싱
        DateTime applicationStart = parseDate(event['application_start_date']);
        DateTime applicationEnd = parseDate(event['application_end_date']);
        DateTime contestStart = parseDate(event['contest_start_date']);
        DateTime contestEnd = parseDate(event['contest_end_date']);

        // 공모전 객체 생성 및 저장
        Contest contest = Contest(
          imageUrl: event['imageUrl'] ?? '', // 이미지 URL을 포함하여 저장
          title: event['title'],
          organizer: event['organizer'],
          description: event['description'],
          location: event['location'],
          applicationStart: applicationStart,
          applicationEnd: applicationEnd,
          startDate: contestStart,
          endDate: contestEnd,
          applicationLink: event['application_link'],
          contact: event['contact'],
          category: event['category'],
          activityType: event['field'],
          views: 0,
        );

        await contestDB.create(contest);

        // 저장된 데이터를 다시 읽어와 확인
        final allContests = await contestDB.readAllContests();
        print('All contests after inserting: $allContests');
        print('New contest created: ${contest.title}');
      } catch (e) {
        print('Error parsing event: ${event['title']} - $e');
      }
    }
  }
}
