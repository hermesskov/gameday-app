import 'package:flutter_test/flutter_test.dart';
import 'package:gameday_app/services/api_client.dart';

void main() {
  group('MockApiClient', () {
    late MockApiClient client;

    setUp(() {
      client = MockApiClient();
    });

    test('getUserSchedule returns ScheduleResponse with events', () async {
      final response = await client.getUserSchedule('2026-06-15');

      expect(response.userId, 98765);
      expect(response.date, '2026-06-15');
      expect(response.timezone, 'America/Los_Angeles');
      expect(response.events.length, 2);
    });

    test('events contain match details', () async {
      final response = await client.getUserSchedule('2026-06-15');
      final event = response.events.first;

      expect(event.type, 'match');
      expect(event.role, 'player');
      expect(event.tournamentName, 'Summer Beach Classic');
      expect(event.matchId, 81001);
      expect(event.court, '1');
      expect(event.canScore, true);
    });

    test('events have teams with players', () async {
      final response = await client.getUserSchedule('2026-06-15');
      final event = response.events.first;

      expect(event.homeTeam, isNotNull);
      expect(event.awayTeam, isNotNull);
      expect(event.homeTeam!.name, 'Cook / Smith');
      expect(event.homeTeam!.players!.length, 2);
    });

    test('events have games and liveScoring', () async {
      final response = await client.getUserSchedule('2026-06-15');
      final event = response.events.first;

      expect(event.games, isNotNull);
      expect(event.games!.length, 1);
      expect(event.games!.first.number, 1);
      expect(event.games!.first.home, 12);
      expect(event.games!.first.away, 10);

      expect(event.liveScoring, isNotNull);
      expect(event.liveScoring!.startUrl, '/matches/scoring/start');
      expect(event.liveScoring!.updateUrl, '/matches/scoring/update');
    });

    test('second event is upcoming without score', () async {
      final response = await client.getUserSchedule('2026-06-15');
      final event = response.events[1];

      expect(event.matchId, 81002);
      expect(event.status, isNull);
      expect(event.canScore, false);
      expect(event.games, isNull);
    });

    test('startScoring completes without error', () async {
      await expectLater(client.startScoring(81001), completes);
    });

    test('updateScore completes without error', () async {
      await expectLater(client.updateScore(81001, 15, 10), completes);
    });

    test('checkIn completes without error', () async {
      await expectLater(client.checkIn(45678), completes);
    });
  });
}
