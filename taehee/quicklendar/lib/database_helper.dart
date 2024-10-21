import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contest_database.dart'; // contest_database.dart를 불러옵니다.
import '/models/contest.dart'; // Contest 클래스를 불러옵니다.
import 'package:intl/intl.dart'; // 날짜 파싱을 위한 intl 패키지 추가

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'events.db');
    return openDatabase(
      path,
      version: 3, // 버전 업그레이드
      onCreate: (db, version) {
        return db.execute(
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
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 3) {
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
        }
      },
    );
  }

  // 이벤트 삽입
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    int result = await db.insert('events', event); // 이벤트 삽입
    await transferEventsToContestDatabase(); // 이벤트 삽입 후 데이터 전송
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
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // 특정 이벤트 수정
  Future<int> updateEvent(int id, String title, String description, String organizer, String location,
      String applicationStartDate, String applicationEndDate, String contestStartDate,
      String contestEndDate, String applicationLink, String contact, String category, String field) async {
    final db = await database;
    return await db.update(
      'events',
      {
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
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<void> transferEventsToContestDatabase() async {
    final contestDB = ContestDatabase.instance; // contest_database 객체 생성
    final List<Map<String, dynamic>> events = await queryAllEvents(); // 모든 이벤트 가져오기

    // 여러 가지 날짜 형식을 처리하기 위한 DateFormat
    final DateFormat dateFormatWithDay = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR'); // 요일이 포함된 형식
    final DateFormat dateFormatWithoutDay = DateFormat('yyyy년 MM월 dd일'); // 요일이 없는 형식
    final DateFormat alternateDateFormat = DateFormat('yyyy.MM.dd'); // 다른 형식

    for (var event in events) {
      try {
        // 날짜 파싱 시 여러 형식을 시도
        DateTime applicationStart;
        DateTime applicationEnd;
        DateTime contestStart;
        DateTime contestEnd;

        try {
          applicationStart = dateFormatWithDay.parse(event['application_start_date']);
          applicationEnd = dateFormatWithDay.parse(event['application_end_date']);
          contestStart = dateFormatWithDay.parse(event['contest_start_date']);
          contestEnd = dateFormatWithDay.parse(event['contest_end_date']);
        } catch (e) {
          try {
            applicationStart = dateFormatWithoutDay.parse(event['application_start_date']);
            applicationEnd = dateFormatWithoutDay.parse(event['application_end_date']);
            contestStart = dateFormatWithoutDay.parse(event['contest_start_date']);
            contestEnd = dateFormatWithoutDay.parse(event['contest_end_date']);
          } catch (e) {
            applicationStart = alternateDateFormat.parse(event['application_start_date']);
            applicationEnd = alternateDateFormat.parse(event['application_end_date']);
            contestStart = alternateDateFormat.parse(event['contest_start_date']);
            contestEnd = alternateDateFormat.parse(event['contest_end_date']);
          }
        }

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
