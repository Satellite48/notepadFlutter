import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:notepad/data/repository/user_repository.dart';
import 'package:notepad/ui/home.dart';
import 'package:notepad/ui/sign_up.dart';
import '../service/auth_service.dart';

class SignInModel {
  final ValueNotifier<String> email = ValueNotifier<String>('');
  final ValueNotifier<String> password = ValueNotifier<String>('');
  final ValueNotifier<bool> isValidNotifier = ValueNotifier<bool>(false);

  void updateValidity() {
    isValidNotifier.value =
        email.value.isNotEmpty &&
        password.value.isNotEmpty &&
        password.value.length >= 6 &&
        isValidEmail();
  }

  bool isValidEmail() {
    final emailRegExp = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email.value);
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  final SignInModel model = SignInModel();
  String? _errorMessage;
  bool _isLoading = false;
  final UserRepository _userRepository = UserRepository();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
                    // Animation Lottie (ou icône si Lottie n'est pas configuré)
                    Lottie.asset(
                      'assets/animations/note_animation.json',
                      width: 200,
                      height: 200,
                      onLoaded: (composition) {},
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Connexion',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).brightness == Brightness.dark
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

                    // Champ Email
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
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Colors.blueAccent,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
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
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                        errorText:
                            model.email.value.isNotEmpty &&
                                    !model.isValidEmail()
                                ? 'Veuillez entrer un email valide'
                                : null,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Champ Mot de passe
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
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.blueAccent,
                        ),
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
                          vertical: 16,
                          horizontal: 12,
                        ),
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
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                        errorText:
                            model.password.value.isNotEmpty &&
                                    model.password.value.length < 6
                                ? 'Le mot de passe doit contenir au moins 6 caractères'
                                : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bouton Se connecter
                    ValueListenableBuilder<bool>(
                      valueListenable: model.isValidNotifier,
                      builder: (context, isValid, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isLoading
                                ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blueAccent,
                                  ),
                                )
                                : GestureDetector(
                                  onTapDown:
                                      isValid
                                          ? (_) =>
                                              setState(() => _isLoading = true)
                                          : null,
                                  child: AnimatedScale(
                                    scale: isValid ? 1.0 : 0.95,
                                    duration: const Duration(milliseconds: 200),
                                    child: ElevatedButton(
                                      onPressed:
                                          isValid
                                              ? () async {
                                                setState(() {
                                                  _isLoading = true;
                                                  _errorMessage = null;
                                                });

                                                try {
                                                  final user =
                                                      await _userRepository
                                                          .login(
                                                            model.email.value,
                                                            model
                                                                .password
                                                                .value,
                                                          );

                                                  setState(() {
                                                    _isLoading = false;
                                                  });

                                                  if (user != null) {
                                                    await AuthService()
                                                        .saveLoggedInUser(
                                                          user.id!,
                                                          user.email,
                                                          user.lastname,
                                                          user.firstname,
                                                        );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Text(
                                                              'Connexion réussie !',
                                                              style:
                                                                  GoogleFonts.poppins(),
                                                            ),
                                                          ],
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                      ),
                                                    );
                                                    Navigator.pushReplacement(
                                                      context,
                                                      PageRouteBuilder(
                                                        pageBuilder:
                                                            (
                                                              context,
                                                              animation,
                                                              secondaryAnimation,
                                                            ) =>
                                                                const HomePage(),
                                                        transitionsBuilder: (
                                                          context,
                                                          animation,
                                                          secondaryAnimation,
                                                          child,
                                                        ) {
                                                          return FadeTransition(
                                                            opacity: animation,
                                                            child: child,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  } else {
                                                    setState(() {
                                                      _errorMessage =
                                                          'Email ou mot de passe incorrect.';
                                                    });
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
                                          vertical: 16,
                                          horizontal: 32,
                                        ),
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 5,
                                        shadowColor: Colors.blueAccent
                                            .withOpacity(0.5),
                                      ),
                                      child: Text(
                                        'SE CONNECTER',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 16),

                            // Lien vers l'inscription
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Vous n'avez pas de compte ? ",
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => const SignUpPage(),
                                        transitionsBuilder: (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "S'inscrire",
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
