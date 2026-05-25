import 'package:json_annotation/json_annotation.dart';
part 'game.g.dart';

@JsonSerializable()
class Game {
  final int id;
  final int number;
  @JsonKey(name: 'to')
  final int toScore;
  final int cap;
  final int? home;
  final int? away;
  final bool isFinal;
  final dynamic winner; // nullable — can be null, string, or int
  final String? status;

  const Game({
    required this.id,
    required this.number,
    required this.toScore,
    required this.cap,
    this.home,
    this.away,
    required this.isFinal,
    this.winner,
    this.status,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);
}
