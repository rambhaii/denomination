import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('denominations.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saves (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remark TEXT,
        total INTEGER,
        created_at TEXT,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        save_id INTEGER,
        amount INTEGER,
        multiplier INTEGER,
        result INTEGER,
        FOREIGN KEY (save_id) REFERENCES saves (id)
      )
    ''');
  }

  Future<int> insertSave(Map<String, dynamic> save) async {
    final db = await instance.database;
    return await db.insert('saves', save);
  }

  Future<int> insertDetail(Map<String, dynamic> detail) async {
    final db = await instance.database;
    return await db.insert('details', detail);
  }

  Future<List<Map<String, dynamic>>> fetchSaves() async {
    final db = await instance.database;
    return await db.query('saves');
  }

  Future<List<Map<String, dynamic>>> fetchDetails(int saveId) async {
    final db = await instance.database;
    return await db.query('details', where: 'save_id = ?', whereArgs: [saveId]);
  }

  Future<void> updateSave(int id, Map<String, dynamic> save) async {
    final db = await instance.database;
    await db.update('saves', save, where: 'id = ?', whereArgs: [id]);
  }

 Future<void> updateDetail(int id, Map<String, dynamic> detail) async {
  final db = await instance.database;

  await db.update(
    'details',
    detail,
    where: 'id = ?', // Target the correct row using the ID
    whereArgs: [id],
  );
}
   Future<void> deleteSave(int id) async {
    final db = await instance.database;
    // First delete the details associated with the save
    await db.delete('details', where: 'save_id = ?', whereArgs: [id]);
    
    // Now delete the save
    await db.delete('saves', where: 'id = ?', whereArgs: [id]);
  }

}
