// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      id: (json['id'] as num).toInt(),
      ppId: (json['ppId'] as num?)?.toInt(),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      name: json['name'] as String?,
      profilePic: json['profilePic'] as String?,
      jersey: json['jersey'] as String?,
    );

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'ppId': instance.ppId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'name': instance.name,
      'profilePic': instance.profilePic,
      'jersey': instance.jersey,
    };
