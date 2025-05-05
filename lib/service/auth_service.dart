import 'package:shared_preferences/shared_preferences.dart';

import '../data/repository/category_repository.dart';

class AuthService {
  static const String KEY_USER_ID = "current_user_id";
  static const String KEY_USER_EMAIL = "current_user_email";
  static const String KEY_USER_LASTNAME = "current_user_lastname";
  static const String KEY_USER_FIRSTNAME = "current_user_firstname";
  final CategoryRepository _categoryRepository = CategoryRepository();

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Stocker les infos de l'utilisateur connecté et initialise les catégories par défaut
  Future<void> saveLoggedInUser(
    int userId,
    String email,
    String lastname,
    String firstname,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(KEY_USER_ID, userId);
    await prefs.setString(KEY_USER_EMAIL, email);
    await prefs.setString(KEY_USER_LASTNAME, lastname);
    await prefs.setString(KEY_USER_FIRSTNAME, firstname);

    // Initialiser les catégories par défaut pour cet utilisateur
    await _categoryRepository.initializeDefaultCategories(userId.toString());
  }

  // Récupèrer l'ID de l'utilisateur connecté
  Future<int?> getCurrentUserId() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getInt(KEY_USER_ID);
  }

  // Récupèrer le nom de l'utilisateur connecté
  Future<String?> getCurrentUserLastname() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(KEY_USER_LASTNAME);
  }

  // Récupèrer le prénom de l'utilisateur connecté
  Future<String?> getCurrentUserFirstname() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(KEY_USER_FIRSTNAME);
  }

  // Récupèrer l'email de l'utilisateur connecté
  Future<String?> getCurrentUserEmail() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(KEY_USER_EMAIL);
  }

  // Vérifier si un utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final userId = await getCurrentUserId();
    return userId != null;
  }

  // Déconnecter l'utilisateur
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_USER_ID);
    await prefs.remove(KEY_USER_EMAIL);
    await prefs.remove(KEY_USER_LASTNAME);
    await prefs.remove(KEY_USER_FIRSTNAME);
  }
}
