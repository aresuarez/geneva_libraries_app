import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/library_service.dart';
import '../widgets/time_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LibraryService _libraryService = LibraryService();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedDay = 'monday';
  List<dynamic> _libraries = [];
  List<dynamic> _openLibraries = [];
  bool _showCurrentTimeButton = true;
  bool _timeSelected = false;

  @override
  void initState() {
    super.initState();
    _loadLibrarySchedules();
  }

  Future<void> _loadLibrarySchedules() async {
    final libraries = await _libraryService.loadLibrarySchedules();
    setState(() {
      _libraries = libraries;
    });
  }

 void _findOpenLibraries(TimeOfDay selectedTime, String selectedDay) {
  setState(() {
    _openLibraries = _libraries.where((library) {
      final schedule = library.schedule[selectedDay];
      if (schedule == null) return false;

      return schedule.timeSlots.any((timeSlot) {
        final openTime = TimeOfDay(
          hour: int.parse(timeSlot.open.split(':')[0]),
          minute: int.parse(timeSlot.open.split(':')[1]),
        );
        final closeTime = TimeOfDay(
          hour: int.parse(timeSlot.close.split(':')[0]),
          minute: int.parse(timeSlot.close.split(':')[1]),
        );

        return selectedTime.hour >= openTime.hour &&
            selectedTime.hour < closeTime.hour;
      });
    }).toList();
  });
}

  void _onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _selectedTime = newTime;
      _timeSelected = true;
    });
    _findOpenLibraries(newTime, _selectedDay);
  }

  void _useCurrentTime() {
    final now = tz.TZDateTime.now(tz.getLocation('Europe/Zurich'));
    final selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final selectedDay = DateFormat('EEEE').format(now).toLowerCase();

    setState(() {
      _selectedTime = selectedTime;
      _selectedDay = selectedDay;
      _showCurrentTimeButton = false;
      _timeSelected = true;
    });

    _findOpenLibraries(selectedTime, selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedDay,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDay = newValue!;
                });
                _findOpenLibraries(_selectedTime, _selectedDay);
              },
              items: <String>[
                'monday',
                'tuesday',
                'wednesday',
                'thursday',
                'friday',
                'saturday',
                'sunday'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value[0].toUpperCase() + value.substring(1)),
                );
              }).toList(),
            ),
            TimeSelector(
              selectedTime: _selectedTime,
              onTimeChanged: _onTimeChanged,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _openLibraries.isEmpty && _timeSelected
                  ? Center(child: Text('No libraries open at this time.'))
                  : ListView.builder(
                      itemCount: _openLibraries.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_openLibraries[index].name),
                        );
                      },
                    ),
            ),
            if (_showCurrentTimeButton)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _useCurrentTime,
                  icon: Icon(Icons.access_time),
                  label: Text('Open right now'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}