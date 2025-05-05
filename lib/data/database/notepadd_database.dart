import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NoteDatabase {
  //instance unique de la base de donnée
  static final NoteDatabase instance = NoteDatabase._init();
  static Database? _database; //db

  NoteDatabase._init();
  //creation de la db
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notepadd.db');
    return _database!;
  }

  //initialise la db
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //creation des tables
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE users(
        id $idType,
        lastname $textType,
        firstname $textType,
        email $textType,
        password  $textType,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
    CREATE TABLE  categories(
      id $idType,
      name $textType,
      user_id $textType,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(name, user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notes(
        id $idType,
        title $textType,
        content $textType,
        priority $textType,
        category_id INTEGER NOT NULL,
        created_at $textType,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        is_archived INTEGER NOT NULL DEFAULT 0,
        user_id $textType,
        FOREIGN KEY (category_id) REFERENCES categories(id)
        )
      ''');
  }

  //ferme la db
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
