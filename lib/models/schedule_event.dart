import 'package:json_annotation/json_annotation.dart';
import 'team.dart';
import 'game.dart';
import 'live_scoring.dart';
part 'schedule_event.g.dart';

@JsonSerializable()
class ScheduleEvent {
  final String type; // "match"
  final String role; // "player", "ref"
  final int tournamentId;
  final String tournamentName;
  final int divisionId;
  final String divisionName;
  final int roundId;
  final String roundName;
  final String parentType; // "pool", "bracket"
  final int parentId;
  final String parentName;
  final int matchId;
  final List<int>? gameIds;
  final int matchNumber;
  final String? court;
  final String? scheduledStartTime;
  final String? scheduledStartDisplay;
  final Team? homeTeam;
  final Team? awayTeam;
  final Team? refTeam;
  final bool isMatch;
  final String? status;
  final dynamic winner;
  final List<Game>? games;
  final bool canScore;
  final LiveScoring? liveScoring;

  const ScheduleEvent({
    required this.type,
    required this.role,
    required this.tournamentId,
    required this.tournamentName,
    required this.divisionId,
    required this.divisionName,
    required this.roundId,
    required this.roundName,
    required this.parentType,
    required this.parentId,
    required this.parentName,
    required this.matchId,
    this.gameIds,
    required this.matchNumber,
    this.court,
    this.scheduledStartTime,
    this.scheduledStartDisplay,
    this.homeTeam,
    this.awayTeam,
    this.refTeam,
    required this.isMatch,
    this.status,
    this.winner,
    this.games,
    required this.canScore,
    this.liveScoring,
  });

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) =>
      _$ScheduleEventFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleEventToJson(this);
}
