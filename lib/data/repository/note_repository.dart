import '../../model/note.dart';
import '../dao/note_dao.dart';

class NoteRepository {
  final NoteDao _noteDao = NoteDao();

  Future<int> addNote(Note note) async {
    try {
      return await _noteDao.insert(note);
    } catch (e) {
      throw Exception('Impossible d\'ajouter la note');
    }
  }

  Future<List<Note>> getAllNotes(
    String userId, {
    bool includeArchived = false,
  }) async {
    try {
      return await _noteDao.getAllForUser(
        userId,
        includeArchived: includeArchived,
      );
    } catch (e) {
      throw Exception('Impossible de récupérer les notes');
    }
  }

  Future<List<Note>> getArchivedNotes(String userId) async {
    try {
      return await _noteDao
          .getAllForUser(userId, includeArchived: true)
          .then((notes) => notes.where((note) => note.isArchived).toList());
    } catch (e) {
      throw Exception('Impossible de récupérer les notes archivées');
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _noteDao.update(note);
    } catch (e) {
      throw Exception('Impossible de mettre à jour la note');
    }
  }

  // pour la pagination
  Future<List<Note>> getPaginatedNotes(
    String userId,
    int page,
    int notesPerPage, {
    bool includeArchived = false,
  }) async {
    try {
      return await _noteDao.getPaginatedForUser(
        userId,
        page,
        notesPerPage,
        includeArchived: includeArchived,
      );
    } catch (e) {
      throw Exception(
        'Impossible de récupérer les notes paginées: ${e.toString()}',
      );
    }
  }

  // Compter les notes pour un utilisateur spécifique
  Future<int> getNoteCountForUser(String userId) async {
    try {
      return await _noteDao.countNotesForUser(userId);
    } catch (e) {
      print('Erreur dans NoteRepository.getNoteCountForUser : $e');
      rethrow;
    }
  }

  //delete
  Future<int> deleteNote(int id) async {
    if (id == null || id <= 0) {
      throw Exception("ID de note invalide");
    }
    return await _noteDao.delete(id);
  }
}
