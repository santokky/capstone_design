import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 2, // 버전 업그레이드
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
            field TEXT
          )
          ''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
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
        }
      },
    );
  }

  // 이벤트 삽입
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('events', event);
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
}
