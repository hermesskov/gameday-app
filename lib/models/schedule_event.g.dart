// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleEvent _$ScheduleEventFromJson(Map<String, dynamic> json) =>
    ScheduleEvent(
      type: json['type'] as String,
      role: json['role'] as String,
      tournamentId: (json['tournamentId'] as num).toInt(),
      tournamentName: json['tournamentName'] as String,
      divisionId: (json['divisionId'] as num).toInt(),
      divisionName: json['divisionName'] as String,
      roundId: (json['roundId'] as num).toInt(),
      roundName: json['roundName'] as String,
      parentType: json['parentType'] as String,
      parentId: (json['parentId'] as num).toInt(),
      parentName: json['parentName'] as String,
      matchId: (json['matchId'] as num).toInt(),
      gameIds: (json['gameIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      matchNumber: (json['matchNumber'] as num).toInt(),
      court: json['court'] as String?,
      scheduledStartTime: json['scheduledStartTime'] as String?,
      scheduledStartDisplay: json['scheduledStartDisplay'] as String?,
      homeTeam: json['homeTeam'] == null
          ? null
          : Team.fromJson(json['homeTeam'] as Map<String, dynamic>),
      awayTeam: json['awayTeam'] == null
          ? null
          : Team.fromJson(json['awayTeam'] as Map<String, dynamic>),
      refTeam: json['refTeam'] == null
          ? null
          : Team.fromJson(json['refTeam'] as Map<String, dynamic>),
      isMatch: json['isMatch'] as bool,
      status: json['status'] as String?,
      winner: json['winner'],
      games: (json['games'] as List<dynamic>?)
          ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList(),
      canScore: json['canScore'] as bool,
      liveScoring: json['liveScoring'] == null
          ? null
          : LiveScoring.fromJson(json['liveScoring'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ScheduleEventToJson(ScheduleEvent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'role': instance.role,
      'tournamentId': instance.tournamentId,
      'tournamentName': instance.tournamentName,
      'divisionId': instance.divisionId,
      'divisionName': instance.divisionName,
      'roundId': instance.roundId,
      'roundName': instance.roundName,
      'parentType': instance.parentType,
      'parentId': instance.parentId,
      'parentName': instance.parentName,
      'matchId': instance.matchId,
      'gameIds': instance.gameIds,
      'matchNumber': instance.matchNumber,
      'court': instance.court,
      'scheduledStartTime': instance.scheduledStartTime,
      'scheduledStartDisplay': instance.scheduledStartDisplay,
      'homeTeam': instance.homeTeam,
      'awayTeam': instance.awayTeam,
      'refTeam': instance.refTeam,
      'isMatch': instance.isMatch,
      'status': instance.status,
      'winner': instance.winner,
      'games': instance.games,
      'canScore': instance.canScore,
      'liveScoring': instance.liveScoring,
    };
