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
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _libraryService = widget.libraryService ?? LibraryService();
    // Load libraries once when app starts
    _loadLibrarySchedules();
    // Initialize time selection after libraries start loading
    _initializeTimeSelection();
  }

  void _initializeTimeSelection() {
    final now = Clock.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final currentDay = DateFormat('EEEE').format(now).toLowerCase();

    setState(() {
      _selectedTime = currentTime;
      _selectedDay = currentDay;
    });
  }

  void _updateCurrentTime() {
    final now = Clock.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final currentDay = DateFormat('EEEE').format(now).toLowerCase();

    setState(() {
      _selectedTime = currentTime;
      _selectedDay = currentDay;
      _timeSelected = false;
      _openLibraries = [];
    });

    if (!_isLoading && _libraries.isNotEmpty && _error == null) {
      _findOpenLibraries(currentTime, currentDay);
      setState(() {
        _timeSelected = true;
      });
    }
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

        // Check if this is a midnight-crossing schedule
        // This happens when the closing time is earlier than opening time
        // For example: opens at 22:00 and closes at 02:00
        final isMidnightCrossing = closeTime.hour < openTime.hour || 
            (closeTime.hour == openTime.hour && closeTime.minute < openTime.minute);

        if (isMidnightCrossing) {
          // For midnight-crossing schedules, we need to check if the time is
          // either after opening time OR before closing time
          return selectedMinutes >= openMinutes || selectedMinutes < closeMinutes;
        } else {
          // For normal schedules, time must be between opening and closing
          return selectedMinutes >= openMinutes && selectedMinutes < closeMinutes;
        }
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

  void _onDayChanged(String? newValue) {
    if (newValue == null) return;
    
    setState(() {
      _selectedDay = newValue;
    });
    _findOpenLibraries(_selectedTime, _selectedDay);
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
      final openTime = TimeOfDay(
        hour: int.parse(timeSlot.open.split(':')[0]),
        minute: int.parse(timeSlot.open.split(':')[1]),
      );
      
      final closeMinutes = closeTime.hour * 60 + closeTime.minute;
      final openMinutes = openTime.hour * 60 + openTime.minute;
      
      // Determine if this slot crosses midnight
      final isNextDayClosing = closeMinutes < openMinutes;
      
      // Calculate the difference between closing time and selected time
      int diff;
      if (isNextDayClosing) {
        // For slots crossing midnight, we need to handle two cases:
        if (selectedMinutes >= openMinutes) {
          // Case 1: Selected time is after opening (same day)
          diff = (closeMinutes + 24 * 60) - selectedMinutes;
        } else if (selectedMinutes < closeMinutes) {
          // Case 2: Selected time is after midnight but before closing
          diff = closeMinutes - selectedMinutes;
        } else {
          // Selected time is outside the slot
          continue;
        }
      } else {
        // Normal case (same day slot)
        if (selectedMinutes > closeMinutes || selectedMinutes < openMinutes) {
          // Selected time is outside the slot
          continue;
        }
        diff = closeMinutes - selectedMinutes;
      }
      
      // Update the next closing time if this is the closest one
      if (diff >= 0 && (closestDiff == null || diff < closestDiff)) {
        closestDiff = diff;
        nextClosing = closeTime;
      }
    }
    
    return nextClosing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateCurrentTime,
        tooltip: 'Reset to current time',
        child: const Icon(Icons.restore),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
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
                    TimeSelector(
                      selectedTime: _selectedTime,
                      selectedDay: _selectedDay,
                      onTimeChanged: _onTimeChanged,
                      onDayChanged: (day) => _onDayChanged(day),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _openLibraries.isEmpty && _timeSelected
                          ? const Center(child: Text('No libraries open at this time.'))
                          : ListView.builder(
                              itemCount: _openLibraries.length,
                              itemBuilder: (context, index) {
                                final library = _openLibraries[index];
                                final schedule = library.schedule[_selectedDay];
                                final selectedMinutes = _selectedTime.hour * 60 + _selectedTime.minute;
                                final nextClosing = _getNextClosingTime(schedule, selectedMinutes);

                                return ListTile(
                                  title: Text(
                                    '${library.name} - until ${nextClosing != null ? MaterialLocalizations.of(context).formatTimeOfDay(nextClosing, alwaysUse24HourFormat: true) : "unknown"}',
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