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
    required this.establishmentName, // 🔹 AJOUT DANS LE CONSTRUCTEUR
  });
  @override
  State<CallingTraineeScreen> createState() => _CallingTraineeScreenState();
}

class _CallingTraineeScreenState extends State<CallingTraineeScreen> {
  int _currentIndex = 0;
  final Map<String, bool> _attendance = {};
  final Map<String, String> _notes = {};
  final TextEditingController _noteController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.32);

  @override
  void initState() {
    super.initState();
    for (var stagiaire in widget.stagiaires) {
      _attendance[stagiaire] = true;
      _notes[stagiaire] = '';
    }

    _noteController.text = _notes[widget.stagiaires[0]] ?? '';
    _noteController.addListener(() {
      _notes[widget.stagiaires[_currentIndex]] = _noteController.text;
    });

    _pageController.addListener(() {
      int? nextPage = _pageController.page?.round();
      if (nextPage != null && _currentIndex != nextPage) {
        setState(() {
          _currentIndex = nextPage;
          _noteController.text = _notes[widget.stagiaires[_currentIndex]] ?? '';
        });
      }
    });
  }

  void _toggleAttendance(bool isPresent) {
    setState(() {
      _attendance[widget.stagiaires[_currentIndex]] = isPresent;
    });
  }

  String _getAvatarAsset(int index) {
    return "assets/avatar_hajar.png";
  }

  @override
  void dispose() {
    _noteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTraineeName = widget.stagiaires[_currentIndex];
    final bool isPresent = _attendance[currentTraineeName] ?? true;
    final double blueSectionHeight = MediaQuery.of(context).size.height * 0.6;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Présence: $_attendance");
          print("Notes: $_notes");
        },
        backgroundColor: const Color(0xFF0D87F7),
        child: const Icon(Icons.save),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
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
                    // TOP BAR
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
                          const Text(
                            "9:41",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // SPECIALTY & GROUP CHIPS
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

                    // STAGIAIRE COUNTER + BUTTON
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
                          Container(
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PAGE VIEW
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 190.0,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: widget.stagiaires.length,
                            clipBehavior: Clip.none,
                            itemBuilder: (context, index) {
                              final stagiaire = widget.stagiaires[index];
                              final isFocused = index == _currentIndex;

                              final double cardWidth = isFocused
                                  ? 120.0
                                  : 100.0;
                              final double cardHeight = isFocused
                                  ? 190.0
                                  : 150.0;
                              final double avatarRadius = isFocused
                                  ? 35.0
                                  : 30.0;
                              final double nameFontSize = isFocused
                                  ? 14.0
                                  : 12.0;

                              return Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  width: cardWidth,
                                  height: cardHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: avatarRadius,
                                        backgroundImage: AssetImage(
                                          _getAvatarAsset(index),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        stagiaire,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: nameFontSize,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${index + 1}/${widget.stagiaires.length}",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0D87F7,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                        ),
                                        child: const Text("Edit"),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // WHITE SECTION - ABSENT / PRESENT + NOTE
          Positioned(
            top: blueSectionHeight - 30,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8F8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // PRESENCE BUTTONS
                    Row(
                      children: [
                        _buildPresenceButton("Absent", false, !isPresent),
                        const SizedBox(width: 20),
                        _buildPresenceButton("Présent", true, isPresent),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // NOTE ZONE
                    Flexible(
                      child: Container(
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
                    ),
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
