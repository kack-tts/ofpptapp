import 'dart:io';
import 'package:flutter/material.dart';
import 'calling_trainee.dart';
import 'administrateur.dart';

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
  String? selectedRole;

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
      body: Stack(
        children: [
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (widget.imageFile != null)
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(widget.imageFile!),
                  ),
                const SizedBox(height: 10),
                Text(
                  "Bienvenue ${widget.nom} ${widget.prenom} !",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 200,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                children: [
                  const Text("Établissement"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "cfifj", child: Text("CFIFJ")),
                      DropdownMenuItem(value: "cfpms", child: Text("CFPMS")),
                    ],
                    value: selectedEtablissement,
                    onChanged: (value) =>
                        setState(() => selectedEtablissement = value),
                  ),
                  const SizedBox(height: 16),

                  const Text("Spécialité"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
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
                    onChanged: (value) =>
                        setState(() => selectedSpecialite = value),
                  ),
                  const SizedBox(height: 16),

                  const Text("Rôle"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "formateur",
                        child: Text("Formateur"),
                      ),
                      DropdownMenuItem(
                        value: "administrateur",
                        child: Text("Administrateur"),
                      ),
                      DropdownMenuItem(
                        value: "responsable",
                        child: Text("Responsable de classe"),
                      ),
                    ],
                    value: selectedRole,
                    onChanged: (value) => setState(() => selectedRole = value),
                  ),
                  const SizedBox(height: 16),

                  if (groupes.isNotEmpty) ...[
                    const Text("Choisir un groupe existant"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                      onChanged: (value) =>
                          setState(() => selectedGroup = value),
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
                        style: TextStyle(color: Colors.white),
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
                        if (selectedEtablissement == null ||
                            selectedSpecialite == null ||
                            selectedRole == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Veuillez remplir tous les champs.",
                              ),
                            ),
                          );
                          return;
                        }

                        if (selectedRole == 'administrateur') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CalendarPage(),
                            ),
                          );
                          return;
                        }

                        if (selectedGroup == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Veuillez choisir un groupe."),
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
                        "Continuer",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
