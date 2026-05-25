import 'package:json_annotation/json_annotation.dart';
import 'player.dart';
part 'team.g.dart';

@JsonSerializable()
class Team {
  final int id;
  final int teamId;
  final String? name;
  final int? seed;
  final List<Player>? players;

  const Team({
    required this.id,
    required this.teamId,
    this.name,
    this.seed,
    this.players,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);
}
