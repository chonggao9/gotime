import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/habit.dart';
import '../../models/check_in.dart';
import '../../models/user.dart';

class SQLiteService {
  // 单例模式，确保全局只有一个数据库实例
  static final SQLiteService instance = SQLiteService._init();
  static Database? _database;

  SQLiteService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gotime_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // 打开数据库，并指定 onCreate 回调用于首次建表
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // 核心建表逻辑 (严格对照 PRD 的 Data Schema)
  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNull = 'TEXT';
    const boolType = 'INTEGER NOT NULL';
    const integerType = 'INTEGER';
    const intNull = 'INTEGER';

    // 1. 创建 User 表
    await db.execute('''
CREATE TABLE users (
  uid $idType,
  display_name $textType,
  avatar_url $textNull,
  momentum_score $boolType,
  anchor_timezone $textNull,
  created_at $textType
)
''');

    // 2. 创建 Habits 表
    await db.execute('''
CREATE TABLE habits (
  id $idType,
  name $textType,
  icon_emoji $textType,
  theme_color $textType,
  type $textType,
  target_value $intNull,
  target_unit $textNull,
  timer_seconds $intNull,
  frequency $textType, 
  reminders $textType,
  is_shared $boolType,
  is_archived $boolType,
  updated_at $textType
)
''');

    // 3. 创建 CheckIns (打卡记录) 表
    await db.execute('''
CREATE TABLE check_ins (
  id $idType,
  habit_id $textType,
  date $textType,
  status $textType,
  value $intNull,
  duration_seconds $intNull,
  log_text $textNull,
  mood $intNull,
  is_suspicious $boolType,
  created_at $textType,
  FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
)
''');
  }

  // ==========================================
  // Habits (习惯) 的 CRUD 操作
  // ==========================================

  Future<void> insertHabit(Habit habit) async {
    final db = await instance.database;
    final map = habit.toJson();
    // SQLite 不支持 Map/List，需要转成 JSON 字符串
    map['frequency'] = jsonEncode(map['frequency']);
    map['reminders'] = jsonEncode(map['reminders']);
    
    // 使用 replace 防止主键冲突时报错
    await db.insert('habits', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Habit>> getAllActiveHabits() async {
    final db = await instance.database;
    final result = await db.query(
      'habits',
      where: 'is_archived = ?',
      whereArgs: [0], // 0 代表 false
      orderBy: 'updated_at DESC',
    );

    return result.map((json) {
      final map = Map<String, dynamic>.from(json);
      // 还原 JSON 字符串为对象
      map['frequency'] = jsonDecode(map['frequency'] as String);
      map['reminders'] = jsonDecode(map['reminders'] as String);
      // SQLite 中 Boolean 存为 Integer (0 或 1)
      map['is_shared'] = map['is_shared'] == 1;
      map['is_archived'] = map['is_archived'] == 1;
      return Habit.fromJson(map);
    }).toList();
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await instance.database;
    final map = habit.toJson();
    map['frequency'] = jsonEncode(map['frequency']);
    map['reminders'] = jsonEncode(map['reminders']);
    
    return db.update(
      'habits',
      map,
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(String id) async {
    final db = await instance.database;
    // 由于设置了 ON DELETE CASCADE，这里删除 habit 时会自动删除底下的 check_ins
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // CheckIns (打卡记录) 的 CRUD 操作
  // ==========================================

  Future<void> insertCheckIn(CheckIn checkIn) async {
    final db = await instance.database;
    final map = checkIn.toJson();
    await db.insert('check_ins', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 供【年度热力图】查询一整年的打卡记录
  Future<List<CheckIn>> getCheckInsForYear(int year) async {
    final db = await instance.database;
    final result = await db.query(
      'check_ins',
      where: 'date LIKE ?',
      whereArgs: ['$year-%'], // 匹配 2024-xxx
    );
    
    return result.map((json) {
      final map = Map<String, dynamic>.from(json);
      map['is_suspicious'] = map['is_suspicious'] == 1;
      return CheckIn.fromJson(map);
    }).toList();
  }

  // 供【今天主页】查询某天的打卡状态
  Future<List<CheckIn>> getCheckInsForDate(String dateString) async {
    final db = await instance.database;
    final result = await db.query(
      'check_ins',
      where: 'date = ?',
      whereArgs: [dateString],
    );
    
    return result.map((json) {
      final map = Map<String, dynamic>.from(json);
      map['is_suspicious'] = map['is_suspicious'] == 1;
      return CheckIn.fromJson(map);
    }).toList();
  }

  // ==========================================
  // 关闭数据库
  // ==========================================
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
