import 'package:daily_planner/model/task_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/user_model.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _databaseService = DatabaseHelper._internal();

  factory DatabaseHelper() => _databaseService;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the DB first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, 'db_daily_planner.db');
    print(
        "Đường dẫn database: $databasePath"); // in đường dẫn chứa file database
    return await openDatabase(path, onCreate: _onCreate, version: 1

    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng Task
    await db.execute('''
        CREATE TABLE Task (
          idTask INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          content TEXT,
          time TEXT,
          place TEXT,
          preside TEXT,
          note TEXT,
          complete INTEGER
        )
      ''');

    // Tạo bảng User
    await db.execute('''
        CREATE TABLE User (
          idUser INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT,
          email TEXT,
          pass TEXT
        )
      ''');
  }

  Future<void> insertTask(Task task) async {
    final db = await _databaseService.database;
    await db.insert(
      'Task',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(int idTask, Task newTaskValues) async {
    final db = await _databaseService.database;
    await db.update(
      'Task',
      newTaskValues.toMap(),
      where: 'idTask = ?',
      whereArgs: [idTask],
    );
  }

  Future<void> deleteTask(int idTask) async {
    final db = await _databaseService.database;
    await db.delete(
      'Task',
      where: 'idTask = ?',
      whereArgs: [idTask],
    );
  }

  Future<List<Task>> getAllTasks() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('Task');

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<List<Task>> getIncompleteTasks() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('Task', where: 'complete = ?', whereArgs: [0]);

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<List<Task>> getCompleteTasks() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('Task', where: 'complete = ?', whereArgs: [1]);

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<List<User>> getAllUsers() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('User');

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<List<User>> getUserByUsername(String username) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('User', where: 'username = ?', whereArgs: [username]);

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await _databaseService.database;
    // Chuyển đổi DateTime thành chuỗi với định dạng 'YYYY-MM-DD'
    String formattedDate = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // Truy vấn cơ sở dữ liệu để tìm các Task có date khớp với formattedDate
    final List<Map<String, dynamic>> maps = await db.query(
      'Task',
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    // Trả về danh sách các đối tượng Task
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }
}