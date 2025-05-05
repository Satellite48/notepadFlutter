import 'package:notepad/data/database/notepadd_database.dart';
import 'package:sqflite/sqflite.dart';
import '../../model/category.dart';

class CategoryDao {
  final tableName = 'categories';//de la table

  //inserer une categorie
  Future<int> insert(Category category) async {
    final db = await NoteDatabase.instance.database;//recuperrer la db
    try {
      final normalizedName = category.name.toLowerCase().trim();
      return await db.insert(
        tableName,
        {
          'name': normalizedName,
          'user_id': category.userId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      print('Erreur d\'insertion de catégorie: $e');
      return -1;
    }
  }

  //recuperer les categorie
  Future<List<Category>> getAllForUser(String userId) async {
    final db = await NoteDatabase.instance.database;
    final result = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((map) => Category.fromMap(map)).toList();
  }

  // verifier si une Category existe
  Future<bool> categoryExists(String name, int userId) async {
    final db = await NoteDatabase.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'LOWER(name) = ? AND user_id = ?',
      whereArgs: [name.toLowerCase().trim(), userId],
    );
    return result.isNotEmpty;
  }

  Future<String?> getCategoryName(int categoryId) async {
    final db = await NoteDatabase.instance.database;

    final maps = await db.query(
      'categories',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [categoryId],
    );
    if (maps.isNotEmpty) {
      return maps.first['name'] as String?;
    }
    return null;
  }
}
