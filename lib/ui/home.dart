import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:notepad/ui/profil_popup.dart';
import '../data/repository/note_repository.dart';
import '../data/repository/category_repository.dart';
import '../model/note.dart';
import '../service/auth_service.dart';
import 'archive_note_page.dart';
import 'filtre_page.dart';
import 'note_card.dart';
import 'note_detail_page.dart';
import 'add_note_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Propriétés
  final NoteRepository _noteRepository = NoteRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  Map<int, String> _categoryNames = {};
  String? _selectedFilter;

  // Pour la pagination
  int _currentPage = 0;
  final int _notesPerPage = 10;
  bool _isLoading = false;
  bool _hasMoreNotes = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterNotes);
    _scrollController.addListener(_scrollListener);
    // Utilisation d'un délai pour laisser l'interface se construire d'abord
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotes();
    });
  }

  //  le défilement jusqu'en bas
  void _scrollListener() {
    if (!_scrollController.hasClients || _isLoading || !_hasMoreNotes) return;

    final thresholdReached =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (thresholdReached) {
      _loadMoreNotes();
    }
  }

  //  pour le filtrage
  // variable qui  stocke le dernier Timer de debounce
  Timer? _debounceTimer;

  void _filterNotes() {
    _debounceTimer?.cancel();

    // Créer un nouveau timer de 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text;

      setState(() {
        _filteredNotes = filterNotes(
          notes: _notes,
          query: query,
          selectedFilter: _selectedFilter,
        );
      });
    });
  }

  // Charge les notes  la liste complète
  Future<void> _loadNotes() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMoreNotes = true;
      _notes.clear(); // Vider la liste
    });

    final userId = await _authService.getCurrentUserId();
    if (userId != null) {
      try {
        // Charger la première page des notes
        final notes = await _noteRepository.getPaginatedNotes(
          userId.toString(),
          _currentPage,
          _notesPerPage,
          includeArchived: false,
        );

        // Déterminer s'il y a plus de notes à charger
        _hasMoreNotes = notes.length == _notesPerPage;

        // Récupérer les catégories
        final categories = await _categoryRepository.getAllCategories(
          userId.toString(),
        );

        // Mise à jour de l'état
        setState(() {
          _notes.addAll(notes);
          _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _categoryNames = {for (var cat in categories) cat.id!: cat.name};
          _filteredNotes = [..._notes];
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Afficher une erreur à l'utilisateur
        _showErrorSnackBar('Erreur lors du chargement des notes: $e');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Charger plus de notes (pagination) - optimisé
  Future<void> _loadMoreNotes() async {
    if (_isLoading || !_hasMoreNotes) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        _currentPage++;

        final moreNotes = await _noteRepository.getPaginatedNotes(
          userId.toString(),
          _currentPage,
          _notesPerPage,
          includeArchived: false,
        );

        // Déterminer s'il y a encore plus de notes à charger
        _hasMoreNotes = moreNotes.length == _notesPerPage;

        // Appliquer le tri uniquement aux nouvelles notes et les insérer
        moreNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        setState(() {
          _notes.addAll(moreNotes);
          // Appliquer le même filtre aux notes mises à jour
          _filterNotes();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(
        'Erreur lors du chargement de notes supplémentaires: $e',
      );
    }
  }

  // Méthode  pour afficher les erreurs
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Optimisation pour les opérations sur les notes
  Future<void> _archiveNote(Note note) async {
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
        isArchived: true, // Archiver la note
      );

      await _noteRepository.updateNote(updatedNote);

      // Mettre à jour localement sans recharger toutes les notes
      setState(() {
        _notes.removeWhere((n) => n.id == note.id);
        _filterNotes();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note archivée'),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Erreur lors de l\'archivage: $e');
    }
  }

  // Toggle favoris optimisé
  Future<void> _toggleFavorite(Note note) async {
    final oldFavoriteState = note.isFavorite;
    final noteIndex = _notes.indexWhere((n) => n.id == note.id);

    if (noteIndex == -1) return;

    setState(() {
      _notes[noteIndex] = Note(
        id: note.id,
        title: note.title,
        content: note.content,
        categoryId: note.categoryId,
        priority: note.priority,
        userId: note.userId,
        createdAt: note.createdAt,
        isFavorite: !note.isFavorite,
        isArchived: note.isArchived,
      );
      _filterNotes();
    });

    try {
      // Puis envoyer au serveur
      await _noteRepository.updateNote(_notes[noteIndex]);
    } catch (e) {
      // En cas d'erreur
      setState(() {
        _notes[noteIndex] = Note(
          id: note.id,
          title: note.title,
          content: note.content,
          categoryId: note.categoryId,
          priority: note.priority,
          userId: note.userId,
          createdAt: note.createdAt,
          isFavorite: oldFavoriteState,
          isArchived: note.isArchived,
        );
        _filterNotes();
      });
      _showErrorSnackBar('Erreur lors de la mise à jour: $e');
    }
  }

  //convertir le type de note en 0.1.2
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
      appBar: AppBar(
        title: const Text(
          'Mes Notes',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () async {
              final lastname = await _authService.getCurrentUserLastname();
              final firstname = await _authService.getCurrentUserFirstname();
              final email = await _authService.getCurrentUserEmail();
              showProfilePopup(context, lastname, firstname, email);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => _searchFocusNode.unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Rechercher des notes...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(Icons.filter_list),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _showFilterOptionsFromExternal(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildNotesList()),
            const SizedBox(height: 60),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.edit_note),
            label: 'Ajouter une note',
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            onTap: _navigateToAddNote,
          ),
          SpeedDialChild(
            child: const Icon(Icons.archive),
            label: 'Notes archivées',
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            onTap: _navigateToArchivedNotes,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNotesList() {
    if (_isLoading && _filteredNotes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredNotes.isEmpty) {
      return const Center(child: Text('Aucune note trouvée'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredNotes.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Indicateur de chargement au bas de la liste
        if (index == _filteredNotes.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final note = _filteredNotes[index];
        return _buildDismissibleNoteCard(note);
      },
    );
  }

  Widget _buildDismissibleNoteCard(Note note) {
    return Dismissible(
      key: Key(note.id.toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.blue.shade100,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: const Icon(Icons.archive, color: Colors.blueAccent, size: 32.0),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note archivée'),
              backgroundColor: Colors.blueAccent,
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
          await _archiveNote(note);
          return true;
        }
        return false;
      },
      child: NoteCard(
        title: note.title,
        content: note.content,
        type: _mapPriorityToType(note.priority),
        date: note.createdAt,
        isFavorite: note.isFavorite,
        category: _categoryNames[note.categoryId] ?? 'Inconnue',
        onTap: () => _navigateToNoteDetail(note),
        onStarPressed: () => _toggleFavorite(note),
        onEditPressed: () => _navigateToEditNote(note),
        onArchivePressed: () => _confirmArchive(note),
        onDeletePressed: () => _confirmDelete(note),
      ),
    );
  }

  // Navigation vers la page de détail de note
  void _navigateToNoteDetail(Note note) {
    _searchFocusNode.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailPage(note: note)),
    );
  }

  // Navigation vers la page d'édition de note
  void _navigateToEditNote(Note note) {
    _searchFocusNode.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNotePage(note: note)),
    ).then((_) => _loadNotes());
  }

  // Navigation vers la page d'ajout de note
  Future<void> _navigateToAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNotePage()),
    );
    if (result == true) {
      await _loadNotes();
    }
  }

  // Navigation vers la page des notes archivées
  Future<void> _navigateToArchivedNotes() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const ArchivedNotesPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
    if (result == true) {
      await _loadNotes();
    }
  }

  // Confirmation d'archivage
  Future<void> _confirmArchive(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer l\'archivage'),
            content: const Text('Voulez-vous archiver cette note ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Archiver'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _archiveNote(note);
    }
  }

  // Confirmation de suppression
  Future<void> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text('Voulez-vous vraiment supprimer cette note ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    if (note.id == null) {
      SnackBar(
        content: Text('ID de note manquant'),
        behavior: SnackBarBehavior.floating,
      );
      return;
    }

    try {
      final result = await _noteRepository.deleteNote(note.id!);
      if (result > 0) {
        // Mise à jour locale
        setState(() {
          _notes.removeWhere((n) => n.id == note.id);
          _filterNotes();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note supprimée avec succès'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune note trouvée avec cet ID'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Méthode externe pour le filtrage
  void _showFilterOptionsFromExternal() {
    showFilterOptions(
      context: context,
      selectedFilter: _selectedFilter,
      onFilterSelected: (filter) {
        setState(() {
          _selectedFilter = filter;
          _filterNotes();
        });
      },
    );
  }

  // Libération des ressources
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
