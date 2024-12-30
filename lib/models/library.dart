class Library {
  final String name;
  final Map<String, Schedule?> schedule;

  Library({required this.name, required this.schedule});

  factory Library.fromJson(Map<String, dynamic> json) {
    final scheduleJson = json['schedule'] as Map<String, dynamic>;
    return Library(
      name: json['name'],
      schedule: Map<String, Schedule?>.from(
        scheduleJson.map((key, value) => MapEntry(
              key,
              value != null ? Schedule.fromJson(value) : null,
            )),
      ),
    );
  }

  @override
  String toString() => 'Library(name: $name, schedule: $schedule)';
}

class Schedule {
  final List<TimeSlot> timeSlots;

  Schedule({required this.timeSlots});

  factory Schedule.fromJson(dynamic json) {
    if (json is List) {
      return Schedule(
        timeSlots: json.map((slot) => TimeSlot.fromJson(slot)).toList(),
      );
    } else if (json is Map<String, dynamic>) {
      // Handle legacy format with single time slot
      return Schedule(
        timeSlots: [TimeSlot(open: json['open'], close: json['close'])],
      );
    }
    throw FormatException('Invalid schedule format');
  }

  @override
  String toString() => 'Schedule(timeSlots: $timeSlots)';
}

class TimeSlot {
  final String open;
  final String close;

  TimeSlot({required this.open, required this.close});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      open: json['open'] as String,
      close: json['close'] as String,
    );
  }

  @override
  String toString() => 'TimeSlot(open: $open, close: $close)';
}