import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/schedule_event.dart';
import '../services/providers.dart';
import '../services/api_client.dart';

class LiveScoreScreen extends ConsumerStatefulWidget {
  final ScheduleEvent event;

  const LiveScoreScreen({super.key, required this.event});

  @override
  ConsumerState<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends ConsumerState<LiveScoreScreen> {
  late int _scoreA;
  late int _scoreB;
  final List<_ScoreSnapshot> _history = [];
  bool _submitting = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // Initialize from existing scores if any
    if (widget.event.games != null && widget.event.games!.isNotEmpty) {
      _scoreA = widget.event.games!.first.home ?? 0;
      _scoreB = widget.event.games!.first.away ?? 0;
    } else {
      _scoreA = 0;
      _scoreB = 0;
    }

    // Start scoring session if not already started
    if (widget.event.canScore && widget.event.liveScoring != null) {
      _startScoring();
    }
  }

  Future<void> _startScoring() async {
    final api = ref.read(apiClientProvider);
    await api.startScoring(widget.event.matchId);
    setState(() => _started = true);
  }

  void _addPoint(bool teamA) {
    setState(() {
      _history.add(_ScoreSnapshot(scoreA: _scoreA, scoreB: _scoreB));
      if (teamA) {
        _scoreA++;
      } else {
        _scoreB++;
      }
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      final prev = _history.removeLast();
      _scoreA = prev.scoreA;
      _scoreB = prev.scoreB;
    });
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    try {
      final api = ref.read(apiClientProvider);
      await api.updateScore(widget.event.matchId, _scoreA, _scoreB);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score submitted!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit score. Try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String get _homeName =>
      widget.event.homeTeam?.name ?? widget.event.awayTeam?.name ?? 'Team A';
  String get _awayName =>
      widget.event.awayTeam?.name ?? widget.event.homeTeam?.name ?? 'Team B';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event.tournamentName,
          style: const TextStyle(fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Undo
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _history.isEmpty ? null : _undo,
          ),
          // Submit
          IconButton(
            icon: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check),
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
      body: Column(
        children: [
          // Court info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: theme.colorScheme.primaryDark.withOpacity(0.05),
            child: Center(
              child: Text(
                widget.event.court != null
                    ? 'Court ${widget.event.court} · Match #${widget.event.matchNumber}'
                    : 'Match #${widget.event.matchNumber}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),

          // Score area
          Expanded(
            child: Row(
              children: [
                // Team A — tap to score
                Expanded(
                  child: GestureDetector(
                    onTap: () => _addPoint(true),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: theme.colorScheme.primary.withOpacity(0.03),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_scoreA',
                            style: const TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _homeName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'tap to score',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Divider
                Container(
                  width: 1,
                  color: Colors.grey[200],
                ),

                // Team B — tap to score
                Expanded(
                  child: GestureDetector(
                    onTap: () => _addPoint(false),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: theme.colorScheme.secondary.withOpacity(0.03),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_scoreB',
                            style: const TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _awayName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'tap to score',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                // Undo button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _history.isEmpty ? null : _undo,
                    icon: const Icon(Icons.undo, size: 20),
                    label: const Text('UNDO'),
                  ),
                ),
                const SizedBox(width: 12),
                // Submit button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 20),
                    label: Text(_submitting ? 'SUBMITTING...' : 'SUBMIT SCORE'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreSnapshot {
  final int scoreA;
  final int scoreB;

  const _ScoreSnapshot({required this.scoreA, required this.scoreB});
}
