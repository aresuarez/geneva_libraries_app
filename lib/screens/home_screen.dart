import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/library_service.dart';
import '../widgets/time_selector.dart';
import '../utils/clock.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  final LibraryService? libraryService;
  final TimeOfDay? initialTime;

  const HomeScreen({
    super.key, 
    required this.title,
    this.libraryService,
    this.initialTime,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final LibraryService _libraryService;
  late TimeOfDay _selectedTime;
  late String _selectedDay;
  List<dynamic> _libraries = [];
  List<dynamic> _openLibraries = [];
  bool _timeSelected = false;
  Timer? _updateTimer;
  bool _isLoading = true;
  String? _error;

  void _startAutoUpdates() {
    // Cancel any existing timer
    _updateTimer?.cancel();
    
    // Calculate time until next minute
    final now = Clock.now();
    final nextMinute = DateTime(now.year, now.month, now.day, 
                              now.hour, now.minute + 1);
    final delay = nextMinute.difference(now);

    // Schedule single update at next minute
    _updateTimer = Timer(delay, () {
      _updateCurrentTime();
      // Then start periodic updates
      _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        _updateCurrentTime();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _libraryService = widget.libraryService ?? LibraryService();
    _updateCurrentTime();
    _loadLibrarySchedules();
    _timeSelected = true;
    _startAutoUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _updateCurrentTime() {
    final now = Clock.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final currentDay = DateFormat('EEEE').format(now).toLowerCase();

    setState(() {
      _selectedTime = currentTime;
      _selectedDay = currentDay;
      _timeSelected = true;
    });

    _findOpenLibraries(currentTime, currentDay);
    
    // Restart auto updates when resetting to current time
    _startAutoUpdates();
  }

  Future<void> _loadLibrarySchedules() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final libraries = await _libraryService.loadLibrarySchedules();
      setState(() {
        _libraries = libraries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load library schedules';
        _isLoading = false;
      });
    }
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

        // Convert to minutes for accurate comparison
        final selectedMinutes = selectedTime.hour * 60 + selectedTime.minute;
        final openMinutes = openTime.hour * 60 + openTime.minute;
        final closeMinutes = closeTime.hour * 60 + closeTime.minute;

        // Check if the selected time falls within any time slot
        if (closeMinutes > openMinutes) {
          // Normal case (e.g., 9:00 - 17:00)
          return selectedMinutes >= openMinutes && selectedMinutes < closeMinutes;
        } else {
          // Handles case when library closes after midnight
          return selectedMinutes >= openMinutes || selectedMinutes < closeMinutes;
        }
      });
    }).toList();
  });
}

  void _onTimeChanged(TimeOfDay newTime) {
    // Stop auto updates when user manually selects time
    _updateTimer?.cancel();
    _updateTimer = null;

    setState(() {
      _selectedTime = newTime;
      _timeSelected = true;
    });
    _findOpenLibraries(newTime, _selectedDay);
  }

  void _onDayChanged(String? newValue) {
    if (newValue == null) return;
    
    // Stop auto updates when user manually selects day
    _updateTimer?.cancel();
    _updateTimer = null;

    setState(() {
      _selectedDay = newValue;
    });
    _findOpenLibraries(_selectedTime, _selectedDay);
  }

  bool _isCurrentTimeAndDay() {
    final now = Clock.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final currentDay = DateFormat('EEEE').format(now).toLowerCase();
    
    return _selectedTime.hour == currentTime.hour && 
           _selectedTime.minute == currentTime.minute &&
           _selectedDay == currentDay;
  }

  TimeOfDay? _getNextClosingTime(dynamic schedule, int selectedMinutes) {
    if (schedule == null) return null;
    
    TimeOfDay? nextClosing;
    int? closestDiff;
    
    for (final timeSlot in schedule.timeSlots) {
      final closeTime = TimeOfDay(
        hour: int.parse(timeSlot.close.split(':')[0]),
        minute: int.parse(timeSlot.close.split(':')[1]),
      );
      final closeMinutes = closeTime.hour * 60 + closeTime.minute;
      
      // Handle after-midnight case
      final adjustedCloseMinutes = closeMinutes < selectedMinutes ? 
          closeMinutes + 24 * 60 : closeMinutes;
      
      if (adjustedCloseMinutes > selectedMinutes) {
        final diff = adjustedCloseMinutes - selectedMinutes;
        if (closestDiff == null || diff < closestDiff) {
          closestDiff = diff;
          nextClosing = closeTime;
        }
      }
    }
    return nextClosing;
  }

  String _capitalizeDay(String day) {
    if (day.isEmpty) return day;
    return '${day[0].toUpperCase()}${day.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: !_isCurrentTimeAndDay()
          ? FloatingActionButton(
              onPressed: _updateCurrentTime,
              child: const Icon(Icons.restore),
            )
          : null,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: _loadLibrarySchedules,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _libraries.isEmpty
            ? const Center(child: Text('No library data available'))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: _selectedDay,
                      onChanged: _onDayChanged,
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
                          child: Text(_capitalizeDay(value)),
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
                                final library = _openLibraries[index];
                                final schedule = library.schedule[_selectedDay];
                                final selectedMinutes = _selectedTime.hour * 60 + _selectedTime.minute;
                                final nextClosing = _getNextClosingTime(schedule, selectedMinutes);

                                return ListTile(
                                  title: Text(
                                    '${library.name} - until ${nextClosing?.format(context) ?? "unknown"}',
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
    );
  }
}