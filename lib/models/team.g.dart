// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
      id: (json['id'] as num).toInt(),
      teamId: (json['teamId'] as num).toInt(),
      name: json['name'] as String?,
      seed: (json['seed'] as num?)?.toInt(),
      players: (json['players'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'name': instance.name,
      'seed': instance.seed,
      'players': instance.players,
    };
