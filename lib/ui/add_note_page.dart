import 'package:flutter/material.dart';
import '../data/repository/note_repository.dart';
import '../data/repository/category_repository.dart';
import '../model/category.dart';
import '../model/note.dart';
import '../service/auth_service.dart';
import 'add_category_dialog.dart';

class AddNotePage extends StatefulWidget {
  final Note? note;

  const AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategory;
  String _selectedPriority = 'Défaut'; // Initialiser à 'Défaut' par défaut

  // Références aux repositories
  final CategoryRepository _categoryRepository = CategoryRepository();
  final NoteRepository _noteRepository = NoteRepository();
  final AuthService _authService = AuthService();
  late int _currentUserId;

  // Liste des catégories chargées depuis la base de données
  List<Category> _categoryObjects = [];
  List<String> _categories = [];

  final List<String> _priorities = ['Défaut', 'Important', 'Urgent'];

  @override
  void initState() {
    super.initState();
    // remplir les champs si une note est passée pour édition
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedPriority = widget.note!.priority;
    }
    _initializeUser();
  }

  //initianiser les categories par defaut
  Future<void> _initializeUser() async {
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        _currentUserId = userId;
        await _categoryRepository.initializeDefaultCategories(
          userId.toString(),
        );
        _loadCategories();
      } else {
        Navigator.pushReplacementNamed(context, '/sign_in');
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation de l\'utilisateur: $e');
    }
  }

  //obtenir les categories ajouter manuellement
  Future<void> _loadCategories() async {
    try {
      _categoryObjects = await _categoryRepository.getAllCategories(
        _currentUserId.toString(),
      );
      setState(() {
        _categories = _categoryObjects.map((c) => _capitalize(c.name)).toList();
        // Sélectionner la catégorie de la note existante ou aucune par défaut
        if (widget.note != null) {
          final categoryName =
              _categoryObjects
                  .firstWhere(
                    (cat) => cat.id == widget.note!.categoryId,
                    orElse:
                        () =>
                            _categoryObjects.isNotEmpty
                                ? _categoryObjects.first
                                : Category(id: 0, name: '', userId: ''),
                  )
                  .name;
          _selectedCategory =
              _categories.contains(_capitalize(categoryName))
                  ? _capitalize(categoryName)
                  : null;
        }
      });
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
    }
  }

  //diialogue catagorie
  void _showAddCategoryDialog() async {
    final dialog = AddCategoryDialog(
      categoryRepository: _categoryRepository,
      authService: _authService,
      context: context,
    );
    final newCategory = await dialog.show();
    if (newCategory != null) {
      await _loadCategories();

      // Trouver l'objet catégorie correspondant à la nouvelle catégorie
      try {
        final selectedCategoryObject = _categoryObjects.firstWhere(
          (category) =>
              _capitalize(category.name).toLowerCase() ==
              _selectedCategory!.toLowerCase(),
        );

        // Suite du code avec selectedCategoryObject
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: Catégorie "$_selectedCategory" non trouvée'),
          ),
        );
        return;
      }

      setState(() {
        _selectedCategory = _capitalize(newCategory);
      });
    }
  }

  void _showCategorySelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sélectionner une catégorie'),
            content: SizedBox(
              width: double.minPositive,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ..._categories.map(
                    (category) => ListTile(
                      leading: Icon(
                        category == 'Travail'
                            ? Icons.work
                            : category == 'Personnel'
                            ? Icons.person
                            : category == 'Études'
                            ? Icons.school
                            : category == 'Idées'
                            ? Icons.lightbulb
                            : category == 'Projets'
                            ? Icons.folder
                            : Icons.category,
                        color: Colors.blueAccent,
                      ),
                      title: Text(category),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.add, color: Colors.blueAccent),
                    title: const Text(
                      'Ajouter une catégorie',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddCategoryDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showPrioritySelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sélectionner une priorité'),
            content: SizedBox(
              width: double.minPositive,
              child: ListView(
                shrinkWrap: true,
                children:
                    _priorities
                        .map(
                          (priority) => ListTile(
                            leading: Icon(
                              priority == 'Défaut'
                                  ? Icons.low_priority
                                  : priority == 'Important'
                                  ? Icons.warning
                                  : Icons.error,
                              color: Colors.blueAccent,
                            ),
                            title: Text(priority),
                            onTap: () {
                              setState(() {
                                _selectedPriority = priority;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
    );
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      print('Validation du formulaire échouée');
      return;
    }

    if (_selectedCategory == null) {
      print(
        'Erreur: Catégorie non sélectionnée (catégorie: $_selectedCategory)',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
      );
      return;
    }

    try {
      print(
        'Tentative de sauvegarde: titre=${_titleController.text}, catégorie=$_selectedCategory, priorité=$_selectedPriority',
      );

      int? categoryId;
      for (var category in _categoryObjects) {
        if (_capitalize(category.name).toLowerCase() ==
            _selectedCategory!.toLowerCase()) {
          categoryId = category.id;
          break;
        }
      }

      if (categoryId == null) {
        print('Erreur: Catégorie non trouvée: $_selectedCategory');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: Catégorie "$_selectedCategory" non trouvée'),
          ),
        );
        return;
      }

      final note = Note(
        id: widget.note?.id, // ID existant pour édition, null pour création
        title: _titleController.text,
        content: _contentController.text,
        categoryId: categoryId,
        priority: _selectedPriority,
        userId: _currentUserId.toString(),
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        isFavorite: widget.note?.isFavorite ?? false,
        isArchived: widget.note?.isArchived ?? false,
      );

      if (widget.note == null) {
        // Création
        final noteId = await _noteRepository.addNote(note);
        if (noteId <= 0) {
          throw Exception('Échec de l\'enregistrement de la note');
        }
      } else {
        // Modification
        await _noteRepository.updateNote(note);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.note == null
                ? 'Note enregistrée avec succès !'
                : 'Note modifiée avec succès !',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.note_add, color: Colors.white, size: 26),
          ),
        ],
        title: Text(
          widget.note == null ? 'Nouvelle Note' : 'Modifier la Note',
          style: const TextStyle(
            fontSize: 30,
            fontStyle: FontStyle.normal,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        elevation: 4,
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ Titre
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold, // Texte en gras
                  color: Colors.blue, // Texte en bleu
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Section Catégorie
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Catégorie', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showCategorySelectionDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory ?? 'Choisir une catégorie',
                            style: TextStyle(
                              color:
                                  _selectedCategory == null
                                      ? Colors.grey.shade600
                                      : Colors.black,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Priorité
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Priorité', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showPrioritySelectionDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedPriority,
                            style: const TextStyle(color: Colors.black),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Contenu
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Contenu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),

              // Bouton Enregistrer
              ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.note == null
                      ? 'Enregistrer la note'
                      : 'Modifier la note',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
