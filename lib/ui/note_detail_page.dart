import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Seul import nécessaire pour l'i18n
import '../model/note.dart';
import '../data/repository/category_repository.dart';
import '../service/auth_service.dart';

class NoteDetailPage extends StatefulWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final AuthService _authService = AuthService();
  String? _categoryName;
  bool _isDateFormatInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _initializeDateFormatting();
    await _loadCategoryName(); // Charge les catégories
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('fr_FR', null);
    setState(() {
      _isDateFormatInitialized = true;
    });
  }

  Future<void> _loadCategoryName() async {
    try {
      final userId = await _authService.getCurrentUserId();
      print(
        'Chargement catégorie: userId=$userId, noteId=${widget.note.id}, categoryId=${widget.note.categoryId}',
      );
      if (userId != null) {
        // Vérifier si des catégories existent, sinon initialiser
        final categories = await _categoryRepository.getAllCategories(
          userId.toString(),
        );
        if (categories.isEmpty) {
          await _categoryRepository.initializeDefaultCategories(
            userId.toString(),
          );
        }
        final categoryName = await _categoryRepository.getCategoryName(
          widget.note.categoryId,
        );
        setState(() {
          _categoryName =
              categoryName?.isNotEmpty == true ? categoryName : 'Inconnue';
        });
      } else {
        setState(() {
          _categoryName = 'Inconnue';
        });
      }
    } catch (e) {
      setState(() {
        _categoryName = 'Inconnue';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDateFormatInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Détails de la note',
          style: TextStyle(
            fontSize: 30,
            fontStyle: FontStyle.normal,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte de métadonnées
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.note.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.category,
                      'Catégorie',
                      _categoryName ?? 'Chargement...',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.priority_high,
                      'Priorité',
                      widget.note.priority,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Date',
                      DateFormat(
                        'EEEE dd MMMM yyyy, HH:mm',
                        'fr_FR',
                      ).format(widget.note.createdAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Contenu de la note
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                widget.note.content,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey,
          ),
        ),
        Text(value, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
      ],
    );
  }
}
