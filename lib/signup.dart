import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF427EEF),
      body: SafeArea(
        child: Column(
          children: [
            // Photo de profil
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 119,
                  height: 119,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF367CFE),
                    border: Border.all(color: Colors.white, width: 2),
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _image == null
                      ? const Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      : null,
                ),
              ),
            ),

            // Formulaire dans un Expanded pour prendre tout l'espace disponible
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 34,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildField(_nomController, "Nom"),
                        const SizedBox(height: 15),
                        buildField(_prenomController, "Prénom"),
                        const SizedBox(height: 15),
                        buildField(
                          _emailController,
                          "Email",
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        buildField(
                          _passwordController,
                          "Mot de passe",
                          obscureText: true,
                        ),
                        const SizedBox(height: 15),
                        buildField(
                          _confirmPasswordController,
                          "Confirmation de mot de passe",
                          obscureText: true,
                        ),
                        const SizedBox(height: 15),
                        buildField(
                          _pinController,
                          "PIN",
                          obscureText: true,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 30),
                        // Bouton fixe en bas du formulaire
                        SizedBox(
                          width: 175,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6AC259),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                      nom: _nomController.text,
                                      prenom: _prenomController.text,
                                      imageFile: _image,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Créer votre compte',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ), // Espace supplémentaire en bas
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(
    TextEditingController controller,
    String hint, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 60,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFF707B81), fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF707B81)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Champ requis';

          if (hint == "Email") {
            final isValidEmail =
                value.endsWith('@ofppt-edu.ma') || value.endsWith('@gmail.com');
            if (!isValidEmail)
              return 'Email doit se terminer par @ofppt-edu.ma ou @gmail.com';
          }

          if (hint == "Mot de passe" && value.length < 6) {
            return 'Mot de passe trop court';
          }

          if (hint == "Confirmation de mot de passe" &&
              value != _passwordController.text) {
            return 'Les mots de passe ne correspondent pas';
          }

          if (hint == "PIN" && (value.length < 4 || value.length > 6)) {
            return 'PIN doit contenir 4 à 6 chiffres';
          }

          return null;
        },
      ),
    );
  }
}
