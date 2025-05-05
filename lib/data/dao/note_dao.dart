import 'package:notepad/data/database/notepadd_database.dart';

import '../../model/note.dart';
import '../database/exception.dart';

class NoteDao {
  final tableName = 'notes';

  //inserer une note
  Future<int> insert(Note note) async {
    final db = await NoteDatabase.instance.database;

    try {
      final id = await db.insert(tableName, note.toMap());
      if (id == 0) {
        throw DatabaseException('Erreur lors de l\'insertion de la note');
      }
      return id;
    } catch (e) {
      print('Erreur lors de l\'insertion: $e');
      rethrow;
    }
  }

  // Dans NoteDao
  Future<List<Note>> getAllForUser(
    String userId, {
    bool includeArchived = false,
  }) async {
    final db = await NoteDatabase.instance.database;
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (!includeArchived) {
      whereClause +=
          ' AND is_archived = 0'; // Charger uniquement les notes non archivées
    } else {
      whereClause +=
          ' AND is_archived = 1'; // Charger uniquement les notes archivées
    }

    final result = await db.query(
      'notes',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  //mettre a jour
  Future<void> update(Note note) async {
    final db = await NoteDatabase.instance.database;
    try {
      final rowsAffected = await db.update(
        tableName,
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      if (rowsAffected == 0) {
        throw DatabaseException('Aucune note mise à jour');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour: $e');
      rethrow;
    }
  }

  // pour la pagination
  Future<List<Note>> getPaginatedForUser(
    String userId,
    int page,
    int notesPerPage, {
    bool includeArchived = false,
  }) async {
    final db = await NoteDatabase.instance.database;
    final offset = page * notesPerPage;

    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (!includeArchived) {
      whereClause += ' AND is_archived = 0';
    } else {
      whereClause += ' AND is_archived = 1';
    }

    final result = await db.query(
      'notes',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: notesPerPage,
      offset: offset,
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  //Archive
  Future<List<Note>> getArchivedForUser(String userId) async {
    final db = await NoteDatabase.instance.database;

    final result = await db.query(
      tableName,
      where: 'user_id = ? AND is_Archived = 1',
      whereArgs: [userId],
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  //compter par user
  Future<int> countNotesForUser(String userId) async {
    final db = await NoteDatabase.instance.database;
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(id) AS note_count FROM notes WHERE user_id = ?',
        [userId],
      );
      return result.isNotEmpty ? result.first['note_count'] as int : 0;
    } catch (e) {
      throw DatabaseException('Erreur lors du comptage des notes : $e');
    }
  }

  //delete
  Future<int> delete(int id) async {
    final db = await NoteDatabase.instance.database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
