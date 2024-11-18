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
      version: 2, // 버전을 2로 업데이트
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE contests ADD COLUMN imageFile TEXT');
        }
      },
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
      imageFile $textType,
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
  Future<Contest?> create(Contest contest) async {
    final db = await instance.database;

    print('Saving contest imageFile path: ${contest.imageFile}');

    // 제목으로 중복 검사
    final List<Map<String, dynamic>> existingContest = await db.query(
      'contests',
      where: 'title = ?',
      whereArgs: [contest.title],
    );

    // 중복된 공모전이 있을 경우, 저장하지 않고 null 반환
    if (existingContest.isNotEmpty) {
      print('이미 존재하는 공모전: ${contest.title}');
      return null;
    }

    // 중복되지 않는 경우에만 저장
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

  // 공모전 삭제 함수 추가
  Future<int> deleteContest(int id) async {
    final db = await instance.database;
    return await db.delete(
      'contests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 공모전 업데이트 함수 추가
  Future<int> update(Contest contest) async {
    final db = await instance.database;

    // 업데이트하려는 공모전의 id가 null인 경우 예외 처리
    if (contest.id == null) {
      throw Exception("Update failed: Contest id is null");
    }

    // 업데이트 수행
    return await db.update(
      'contests',
      contest.toMap(),
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

  Future<Contest?> readContestById(int id) async {
    final db = await instance.database;
    final maps = await db.query('contests', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Contest.fromMap(maps.first);
    }
    return null;
  }


  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
