import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final TimeOfDay selectedTime;
  final String selectedDay;
  final Function(TimeOfDay) onTimeChanged;
  final Function(String) onDayChanged;

  const TimeSelector({
    super.key,
    required this.selectedTime,
    required this.selectedDay,
    required this.onTimeChanged,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showPicker(context),
      child: const Text('Select Date'),
    );
  }

  void _showPicker(BuildContext context) {
    final List<String> days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    // Generate hours (0-23)
    final List<String> hours = List.generate(24, (index) {
      return index.toString().padLeft(2, '0');
    });

    // Generate minutes (0-59)
    final List<String> minutes = List.generate(60, (index) {
      return index.toString().padLeft(2, '0');
    });

    // Initialize state variables
    int selectedDayIndex = days.indexOf(selectedDay.toLowerCase());
    int selectedHourIndex = selectedTime.hour;
    int selectedMinuteIndex = selectedTime.minute;

    // Validate and set default day if not found
    if (selectedDayIndex == -1) {
      selectedDayIndex = 0; // Default to Monday
    }

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: 300,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: const Text('Confirm'),
                      onPressed: () {
                        onDayChanged(days[selectedDayIndex]);
                        onTimeChanged(TimeOfDay(
                          hour: selectedHourIndex,
                          minute: selectedMinuteIndex,
                        ));
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedDayIndex,
                          ),
                          itemExtent: 32,
                          onSelectedItemChanged: (int index) {
                            selectedDayIndex = index;
                          },
                          children: days.map((day) {
                            return Center(
                              child: Text(
                                '${day[0].toUpperCase()}${day.substring(1)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedHourIndex,
                          ),
                          itemExtent: 32,
                          onSelectedItemChanged: (int index) {
                            selectedHourIndex = index;
                          },
                          children: hours.map((hour) {
                            return Center(
                              child: Text(
                                hour,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedMinuteIndex,
                          ),
                          itemExtent: 32,
                          onSelectedItemChanged: (int index) {
                            selectedMinuteIndex = index;
                          },
                          children: minutes.map((minute) {
                            return Center(
                              child: Text(
                                minute,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}