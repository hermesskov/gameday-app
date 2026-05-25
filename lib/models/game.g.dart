// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
      id: (json['id'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      toScore: (json['to'] as num).toInt(),
      cap: (json['cap'] as num).toInt(),
      home: (json['home'] as num?)?.toInt(),
      away: (json['away'] as num?)?.toInt(),
      isFinal: json['isFinal'] as bool,
      winner: json['winner'],
      status: json['status'] as String?,
    );

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'to': instance.toScore,
      'cap': instance.cap,
      'home': instance.home,
      'away': instance.away,
      'isFinal': instance.isFinal,
      'winner': instance.winner,
      'status': instance.status,
    };
