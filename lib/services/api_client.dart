import '../models/schedule_response.dart';
import '../models/schedule_event.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/live_scoring.dart';

/// Abstract API client. Real implementation hits volleyballlife.com REST API.
/// Mock implementation returns test data for development.
abstract class ApiClient {
  Future<ScheduleResponse> getUserSchedule(String date);
  Future<void> startScoring(int matchId);
  Future<void> updateScore(int matchId, int home, int away);
  Future<void> checkIn(int tournamentId);
}

class MockApiClient implements ApiClient {
  @override
  Future<ScheduleResponse> getUserSchedule(String date) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return ScheduleResponse(
      userId: 98765,
      date: date,
      timezone: 'America/Los_Angeles',
      events: [
        ScheduleEvent(
          type: 'match',
          role: 'player',
          tournamentId: 45678,
          tournamentName: 'Summer Beach Classic',
          divisionId: 101,
          divisionName: "Women's Open",
          roundId: 1,
          roundName: 'Day 1',
          parentType: 'pool',
          parentId: 201,
          parentName: 'Pool 1',
          matchId: 81001,
          matchNumber: 1,
          court: '1',
          scheduledStartTime: '2026-06-15T16:00:00Z',
          scheduledStartDisplay: '9:00 AM',
          homeTeam: Team(
            id: 301, teamId: 301, name: 'Cook / Smith',
            players: [
              Player(id: 1, firstName: 'Karissa', lastName: 'Cook', name: 'Karissa Cook'),
              Player(id: 2, firstName: 'Alex', lastName: 'Smith', name: 'Alex Smith'),
            ],
          ),
          awayTeam: Team(
            id: 302, teamId: 302, name: 'Nguyen / Patel',
            players: [
              Player(id: 3, firstName: 'Mai', lastName: 'Nguyen', name: 'Mai Nguyen'),
              Player(id: 4, firstName: 'Priya', lastName: 'Patel', name: 'Priya Patel'),
            ],
          ),
          isMatch: true,
          status: 'Started',
          games: [
            Game(id: 91001, number: 1, toScore: 21, cap: 23, home: 12, away: 10, isFinal: false),
          ],
          canScore: true,
          liveScoring: LiveScoring(
            startUrl: '/matches/scoring/start',
            updateUrl: '/matches/scoring/update',
            keyRequired: true,
          ),
        ),
        ScheduleEvent(
          type: 'match',
          role: 'player',
          tournamentId: 45678,
          tournamentName: 'Summer Beach Classic',
          divisionId: 101,
          divisionName: "Women's Open",
          roundId: 1,
          roundName: 'Day 1',
          parentType: 'pool',
          parentId: 202,
          parentName: 'Pool 2',
          matchId: 81002,
          matchNumber: 2,
          court: '2',
          scheduledStartTime: '2026-06-15T18:00:00Z',
          scheduledStartDisplay: '11:00 AM',
          homeTeam: Team(
            id: 303, teamId: 303, name: 'Johnson / Lee',
            players: [
              Player(id: 5, firstName: 'Tara', lastName: 'Johnson', name: 'Tara Johnson'),
              Player(id: 6, firstName: 'Sue', lastName: 'Lee', name: 'Sue Lee'),
            ],
          ),
          awayTeam: Team(
            id: 304, teamId: 304, name: 'Garcia / Brown',
            players: [
              Player(id: 7, firstName: 'Elena', lastName: 'Garcia', name: 'Elena Garcia'),
              Player(id: 8, firstName: 'Kate', lastName: 'Brown', name: 'Kate Brown'),
            ],
          ),
          isMatch: true,
          status: null,
          canScore: false,
        ),
      ],
    );
  }

  @override
  Future<void> startScoring(int matchId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // TODO: POST to /matches/scoring/start
  }

  @override
  Future<void> updateScore(int matchId, int home, int away) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // TODO: POST to /matches/scoring/update
  }

  @override
  Future<void> checkIn(int tournamentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: POST to /api/me/checkin
  }
}
