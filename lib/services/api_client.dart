import '../models/schedule_response.dart';
import '../models/schedule_event.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/live_scoring.dart';

/// Public API client. No auth — calls VBL public endpoints directly.
abstract class ApiClient {
  Future<ScheduleResponse> getPublicEvents();
  Future<void> startScoring(int matchId);
  Future<void> updateScore(int matchId, int home, int away);
}
