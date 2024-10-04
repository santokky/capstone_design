import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contest.dart';

class ContestDatabase {
  static final ContestDatabase instance = ContestDatabase._init();
  static Database? _database;

  ContestDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contest.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const dateType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE contests (
      id $idType,
      imageUrl $textType,
      title $textType,
      organizer $textType,
      description $textType,
      location $textType,
      applicationStart $dateType,
      applicationEnd $dateType,
      startDate $dateType,
      endDate $dateType,
      applicationLink $textType,
      contact $textType,
      views $intType, -- 조회수 필드
      category $textType,
      activityType $textType
    )
    ''');
  }

  // 새로운 공모전 생성
  Future<Contest> create(Contest contest) async {
    final db = await instance.database;
    final id = await db.insert('contests', contest.toMap());
    return contest.copyWith(id: id);
  }

  Future<List<String>> getAllOrganizers() async {
    final db = await instance.database;
    // 주최자 목록 가져오기 (중복 제거)
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT organizer FROM contests'
    );
    return List<String>.from(maps.map((map) => map['organizer'] as String));
  }

  // 주최자 목록을 가져오는 함수
  Future<List<String>> readAllOrganizers() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT DISTINCT organizer FROM contests');
    return result.map((row) => row['organizer'] as String).toList();
  }

  Future<List<String>> readOrganizersByCategory(String category) async {
    final db = await instance.database;

    // 해당 카테고리의 공모전 또는 대외활동 주최자를 중복 없이 가져오는 쿼리
    final result = await db.rawQuery(
      'SELECT DISTINCT organizer FROM contests WHERE activityType = ?',
      [category],
    );

    // 결과를 문자열 목록으로 변환
    List<String> organizers = result.map((row) => row['organizer'] as String).toList();

    // 디버그용 출력
    print('Organizers for category $category: $organizers');

    return organizers;
  }

  // 조회수 업데이트 함수
  Future<void> updateViews(Contest contest) async {
    final db = await instance.database;
    await db.update(
      'contests',
      {'views': contest.views},
      where: 'id = ?',
      whereArgs: [contest.id],
    );
  }

  // 전체 공모전 읽기
  Future<List<Contest>> readAllContests() async {
    final db = await instance.database;
    const orderBy = 'views DESC';
    final result = await db.query('contests', orderBy: orderBy);
    return result.map((json) => Contest.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
