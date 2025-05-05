import 'package:notepad/data/database/notepadd_database.dart';
import 'package:notepad/model/user.dart';

import '../database/exception.dart';

class UserDao {
  final NoteDatabase _databaseHelper = NoteDatabase.instance;
  final tableName = 'users';

  //inserer
  Future<int> insertUser(User user) async {
    final db = await _databaseHelper.database;
    try {
      final id = await db.insert(tableName, user.toMap());
      if (id == 0) {
        throw DatabaseException(
          'Erreur lors de l\'insertion de l\'utilisateur',
        );
      }
      return id;
    } catch (e) {
      print('Erreur lors de l\'insertion: $e');
      rethrow;
    }
  }

  // Vérifier si un email existe déjà
  Future<bool> emailExists(String email) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      tableName,
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  //login
  Future<User?> checkLogin(String email, String password) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
        tableName,
        where: 'email = ? AND password = ?',
        whereArgs: [email,password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}

