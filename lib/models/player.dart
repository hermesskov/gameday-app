import 'package:json_annotation/json_annotation.dart';
part 'player.g.dart';

@JsonSerializable()
class Player {
  final int id;
  final int? ppId;
  final String firstName;
  final String lastName;
  final String? name;
  final String? profilePic;
  final String? jersey;

  const Player({
    required this.id,
    this.ppId,
    required this.firstName,
    required this.lastName,
    this.name,
    this.profilePic,
    this.jersey,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
