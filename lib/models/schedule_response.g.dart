// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleResponse _$ScheduleResponseFromJson(Map<String, dynamic> json) =>
    ScheduleResponse(
      userId: (json['userId'] as num).toInt(),
      date: json['date'] as String,
      timezone: json['timezone'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => ScheduleEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScheduleResponseToJson(ScheduleResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'date': instance.date,
      'timezone': instance.timezone,
      'events': instance.events,
    };
