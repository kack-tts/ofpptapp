import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final DeviceCalendarPlugin _calendarPlugin;
  List<Event> _events = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;

  final Map<String, int> _summaryData = {
    'Absences': 3,
    'Présences': 10,
    'Dirigé': 4,
  };

  final Map<String, IconData> _summaryIcons = {
    'Absences': Icons.cancel,
    'Présences': Icons.check_circle,
    'Dirigé': Icons.group,
  };

  final Map<String, Color> _summaryColors = {
    'Absences': Colors.redAccent,
    'Présences': Colors.green,
    'Dirigé': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _calendarPlugin = DeviceCalendarPlugin();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    tz.initializeTimeZones();
    await _requestPermissionsAndLoad();
  }

  Future<void> _requestPermissionsAndLoad() async {
    setState(() => _isLoading = true);
    try {
      final status = await Permission.calendar.request();
      if (!status.isGranted) return;

      final calendarsResult = await _calendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data!.isEmpty) return;

      final calendarId = calendarsResult.data!.first.id!;
      final now = DateTime.now();
      final eventsResult = await _calendarPlugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(
          startDate: now.subtract(const Duration(days: 30)),
          endDate: now.add(const Duration(days: 30)),
        ),
      );

      if (eventsResult.isSuccess) {
        setState(() => _events = List<Event>.from(eventsResult.data ?? []));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddEventDialog() async {
    final titleController = TextEditingController();
    DateTime selectedDate = _selectedDay ?? DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Ajouter un événement"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Titre",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text("Date"),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setStateDialog(() => selectedDate = pickedDate);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Le titre est requis")),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                child: const Text("Ajouter"),
              ),
            ],
          );
        },
      ),
    );

    if (result != true) return;

    setState(() => _isLoading = true);
    try {
      final calendarsResult = await _calendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data!.isEmpty) return;

      final calendarId = calendarsResult.data!.first.id!;
      final local = tz.getLocation('Europe/Paris');

      final newEvent = Event(calendarId)
        ..title = titleController.text.trim()
        ..start = tz.TZDateTime.from(selectedDate, local)
        ..end = tz.TZDateTime.from(
          selectedDate.add(const Duration(hours: 1)),
          local,
        );

      final createResult = await _calendarPlugin.createOrUpdateEvent(newEvent);
      if (!createResult!.isSuccess || createResult.data!.isEmpty) return;

      await _refreshEvents(calendarId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Événement ajouté avec succès")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshEvents(String calendarId) async {
    final eventsResult = await _calendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 30)),
      ),
    );

    if (eventsResult.isSuccess) {
      setState(() => _events = List<Event>.from(eventsResult.data ?? []));
    }
  }

  Future<void> _deleteEvent(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer l'événement"),
        content: const Text("Voulez-vous vraiment supprimer cet événement ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final deleteResult = await _calendarPlugin.deleteEvent(
        event.calendarId!,
        event.eventId!,
      );

      if (deleteResult.isSuccess && deleteResult.data == true) {
        setState(() => _events.remove(event));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Événement supprimé avec succès")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: _summaryData.entries.map((entry) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _summaryColors[entry.key],
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_summaryIcons[entry.key], size: 30, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${entry.value}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return const Center(
        child: Text("Aucun événement trouvé", style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (_, index) {
        final event = _events[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const Icon(Icons.event, color: Colors.blue),
            title: Text(
              event.title ?? "Sans titre",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(event.start?.toLocal() ?? DateTime.now()),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteEvent(event),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          title: const Text("Admin"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.summarize), text: "Résumé"),
              Tab(icon: Icon(Icons.edit), text: "Édition"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                _buildSummaryCards(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        headerPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        weekendTextStyle: TextStyle(color: Colors.red.shade400),
                      ),
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(child: _buildEventList()),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showAddEventDialog,
                      icon: const Icon(Icons.add),
                      label: const Text("Ajouter un événement"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Center(
              child: Text(
                "Interface d'édition à implémenter",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
