import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StudentDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'students.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            studentId TEXT,
            name TEXT,
            course TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertStudent(
    String studentId,
    String name,
    String course,
  ) async {
    try {
      final db = await database;

      int result = await db.insert(
        'students',
        {
          'studentId': studentId,
          'name': name,
          'course': course,
        },
      );

      print("INSERT SUCCESS → Row ID: $result");
    } catch (e) {
      print("INSERT ERROR: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final db = await database;
      return await db.query('students');
    } catch (e) {
      print("FETCH ERROR: $e");
      return [];
    }
  }

  static Future<void> deleteStudent(int id) async {
    try {
      final db = await database;

      await db.delete(
        'students',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("DELETE ERROR: $e");
    }
  }

  static Future<void> updateStudent(
    int id,
    String studentId,
    String name,
    String course,
  ) async {
    try {
      final db = await database;

      await db.update(
        'students',
        {
          'studentId': studentId,
          'name': name,
          'course': course,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("UPDATE ERROR: $e");
    }
  }
}