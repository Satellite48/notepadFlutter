import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notepad/service/auth_service.dart';
import 'data/repository/note_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialiser l'animation de fondu
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    //vérification après 2 secondes
    Timer(const Duration(seconds: 2), () {
      _checkLoginAndNavigate();
    });
  }

  Future<void> _checkLoginAndNavigate() async {
    final authService = AuthService();

    try {
      final isLoggedIn = await authService.isLoggedIn();
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          isLoggedIn ? '/home' : '/sign_in',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/sign_in');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Précharger l'image
    precacheImage(const AssetImage('assets/images/splash_screen.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/splash_screen.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                'Bienvenue sur Block Note',
                style:
                    Theme.of(context).textTheme.headlineSmall ??
                    const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
    _controller.dispose();
    super.dispose();
  }
}
