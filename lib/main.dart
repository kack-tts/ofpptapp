import 'package:flutter/material.dart';
import 'dart:async';
import 'signup.dart'; // Assure-toi que ce fichier existe avec la classe SignUpScreen
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

// -------------------- Splash Screen --------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/logo.png'),
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}

// -------------------- Login Screen --------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _imageController;

  @override
  void initState() {
    super.initState();
    _imageController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Ellipse 700x700
          Positioned(
            left: -206,
            top: -427,
            child: Container(
              width: 700,
              height: 700,
              decoration: BoxDecoration(
                color: const Color(0xD9367CFE),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(1.0),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          // Vector 398x398 (9BBEFD)
          Positioned(
            left: -163,
            top: -292,
            child: Container(
              width: 398,
              height: 398,
              decoration: const BoxDecoration(
                color: Color(0xFF9BBEFD),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Autre ellipse 398x398 (B0CBFF)
          Positioned(
            left: 235,
            top: -16,
            child: Container(
              width: 398,
              height: 398,
              decoration: const BoxDecoration(
                color: Color(0xFFB0CBFF),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Texte "Welcome back"
          const Positioned(
            left: 40,
            top: 120,
            child: Text(
              'Welcome\nback',
              style: TextStyle(
                fontSize: 38,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),

          // Formulaire Scrollable
          Positioned.fill(
            top: 300,
            bottom: 120,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  // Email
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: TextField(
                          decoration: InputDecoration.collapsed(
                            hintText: 'Your Email@ofppt-edu.ma',
                            hintStyle: TextStyle(color: Color(0xFF707B81)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Mot de passe
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: TextField(
                          obscureText: true,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Mot de passe',
                            hintStyle: TextStyle(color: Color(0xFF707B81)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton flèche avec navigation vers HomeScreen
          Positioned(
            right: 36,
            bottom: 100,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      nom: 'TonNom',
                      prenom: 'TonPrénom',
                      imageFile: null,
                    ),
                  ),
                );
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF367CFE),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ),
          ),

          // Boutons en bas fixés
          Positioned(
            left: 36,
            right: 36,
            bottom: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Action "Forgot password"
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
