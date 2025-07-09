import 'dart:io';
import 'package:flutter/material.dart';
import 'calling_trainee.dart';

class HomeScreen extends StatefulWidget {
  final String nom;
  final String prenom;
  final File? imageFile;

  const HomeScreen({
    super.key,
    required this.nom,
    required this.prenom,
    this.imageFile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedEtablissement;
  String? selectedSpecialite;
  String? selectedGroup;

  final TextEditingController _groupNameController = TextEditingController();
  int nombreStagiaires = 0;
  List<TextEditingController> stagiairesControllers = [];

  List<Map<String, dynamic>> groupes = [];

  void updateControllers(int count) {
    stagiairesControllers = List.generate(
      count,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in stagiairesControllers) {
      controller.dispose();
    }
    _groupNameController.dispose();
    super.dispose();
  }

  void createGroup() {
    if (_groupNameController.text.isEmpty || stagiairesControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir le nom du groupe et les stagiaires."),
        ),
      );
      return;
    }

    List<String> stagiaires = stagiairesControllers
        .map((e) => e.text.trim())
        .toList();

    // Vérifier qu’aucun stagiaire n’est vide
    if (stagiaires.any((name) => name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les noms des stagiaires."),
        ),
      );
      return;
    }

    setState(() {
      groupes.add({
        'name': _groupNameController.text.trim(),
        'stagiaires': stagiaires,
      });
      selectedGroup = _groupNameController.text.trim();
      _groupNameController.clear();
      nombreStagiaires = 0;
      stagiairesControllers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF367CFE),
      appBar: AppBar(
        title: const Text('Bienvenue !'),
        backgroundColor: const Color(0xFF427EEF),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (widget.imageFile != null)
            CircleAvatar(
              radius: 60,
              backgroundImage: FileImage(widget.imageFile!),
            ),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListView(
                children: [
                  const Text("Établissement"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: const OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "cfifj", child: Text("CFIFJ")),
                      DropdownMenuItem(value: "cfpms", child: Text("CFPMS")),
                    ],
                    value: selectedEtablissement,
                    onChanged: (value) {
                      setState(() {
                        selectedEtablissement = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text("Spécialité"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF427EEF)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "infrastructure",
                        child: Text("Infrastructure Digitale"),
                      ),
                      DropdownMenuItem(
                        value: "developpement",
                        child: Text("Développement"),
                      ),
                      DropdownMenuItem(
                        value: "electrique",
                        child: Text("Génie Électrique"),
                      ),
                      DropdownMenuItem(
                        value: "design",
                        child: Text("Digital Design"),
                      ),
                      DropdownMenuItem(
                        value: "génie",
                        child: Text("Génie Civil"),
                      ),
                      DropdownMenuItem(
                        value: "TRI",
                        child: Text("TRI : Réseaux Informatiques"),
                      ),
                      DropdownMenuItem(
                        value: "TDI",
                        child: Text("TDI : Développement Informatique"),
                      ),
                      DropdownMenuItem(
                        value: "TSGE",
                        child: Text("TSGE : Gestion des Entreprises"),
                      ),
                      DropdownMenuItem(
                        value: "TSC",
                        child: Text("TSC : Commerce"),
                      ),
                    ],
                    value: selectedSpecialite,
                    onChanged: (value) {
                      setState(() {
                        selectedSpecialite = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  if (groupes.isNotEmpty) ...[
                    const Text("Choisir un groupe existant"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Choisir un groupe",
                      ),
                      items: groupes
                          .map(
                            (g) => DropdownMenuItem<String>(
                              value: g['name'],
                              child: Text(g['name']),
                            ),
                          )
                          .toList(),
                      value: selectedGroup,
                      onChanged: (value) {
                        setState(() {
                          selectedGroup = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Text("Créer un nouveau groupe"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Nom du groupe",
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text("Nombre de stagiaires"),
                  const SizedBox(height: 8),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Entrez le nombre",
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        setState(() {
                          nombreStagiaires = parsed;
                          updateControllers(parsed);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  if (stagiairesControllers.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        stagiairesControllers.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            controller: stagiairesControllers[index],
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: "Stagiaire ${index + 1}",
                              hintText: "Nom complet",
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  Center(
                    child: ElevatedButton(
                      onPressed: createGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6AC259),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Créer le groupe",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF42F91F),
                        fixedSize: const Size(147, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        if (selectedGroup == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Veuillez sélectionner un groupe."),
                            ),
                          );
                          return;
                        }
                        if (selectedEtablissement == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Veuillez sélectionner un établissement.",
                              ),
                            ),
                          );
                          return;
                        }
                        if (selectedSpecialite == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Veuillez sélectionner une spécialité.",
                              ),
                            ),
                          );
                          return;
                        }

                        final groupe = groupes.firstWhere(
                          (g) => g['name'] == selectedGroup,
                          orElse: () => {'stagiaires': <String>[]},
                        );
                        final stagiaires = List<String>.from(
                          groupe['stagiaires'],
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CallingTraineeScreen(
                              groupName: selectedGroup!,
                              stagiaires: stagiaires,
                              specialtyName: selectedSpecialite!,
                              establishmentName: selectedEtablissement!,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Soumettre',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
