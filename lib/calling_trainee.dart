import 'package:flutter/material.dart';

class CallingTraineeScreen extends StatefulWidget {
  final String groupName;
  final List<String> stagiaires;
  final String specialtyName;
  final String establishmentName;

  const CallingTraineeScreen({
    super.key,
    required this.groupName,
    required this.stagiaires,
    required this.specialtyName,
    required this.establishmentName,
  });

  @override
  State<CallingTraineeScreen> createState() => _CallingTraineeScreenState();
}

class _CallingTraineeScreenState extends State<CallingTraineeScreen> {
  int _currentIndex = 1;
  final Map<String, bool> _attendance = {};
  final Map<String, String> _notes = {};
  final Map<String, bool> _excluded = {};
  final TextEditingController _noteController = TextEditingController();
  final PageController _pageController = PageController(
    viewportFraction: 0.32,
    initialPage: 1,
  );
  bool _hasUnsavedChanges = false;
  bool _showSuccessMessage = false;
  bool _showSaveOptions = false;
  String _currentNoteToSave = '';
  bool _alphabeticalOrder = false;

  @override
  void initState() {
    super.initState();
    for (var stagiaire in widget.stagiaires) {
      _attendance[stagiaire] = true;
      _notes[stagiaire] = '';
      _excluded[stagiaire] = false;
    }
    if (widget.stagiaires.isNotEmpty) {
      _noteController.text = _notes[widget.stagiaires[_currentIndex]] ?? '';
      _noteController.addListener(() {
        final currentTrainee = widget.stagiaires[_currentIndex];
        if (_notes[currentTrainee] != _noteController.text) {
          setState(() {
            _notes[currentTrainee] = _noteController.text;
            _hasUnsavedChanges = true;
          });
        }
      });

      _pageController.addListener(() {
        int? nextPage = _pageController.page?.round();
        if (nextPage != null &&
            _currentIndex != nextPage &&
            nextPage < widget.stagiaires.length) {
          setState(() {
            _currentIndex = nextPage;
            _noteController.text =
                _notes[widget.stagiaires[_currentIndex]] ?? '';
          });
        }
      });
    }
  }

  void _toggleAttendance(bool isPresent) {
    setState(() {
      _attendance[widget.stagiaires[_currentIndex]] = isPresent;
      _hasUnsavedChanges = true;
    });
  }

  void _toggleExclusion(bool isExcluded) {
    setState(() {
      _excluded[widget.stagiaires[_currentIndex]] = isExcluded;
      _hasUnsavedChanges = true;
    });
  }

  void _saveData() {
    setState(() {
      _hasUnsavedChanges = false;
      _showSaveOptions = true;
      _currentNoteToSave = _notes[widget.stagiaires[_currentIndex]] ?? '';
    });
  }

  void _confirmSave() {
    setState(() {
      _showSaveOptions = false;
      _showSuccessMessage = true;
    });

    print("Données sauvegardées:");
    print("Présence: $_attendance");
    print("Notes: $_notes");
    print("Exclusions: $_excluded");

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessMessage = false;
        });
      }
    });
  }

  void _cancelSave() {
    setState(() {
      _showSaveOptions = false;
    });
  }

  void _deleteNote() {
    setState(() {
      _notes[widget.stagiaires[_currentIndex]] = '';
      _noteController.text = '';
      _showSaveOptions = false;
      _hasUnsavedChanges = true;
    });
  }

  void _showSuccess() {
    setState(() {
      _showSuccessMessage = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessMessage = false;
        });
      }
    });
  }

  void _showEditOptions(BuildContext context) {
    final currentTrainee = widget.stagiaires[_currentIndex];
    final isExcluded = _excluded[currentTrainee] ?? false;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.group_remove),
                title: const Text('Exclusion du groupe'),
                trailing: Switch(
                  value: isExcluded,
                  onChanged: (value) {
                    _toggleExclusion(value);
                    Navigator.pop(context);
                  },
                ),
              ),
              const Divider(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile(
                Icons.print,
                'Imprimer le PV',
                () => _printAttendanceReport(),
              ),
              _buildOptionTile(
                Icons.list,
                'Imprimer la liste d\'absence',
                () => _printAbsenceList(),
              ),
              const Divider(),
              _buildOptionTile(
                Icons.check_circle,
                'Marquer tous présents',
                () => _markAllPresent(),
              ),
              _buildOptionTile(
                Icons.cancel,
                'Marquer tous absents',
                () => _markAllAbsent(),
              ),
              _buildOptionTile(
                Icons.sort_by_alpha,
                'Ordre alphabétique',
                () => _toggleAlphabeticalOrder(),
              ),
              _buildOptionTile(
                Icons.bar_chart,
                'Statut de présence',
                () => _showAttendanceStatus(),
              ),
              _buildOptionTile(
                Icons.access_time,
                'Dernière marque',
                () => _showLastMarked(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D87F7)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _printAttendanceReport() {
    print("Génération du PV...");
    _showSuccessMessageWithText("PV généré avec succès");
  }

  void _printAbsenceList() {
    print("Génération de la liste d'absence...");
    _showSuccessMessageWithText("Liste d'absence générée");
  }

  void _markAllPresent() {
    setState(() {
      for (var trainee in widget.stagiaires) {
        _attendance[trainee] = true;
      }
      _hasUnsavedChanges = true;
    });
    _showSuccessMessageWithText("Tous marqués présents");
  }

  void _markAllAbsent() {
    setState(() {
      for (var trainee in widget.stagiaires) {
        _attendance[trainee] = false;
      }
      _hasUnsavedChanges = true;
    });
    _showSuccessMessageWithText("Tous marqués absents");
  }

  void _toggleAlphabeticalOrder() {
    setState(() {
      _alphabeticalOrder = !_alphabeticalOrder;
      if (_alphabeticalOrder) {
        widget.stagiaires.sort();
      }
      _currentIndex = 0;
      _pageController.jumpToPage(0);
    });
    _showSuccessMessageWithText(
      _alphabeticalOrder
          ? "Tri alphabétique activé"
          : "Tri alphabétique désactivé",
    );
  }

  void _showAttendanceStatus() {
    int presentCount = _attendance.values.where((v) => v).length;
    int absentCount = widget.stagiaires.length - presentCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statut de présence'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Présents: $presentCount'),
            Text('Absents: $absentCount'),
            Text('Total: ${widget.stagiaires.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLastMarked() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dernière marque'),
        content: const Text('Fonctionnalité en développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessageWithText(String message) {
    setState(() {
      _showSuccessMessage = true;
      _successMessage = message;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessMessage = false;
        });
      }
    });
  }

  Widget _buildAvatar(int index, double radius) {
    final isExcluded = _excluded[widget.stagiaires[index]] ?? false;

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: isExcluded ? Colors.grey : const Color(0xFF0D87F7),
          child: ClipOval(
            child: Image.asset(
              "assets/images/stagiaire.jpg",
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: radius * 2,
                  height: radius * 2,
                  color: isExcluded ? Colors.grey : const Color(0xFF0D87F7),
                  child: Icon(
                    Icons.person,
                    color: const Color.fromARGB(112, 240, 227, 227),
                    size: radius * 1.2,
                  ),
                );
              },
            ),
          ),
        ),
        if (isExcluded)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.block, color: Colors.white, size: 12),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _successMessage = "Success!";

  @override
  Widget build(BuildContext context) {
    final currentTraineeName = widget.stagiaires[_currentIndex];
    final bool isPresent = _attendance[currentTraineeName] ?? true;
    final double blueSectionHeight = MediaQuery.of(context).size.height * 0.6;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _hasUnsavedChanges ? _saveData : null,
        backgroundColor: _hasUnsavedChanges
            ? const Color(0xFF0D87F7)
            : Colors.grey,
        child: const Icon(Icons.save),
      ),
      body: Stack(
        children: [
          if (_showSuccessMessage)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green,
                child: Column(
                  children: [
                    Text(
                      _successMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_successMessage == "Success!") ...[
                      const SizedBox(height: 8),
                      const Text(
                        "Your file has been uploaded successfully",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          Positioned(
            top: _showSuccessMessage ? 120 : 0,
            left: 0,
            right: 0,
            height: blueSectionHeight,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF367CFE), Color(0xFF2C6FEF)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const Text(
                                "Retour",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                                onPressed: () => _showOptionsMenu(context),
                              ),
                              GestureDetector(
                                onTap: _showSuccess,
                                child: Container(
                                  width: 82,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Donné",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChipRow(
                            "Specialty :",
                            "${widget.establishmentName} | ${widget.specialtyName}",
                          ),
                          const SizedBox(height: 8),
                          _buildChipRow("Group :", widget.groupName),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Trainee ${_currentIndex + 1}/${widget.stagiaires.length}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height:
                                190.0, // Increased height to prevent overflow
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: widget.stagiaires.length,
                              clipBehavior: Clip.none,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentIndex = index;
                                  _noteController.text =
                                      _notes[widget
                                          .stagiaires[_currentIndex]] ??
                                      '';
                                });
                              },
                              itemBuilder: (context, index) {
                                final stagiaire = widget.stagiaires[index];
                                final isFocused = index == _currentIndex;
                                final isExcluded =
                                    _excluded[stagiaire] ?? false;

                                // Adjusted dimensions to prevent overflow
                                final double cardWidth = isFocused
                                    ? 120.0
                                    : 90.0;
                                final double cardHeight = isFocused
                                    ? 210.0
                                    : 160.0;
                                final double avatarRadius = isFocused
                                    ? 35.0
                                    : 25.0;
                                final double nameFontSize = isFocused
                                    ? 14.0
                                    : 11.0;

                                return Center(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    width: cardWidth,
                                    height: cardHeight,
                                    decoration: BoxDecoration(
                                      color: isExcluded
                                          ? Colors.grey[200]
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        isFocused ? 20 : 15,
                                      ),
                                      boxShadow: [
                                        if (isFocused)
                                          BoxShadow(
                                            color: Colors.black26.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _buildAvatar(index, avatarRadius),
                                        const SizedBox(height: 8),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0,
                                            ),
                                            child: Text(
                                              stagiaire,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: nameFontSize,
                                                color: isExcluded
                                                    ? Colors.grey
                                                    : Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${index + 1}/${widget.stagiaires.length}",
                                          style: TextStyle(
                                            color: isExcluded
                                                ? Colors.grey[400]
                                                : Colors.grey,
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Fixed button with proper constraints
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: cardWidth - 16,
                                            minHeight: 32,
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _showEditOptions(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isExcluded
                                                  ? Colors.grey
                                                  : const Color(0xFF0D87F7),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                isExcluded ? "Exclu" : "Edit",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: blueSectionHeight - 20 + (_showSuccessMessage ? 120 : 0),
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildPresenceButton("Absent", false, !isPresent),
                        const SizedBox(width: 20),
                        _buildPresenceButton("Présent", true, isPresent),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 120,
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          TextField(
                            controller: _noteController,
                            maxLength: 60,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: "Write a note ...",
                              contentPadding: const EdgeInsets.all(16),
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 15,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.attach_file,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${_noteController.text.length}/60",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showSaveOptions) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Sauvegarder la note",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _currentNoteToSave,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _deleteNote,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Supprimer",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _cancelSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text("Annuler"),
                                ),
                                ElevatedButton(
                                  onPressed: _confirmSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D87F7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Confirmer",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: const BoxDecoration(
            color: Color(0xFF46D9BF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: const BoxDecoration(
            color: Color(0xFF05518B),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresenceButton(String label, bool value, bool isSelected) {
    final color = value ? const Color(0xFF28A745) : const Color(0xFFDC3545);
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleAttendance(value),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected
                    ? (value ? Icons.check_circle : Icons.radio_button_checked)
                    : (value ? Icons.circle_outlined : Icons.radio_button_off),
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
