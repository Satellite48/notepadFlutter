import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/repository/category_repository.dart';
import '../data/repository/note_repository.dart';
import '../model/note.dart';
import '../service/auth_service.dart';
import 'note_card.dart';
import 'note_detail_page.dart';

class ArchivedNotesPage extends StatefulWidget {
  const ArchivedNotesPage({super.key});

  @override
  State<ArchivedNotesPage> createState() => _ArchivedNotesPageState();
}

class _ArchivedNotesPageState extends State<ArchivedNotesPage> {
  final NoteRepository _noteRepository = NoteRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final AuthService _authService = AuthService();
  List<Note> _notes = [];
  Map<int, String> _categoryNames = {};

  @override
  void initState() {
    super.initState();
    _loadArchivedNotes();
  }

  Future<void> _loadArchivedNotes() async {
    final userId = await _authService.getCurrentUserId();
    print('Chargement des notes archivées pour userId: $userId');
    if (userId != null) {
      final notes = await _noteRepository.getArchivedNotes(userId.toString());
      final categories = await _categoryRepository.getAllCategories(userId.toString());
      setState(() {
        _notes = notes..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _categoryNames = {for (var cat in categories) cat.id!: cat.name};
      });
      print('Notes archivées chargées: ${notes.length}');
    } else {
      print('Erreur: Aucun utilisateur connecté');
    }
  }

  Future<void> _unarchiveNote(Note note) async {
    try {
      final updatedNote = Note(
        id: note.id,
        title: note.title,
        content: note.content,
        categoryId: note.categoryId,
        priority: note.priority,
        userId: note.userId,
        createdAt: note.createdAt,
        isFavorite: note.isFavorite,
        isArchived: false, // Désarchiver la note
      );
      await _noteRepository.updateNote(updatedNote);
      Navigator.pop(context, true);
      Navigator.pushReplacementNamed(context, '/home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note désarchivée'),
          backgroundColor: Colors.blueAccent,
        ),
      );
      await _loadArchivedNotes();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du désarchivage: $e')),
      );
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (note.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID de note manquant')),
      );
      return;
    }

    try {
      final result = await _noteRepository.deleteNote(note.id!);
      if (result > 0) {
        await _loadArchivedNotes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note supprimée avec succès'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune note trouvée avec cet ID')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  int _mapPriorityToType(String priority) {
    switch (priority) {
      case 'Important':
        return 1;
      case 'Urgent':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //appBar
      appBar: AppBar(
        title: const Text(
          'Notes Archivées',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      //body
      body: _notes.isEmpty
          ? const Center(child: Text('Aucune note archivée'))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return NoteCard(
            title: note.title,
            content: note.content,
            type: _mapPriorityToType(note.priority),
            date: note.createdAt,
            isFavorite: note.isFavorite,
            category: _categoryNames[note.categoryId] ?? 'Inconnue',
            onTap: () {
              // Optionnel : Naviguer vers une page de détails
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailPage(note: note),
                ),
              );
            },
            onStarPressed: null,
            onEditPressed: null,
            onArchivePressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmer le désarchivage'),
                  content: const Text('Voulez-vous désarchiver cette note ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Désarchiver'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _unarchiveNote(note);
              }
            },
            onDeletePressed: () => _deleteNote(note),
          );
        },
      ),
    );
  }
}