import 'package:freezed_annotation/freezed_annotation.dart';

part 'library.freezed.dart';
part 'library.g.dart';

class ScheduleConverter implements JsonConverter<Schedule, dynamic> {
  const ScheduleConverter();

  @override
  Schedule fromJson(dynamic json) {
    if (json == null) return const Schedule(timeSlots: []);
    if (json is List) {
      return Schedule(
        timeSlots: json
            .map((slot) => TimeSlot.fromJson(slot as Map<String, dynamic>))
            .toList(),
      );
    }
    return const Schedule(timeSlots: []);
  }

  @override
  dynamic toJson(Schedule schedule) => schedule.timeSlots;
}

@freezed
class Library with _$Library {
  const factory Library({
    required String name,
    @ScheduleConverter()
    required Map<String, Schedule> schedule,
  }) = _Library;

  factory Library.fromJson(Map<String, dynamic> json) => _$LibraryFromJson(json);
}

@freezed
class Schedule with _$Schedule {
  const factory Schedule({
    required List<TimeSlot> timeSlots,
  }) = _Schedule;
}

@freezed
class TimeSlot with _$TimeSlot {
  const factory TimeSlot({
    required String open,
    required String close,
  }) = _TimeSlot;

  factory TimeSlot.fromJson(Map<String, dynamic> json) => _$TimeSlotFromJson(json);
}