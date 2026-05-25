import 'package:json_annotation/json_annotation.dart';
part 'live_scoring.g.dart';

@JsonSerializable()
class LiveScoring {
  final String startUrl;
  final String updateUrl;
  final bool keyRequired;

  const LiveScoring({
    required this.startUrl,
    required this.updateUrl,
    required this.keyRequired,
  });

  factory LiveScoring.fromJson(Map<String, dynamic> json) =>
      _$LiveScoringFromJson(json);
  Map<String, dynamic> toJson() => _$LiveScoringToJson(this);
}
