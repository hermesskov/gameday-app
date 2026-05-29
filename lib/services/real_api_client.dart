import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule_response.dart';
import '../models/schedule_event.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/live_scoring.dart';
import 'api_client.dart';

/// Production API client — no auth, public endpoints only.
///
/// Endpoints:
///   - GET  /Event                        → public tournament list
///   - POST /matches/scoring/start        → begin live scoring
///   - POST /matches/scoring/update       → push a score update
class RealApiClient implements ApiClient {
  static const _baseUrl = 'https://api.volleyballlife.com/api/v1.0';
  static const _prod2Url = 'https://api-v8.volleyballlife.com';

  final http.Client _client;

  RealApiClient({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // ---- PUBLIC EVENTS ----

  @override
  Future<ScheduleResponse> getPublicEvents() async {
    // GET /Event — VBL API uses [FromBody] on GET, which in .NET 8+ 
    // can read from query string. Send as URL query params.
    final url = Uri.parse('$_baseUrl/Event').replace(queryParameters: {
      'type': '',
      'organizationIds': '[]',
      'statusIds': '[]',
    });

    final response = await _client.get(url, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch events: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return _parseEventResponse(data, response.statusCode);
  }

  ScheduleResponse _parseEventResponse(dynamic data, int statusCode) {
    if (data is List) {
      // /Event returns a flat list of tournament summaries
      return ScheduleResponse(
        userId: 0,
        date: '',
        timezone: 'America/Los_Angeles',
        events: data.map((e) => _parseTournamentSummary(e)).toList(),
      );
    }
    if (data is Map<String, dynamic>) {
      final events = (data['events'] as List<dynamic>?)
          ?.map((e) => _parseTournamentSummary(e))
          .toList() ?? [];
      return ScheduleResponse(
        userId: data['userId'] as int? ?? 0,
        date: data['date'] as String? ?? '',
        timezone: data['timezone'] as String? ?? 'America/Los_Angeles',
        events: events,
      );
    }
    throw ApiException('Unexpected /Event response format');
  }

  ScheduleEvent _parseTournamentSummary(dynamic t) {
    final m = t as Map<String, dynamic>;
    final name = m['name'] as String? ?? m['tournamentName'] as String? ?? '';
    final id = m['id'] as int? ?? m['tournamentId'] as int? ?? 0;

    return ScheduleEvent(
      type: 'tournament',
      role: 'viewer',
      tournamentId: id,
      tournamentName: name,
      divisionId: m['divisionId'] as int? ?? 0,
      divisionName: m['divisionName'] as String? ?? '',
      roundId: 0,
      roundName: '',
      parentType: '',
      parentId: 0,
      parentName: '',
      matchId: 0,
      matchNumber: 0,
      court: '',
      scheduledStartTime: m['startDate'] as String? ?? '',
      scheduledStartDisplay: m['startDateDisplay'] as String? ?? '',
      homeTeam: Team(id: 0, teamId: 0, name: '', players: []),
      awayTeam: Team(id: 0, teamId: 0, name: '', players: []),
      isMatch: false,
      canScore: false,
    );
  }

  // ---- SCORING (public, no auth) ----

  @override
  Future<void> startScoring(int matchId) async {
    final url = Uri.parse('$_baseUrl/matches/scoring/start');
    final body = jsonEncode({
      'name': matchId.toString(),
      'role': 'scorer',
      'match': {'id': matchId},
      'key': null,
    });

    final response = await _client.post(url, headers: _headers, body: body);
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

    final url = Uri.parse(
        '$_baseUrl/matches/scoring/update?key=&timestamp=${DateTime.now().millisecondsSinceEpoch}');
    final response = await _client.post(url, headers: _headers, body: dto);
    if (response.statusCode != 200) {
      throw ApiException('Failed to update score: ${response.statusCode}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}
