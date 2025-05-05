import '../../model/user.dart';
import '../../utils/constante.dart';
import '../database/exception.dart';
import '../dao/user_dao.dart';

class UserRepository {
  final UserDao _userDao = UserDao();

  Future<SignUpResult> saveUser(User user) async {
    bool exists = await _userDao.emailExists(user.email);

    if (exists) {
      return SignUpResult.emailExists;
    }

    try {
      final userId = await _userDao.insertUser(user);
      user.id = userId;
      return SignUpResult.success;
    } on DatabaseException catch (e) {
      print('Erreur lors de l\'insertion de l\'utilisateur: $e');
      return SignUpResult.error;
    }
  }

  //login
  Future<User?> login(String email, String password) async {
    return await _userDao.checkLogin(email, password);
  }
}
