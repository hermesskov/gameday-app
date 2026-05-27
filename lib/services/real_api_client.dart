import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule_response.dart';
import '../models/schedule_event.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/live_scoring.dart';
import 'api_client.dart';
import 'real_auth_service.dart';

/// Production API client for volleyballlife.com.
///
/// Endpoints mapped from the VBL frontend SDK (src/VBL/):
///   - GET  /Me/upcoming-events  → user's schedule
///   - POST /matches/scoring/start → begin live scoring
///   - POST /matches/scoring/update → push a score update
///   - POST /Team/OnlineCheckin     → check in to a tournament
class RealApiClient implements ApiClient {
  static const _baseUrl = 'https://api-v8.volleyballlife.com';
  static const _apiPrefix = '/api/v1.0';

  final http.Client _client;
  final RealAuthService _auth;
  final bool _usePrefix;

  RealApiClient(this._auth, {http.Client? client, bool usePrefix = true})
      : _client = client ?? http.Client(),
        _usePrefix = usePrefix;

  String get _api => _usePrefix ? '$_baseUrl$_apiPrefix' : _baseUrl;

  Map<String, String> _headers([String? token]) {
    final t = token ?? _auth.authToken;
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  // ---- SCHEDULE ----

  @override
  Future<ScheduleResponse> getUserSchedule(String date) async {
    final url = Uri.parse('$_api/Me/upcoming-events')
        .replace(queryParameters: {'date': date});

    final response = await _client.get(url, headers: _headers());
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch schedule: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return _parseScheduleResponse(data);
  }

  // ---- SCORING ----

  @override
  Future<void> startScoring(int matchId) async {
    final url = Uri.parse('$_api/matches/scoring/start');
    final body = jsonEncode({
      'name': matchId.toString(),
      'role': 'scorer',
      'match': {'id': matchId},
      'key': null,
    });

    final response = await _client.post(url, headers: _headers(), body: body);
    if (response.statusCode != 200) {
      throw ApiException('Failed to start scoring: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateScore(int matchId, int home, int away) async {
    final dto = jsonEncode({
      'match': {
        'id': matchId,
        'games': [
          {
            'number': 1,
            'home': home,
            'away': away,
          }
        ],
      },
      'key': null,
    });

    // Scoring key check first (keycheck is POST, returns bool)
    final keyCheckUrl = Uri.parse(
        '$_api/matches/scoring/keycheck?key=&id=$matchId');
    try {
      await _client.post(keyCheckUrl, headers: _headers());
    } catch (_) {
      // keycheck is best-effort; scoring can work without it
    }

    final url = Uri.parse(
        '$_api/matches/scoring/update?key=&timestamp=${DateTime.now().millisecondsSinceEpoch}');
    final response = await _client.post(url, headers: _headers(), body: dto);
    if (response.statusCode != 200) {
      throw ApiException('Failed to update score: ${response.statusCode}');
    }
  }

  // ---- CHECK-IN ----

  @override
  Future<void> checkIn(int tournamentId) async {
    final url = Uri.parse('$_api/Team/OnlineCheckin');
    final body = jsonEncode({'tournamentId': tournamentId});
    final response =
        await _client.post(url, headers: _headers(), body: body);
    if (response.statusCode != 200) {
      throw ApiException('Failed to check in: ${response.statusCode}');
    }
  }

  // ---- PARSE HELPERS ----

  ScheduleResponse _parseScheduleResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected schedule response format');
    }

    // Map the VBL API response shape to our ScheduleResponse model
    // The VBL API returns events under 'events' or directly as array
    final List<dynamic> rawEvents = data['events'] as List<dynamic>? ?? [];
    final events = rawEvents.map((e) => _parseEvent(e)).toList();

    return ScheduleResponse(
      userId: data['userId'] as int? ?? data['user_id'] as int? ?? 0,
      date: data['date'] as String? ?? '',
      timezone: data['timezone'] as String? ?? 'America/Los_Angeles',
      events: events,
    );
  }

  ScheduleEvent _parseEvent(dynamic e) {
    final m = e as Map<String, dynamic>;
    final team = m['team'] as Map<String, dynamic>?;
    final opponent = m['opponent'] as Map<String, dynamic>?;
    final match = m['match'] as Map<String, dynamic>?;

    return ScheduleEvent(
      type: m['type'] as String? ?? 'match',
      role: m['role'] as String? ?? 'player',
      tournamentId: m['tournamentId'] as int? ?? m['tournament_id'] as int? ?? 0,
      tournamentName:
          m['tournamentName'] as String? ?? m['name'] as String? ?? '',
      divisionId: m['divisionId'] as int? ?? m['division_id'] as int? ?? 0,
      divisionName:
          m['divisionName'] as String? ?? m['division_name'] as String? ?? '',
      roundId: m['roundId'] as int? ?? m['round_id'] as int? ?? 0,
      roundName: m['roundName'] as String? ?? '',
      parentType: m['parentType'] as String? ?? '',
      parentId: m['parentId'] as int? ?? m['parent_id'] as int? ?? 0,
      parentName: m['parentName'] as String? ?? '',
      matchId: m['matchId'] as int? ?? m['match_id'] as int? ?? match?['id'] as int? ?? 0,
      matchNumber: m['matchNumber'] as int? ?? m['number'] as int? ?? 0,
      court: m['court'] as String? ?? m['court_id'] as String? ?? '',
      scheduledStartTime: m['scheduledStartTime'] as String? ?? m['start_time'] as String? ?? '',
      scheduledStartDisplay:
          m['scheduledStartDisplay'] as String? ?? m['start_display'] as String? ?? '',
      homeTeam: _parseTeam(team ?? m['homeTeam'] as Map<String, dynamic>? ?? {}),
      awayTeam:
          _parseTeam(opponent ?? m['awayTeam'] as Map<String, dynamic>? ?? {}),
      isMatch: m['isMatch'] as bool? ?? true,
      status: m['status'] as String?,
      games: _parseGames(m['games'] as List<dynamic>?),
      canScore: m['canScore'] as bool? ?? false,
      liveScoring: LiveScoring(
        startUrl: m['scoring']?['startUrl'] as String? ?? '/matches/scoring/start',
        updateUrl: m['scoring']?['updateUrl'] as String? ?? '/matches/scoring/update',
        keyRequired: m['scoring']?['keyRequired'] as bool? ?? false,
      ),
    );
  }

  Team _parseTeam(Map<String, dynamic> t) {
    return Team(
      id: t['id'] as int? ?? 0,
      teamId: t['teamId'] as int? ?? t['team_id'] as int? ?? 0,
      name: t['name'] as String? ?? '',
      players: _parsePlayers(t['players'] as List<dynamic>?),
    );
  }

  List<Player> _parsePlayers(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((p) {
      final m = p as Map<String, dynamic>;
      return Player(
        id: m['id'] as int? ?? 0,
        firstName: m['firstName'] as String? ?? m['first_name'] as String? ?? '',
        lastName: m['lastName'] as String? ?? m['last_name'] as String? ?? '',
        name: m['name'] as String? ?? '',
      );
    }).toList();
  }

  List<Game> _parseGames(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((g) {
      final m = g as Map<String, dynamic>;
      return Game(
        id: m['id'] as int? ?? 0,
        number: m['number'] as int? ?? 0,
        toScore: m['toScore'] as int? ?? m['to_score'] as int? ?? 21,
        cap: m['cap'] as int? ?? 23,
        home: m['home'] as int? ?? 0,
        away: m['away'] as int? ?? 0,
        isFinal: m['isFinal'] as bool? ?? m['final'] as bool? ?? false,
      );
    }).toList();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}
