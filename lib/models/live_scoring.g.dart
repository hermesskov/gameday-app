// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_scoring.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveScoring _$LiveScoringFromJson(Map<String, dynamic> json) => LiveScoring(
      startUrl: json['startUrl'] as String,
      updateUrl: json['updateUrl'] as String,
      keyRequired: json['keyRequired'] as bool,
    );

Map<String, dynamic> _$LiveScoringToJson(LiveScoring instance) =>
    <String, dynamic>{
      'startUrl': instance.startUrl,
      'updateUrl': instance.updateUrl,
      'keyRequired': instance.keyRequired,
    };
