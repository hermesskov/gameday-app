import 'package:json_annotation/json_annotation.dart';
import 'schedule_event.dart';
part 'schedule_response.g.dart';

@JsonSerializable()
class ScheduleResponse {
  final int userId;
  final String date;
  final String timezone;
  final List<ScheduleEvent> events;

  const ScheduleResponse({
    required this.userId,
    required this.date,
    required this.timezone,
    required this.events,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$ScheduleResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleResponseToJson(this);
}
