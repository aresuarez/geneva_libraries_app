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
      onPressed: () => _showDateTimePicker(context),
      child: const Text('Select Date'),
    );
  }

  void _showDateTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: DateTime.now(),
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDateTime) {
                    // Handle both date and time changes here
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}