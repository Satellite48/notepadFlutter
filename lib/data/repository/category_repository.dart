import 'package:notepad/data/dao/category_dao.dart';
import '../../model/category.dart';

class CategoryRepository {
  final CategoryDao _categoryDao = CategoryDao();

  Future<List<Category>> getAllCategories(String userId) async {
    return await _categoryDao.getAllForUser(userId);
  }

  Future<int> addCategory(Category category) async {
    final normalizedName = category.name.toLowerCase().trim();
    final exists = await _categoryDao.categoryExists(
      normalizedName,
      int.parse(category.userId),
    );
    if (exists) {
      return 0; // Catégorie existe déjà
    }
    return await _categoryDao.insert(
      Category(name: normalizedName, userId: category.userId),
    );
  }

  Future<bool> categoryExistsForUser(String name, int userId) async {
    return await _categoryDao.categoryExists(name, userId);
  }

  Future<String?> getCategoryName(int categoryId) async {
    return await _categoryDao.getCategoryName(categoryId);
  }

  Future<void> initializeDefaultCategories(String userId) async {
    const defaultCategories = [
      'Travail',
      'Personnel',
      'Études',
      'Idées',
      'Projets',
    ];
    for (final categoryName in defaultCategories) {
      final normalizedName = categoryName.toLowerCase().trim();
      final exists = await _categoryDao.categoryExists(
        normalizedName,
        int.parse(userId),
      );
      if (!exists) {
        final category = Category(name: normalizedName, userId: userId);
        await addCategory(category);
      }
    }
  }
}
