// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LibraryImpl _$$LibraryImplFromJson(Map<String, dynamic> json) =>
    _$LibraryImpl(
      name: json['name'] as String,
      schedule: (json['schedule'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, const ScheduleConverter().fromJson(e)),
      ),
    );

Map<String, dynamic> _$$LibraryImplToJson(_$LibraryImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'schedule': instance.schedule
          .map((k, e) => MapEntry(k, const ScheduleConverter().toJson(e))),
    };

_$TimeSlotImpl _$$TimeSlotImplFromJson(Map<String, dynamic> json) =>
    _$TimeSlotImpl(
      open: json['open'] as String,
      close: json['close'] as String,
    );

Map<String, dynamic> _$$TimeSlotImplToJson(_$TimeSlotImpl instance) =>
    <String, dynamic>{
      'open': instance.open,
      'close': instance.close,
    };
