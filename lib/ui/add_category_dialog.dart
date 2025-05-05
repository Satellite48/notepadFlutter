import 'package:flutter/material.dart';

import '../data/repository/category_repository.dart';
import '../model/category.dart';
import '../service/auth_service.dart';

class AddCategoryDialog {
  final CategoryRepository categoryRepository;
  final AuthService authService;
  final BuildContext context;
  late int _currentUserId;

  AddCategoryDialog({
    required this.categoryRepository,
    required this.authService,
    required this.context,
  });

  // Méthode pour ajouter une nouvelle catégorie à la base de données
  Future<void> _addCategoryToDatabase(String categoryName) async {
    try {
      final userId = await authService.getCurrentUserId();
      if (userId == null) {
        Navigator.pushReplacementNamed(context, '/sign_in');
        return;
      }
      _currentUserId = userId;

      final normalizedName =
          categoryName.toLowerCase().trim(); // Normaliser le nom
      final newCategory = Category(
        name: normalizedName,
        userId: _currentUserId.toString(),
      );

      final categoryId = await categoryRepository.addCategory(newCategory);

      if (categoryId > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catégorie Ajoutée!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cette catégorie existe déjà')),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de la catégorie: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  // Méthode pour afficher le Bottom Sheet
  Future<String?> show() async {
    final controller = TextEditingController();
    String? selectedCategory;

    await showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permet au Bottom Sheet de s'adapter au clavier
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).viewInsets.bottom, // Gère le clavier
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  "Nouvelle catégorie",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Nom de la catégorie",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Annuler",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (controller.text.isNotEmpty) {
                          await _addCategoryToDatabase(controller.text);
                          selectedCategory = controller.text;
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        "Ajouter",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );

    return selectedCategory;
  }
}
