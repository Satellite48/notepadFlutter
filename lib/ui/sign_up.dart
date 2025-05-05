import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../data/repository/user_repository.dart';
import '../utils/constante.dart';
import '../model/user.dart';
import '../service/auth_service.dart';
import 'home.dart';
import 'sign_in.dart';

class SignUpModel {
  final ValueNotifier<String> nom = ValueNotifier<String>('');
  final ValueNotifier<String> prenom = ValueNotifier<String>('');
  final ValueNotifier<String> email = ValueNotifier<String>('');
  final ValueNotifier<String> password = ValueNotifier<String>('');
  final ValueNotifier<String> confirmPassword = ValueNotifier<String>('');
  final ValueNotifier<bool> isValidNotifier = ValueNotifier<bool>(false); // Corrigé ici
  bool isValidEmail() {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email.value);
  }

  void updateValidity() {
    isValidNotifier.value = nom.value.isNotEmpty &&
        prenom.value.isNotEmpty &&
        email.value.isNotEmpty &&
        isValidEmail() &&
        password.value.isNotEmpty &&
        password.value.length >= 6 &&
        password.value == confirmPassword.value;
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  final UserRepository _userRepository = UserRepository();
  final SignUpModel model = SignUpModel();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade900
                  : Colors.blue.shade50,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.blue.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animation Lottie
                    Lottie.asset(
                      'assets/animations/note_animation.json',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Inscription',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Affichage des erreurs
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade200.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            color: Colors.red.shade800,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    // TextField Nom
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          model.nom.value = value;
                          model.updateValidity();
                          _errorMessage = null;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Nom',
                        prefixIcon:
                        const Icon(Icons.person, color: Colors.blueAccent),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),

                    // TextField Prénom
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          model.prenom.value = value;
                          model.updateValidity();
                          _errorMessage = null;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Prénom',
                        prefixIcon:
                        const Icon(Icons.person, color: Colors.blueAccent),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),

                    // TextField Email
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          model.email.value = value;
                          model.updateValidity();
                          _errorMessage = null;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon:
                        const Icon(Icons.email, color: Colors.blueAccent),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                        errorText: model.email.value.isNotEmpty &&
                            !model.isValidEmail()
                            ? 'Veuillez entrer un email valide'
                            : null,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // TextField Mot de passe
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          model.password.value = value;
                          model.updateValidity();
                          _errorMessage = null;
                        });
                      },
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Mot de passe',
                        prefixIcon:
                        const Icon(Icons.lock, color: Colors.blueAccent),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                        errorText: model.password.value.isNotEmpty &&
                            model.password.value.length < 6
                            ? 'Le mot de passe doit contenir au moins 6 caractères'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TextField Confirmer le mot de passe
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          model.confirmPassword.value = value;
                          model.updateValidity();
                          _errorMessage = null;
                        });
                      },
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Répéter le mot de passe',
                        prefixIcon:
                        const Icon(Icons.lock, color: Colors.blueAccent),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                        errorText: model.confirmPassword.value.isNotEmpty &&
                            model.password.value != model.confirmPassword.value
                            ? 'Les mots de passe ne correspondent pas'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Bouton S'inscrire
                    ValueListenableBuilder<bool>(
                      valueListenable: model.isValidNotifier,
                      builder: (context, isValid, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isLoading
                                ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent),
                            )
                                : GestureDetector(
                              onTapDown: isValid
                                  ? (_) => setState(() => _isLoading = true)
                                  : null,
                              child: AnimatedScale(
                                scale: isValid ? 1.0 : 0.95,
                                duration: const Duration(milliseconds: 200),
                                child: ElevatedButton(
                                  onPressed: isValid
                                      ? () async {
                                    setState(() {
                                      _isLoading = true;
                                      _errorMessage = null;
                                    });

                                    try {
                                      final user = User(
                                        lastname: model.nom.value,
                                        firstname:
                                        model.prenom.value,
                                        email: model.email.value,
                                        password:
                                        model.password.value,
                                      );

                                      final result =
                                      await _userRepository
                                          .saveUser(user);

                                      setState(() {
                                        _isLoading = false;
                                      });

                                      if (!mounted) return;

                                      switch (result) {
                                        case SignUpResult.success:
                                          ScaffoldMessenger.of(
                                              context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                      Icons
                                                          .check_circle,
                                                      color: Colors
                                                          .white),
                                                  const SizedBox(
                                                      width: 8),
                                                  Text(
                                                    'Inscription réussie !',
                                                    style: GoogleFonts
                                                        .poppins(),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor:
                                              Colors.green,
                                              shape:
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(12),
                                              ),
                                              behavior:
                                              SnackBarBehavior
                                                  .floating,
                                            ),
                                          );
                                          await AuthService()
                                              .saveLoggedInUser(
                                            user.id!,
                                            user.email,
                                            user.lastname,
                                            user.firstname,
                                          );

                                          Navigator.pushReplacement(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context,
                                                  animation,
                                                  secondaryAnimation) =>
                                              const HomePage(),
                                              transitionsBuilder:
                                                  (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                          break;

                                        case SignUpResult
                                            .emailExists:
                                          setState(() {
                                            _errorMessage =
                                            'Cet email est déjà utilisé.';
                                          });
                                          break;

                                        case SignUpResult.error:
                                          setState(() {
                                            _errorMessage =
                                            'Une erreur est survenue. Veuillez réessayer.';
                                          });
                                          break;
                                      }
                                    } catch (e) {
                                      setState(() {
                                        _isLoading = false;
                                        _errorMessage =
                                        'Erreur: ${e.toString()}';
                                      });
                                    }
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 32),
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                    shadowColor:
                                    Colors.blueAccent.withOpacity(0.5),
                                  ),
                                  child: Text(
                                    'S\'INSCRIRE',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Lien vers la connexion
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Vous avez déjà un compte ? ",
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const SignInPage(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Se connecter",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}