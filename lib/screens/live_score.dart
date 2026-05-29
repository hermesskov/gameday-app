import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/schedule_event.dart';
import '../services/real_api_client.dart';

/// Tracks scores for a single set/game.
class _SetScore {
  final int number;
  final int home;
  final int away;
  final bool isFinal;

  const _SetScore({
    required this.number,
    required this.home,
    required this.away,
    this.isFinal = false,
  });

  bool get isComplete =>
      isFinal || _hasWinningScore(home, away) || _hasWinningScore(away, home);

  _SetScore copyWith({int? home, int? away, bool? isFinal}) {
    return _SetScore(
      number: number,
      home: home ?? this.home,
      away: away ?? this.away,
      isFinal: isFinal ?? this.isFinal,
    );
  }

  static bool _hasWinningScore(int a, int b) {
    return a >= 25 && a - b >= 2 || a >= 30;
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'home': home,
        'away': away,
      };
}

class LiveScoreScreen extends StatefulWidget {
  final ScheduleEvent event;

  const LiveScoreScreen({super.key, required this.event});

  @override
  State<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends State<LiveScoreScreen> {
  final _api = RealApiClient();
  /// Completed sets — added when a set ends.
  final List<_SetScore> _completedSets = [];

  /// Current set being played.
  late _SetScore _currentSet;

  /// Undo history for the current set only (cross-set undo is too complex).
  final List<_SetScore> _history = [];

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentSet = _SetScore(
      number: 1,
      home: widget.event.games?.isNotEmpty == true
          ? widget.event.games!.first.home ?? 0
          : 0,
      away: widget.event.games?.isNotEmpty == true
          ? widget.event.games!.first.away ?? 0
          : 0,
    );

    if (widget.event.canScore && widget.event.liveScoring != null) {
      _startScoring();
    }
  }

  Future<void> _startScoring() async {
    try {
      await _api.startScoring(widget.event.matchId);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not start scoring session.');
    }
  }

  void _addPointHome() => _addPoint(true);
  void _addPointAway() => _addPoint(false);

  void _addPoint(bool home) {
    setState(() {
      _history.add(_currentSet);
      if (home) {
        _currentSet = _currentSet.copyWith(home: _currentSet.home + 1);
      } else {
        _currentSet = _currentSet.copyWith(away: _currentSet.away + 1);
      }
    });
  }

  void _subtractPointHome() => _subtractPoint(true);
  void _subtractPointAway() => _subtractPoint(false);

  void _subtractPoint(bool home) {
    if (home && _currentSet.home <= 0) return;
    if (!home && _currentSet.away <= 0) return;

    setState(() {
      _history.add(_currentSet);
      if (home) {
        _currentSet = _currentSet.copyWith(home: _currentSet.home - 1);
      } else {
        _currentSet = _currentSet.copyWith(away: _currentSet.away - 1);
      }
    });
  }

  void _undoCurrentSet() {
    if (_history.isEmpty) return;
    setState(() {
      _currentSet = _history.removeLast();
    });
  }

  /// Advance to the next set when current set is complete.
  void _nextSet() {
    final finalSet = _currentSet.copyWith(isFinal: true);
    setState(() {
      _completedSets.add(finalSet);
      _history.clear();
      _currentSet = _SetScore(
        number: _currentSet.number + 1,
        home: 0,
        away: 0,
      );
    });
  }

  bool get _isMatchComplete {
    // Best-of-3: first to 2 sets
    int homeWon = 0;
    int awayWon = 0;
    for (final s in _completedSets) {
      if (s.home > s.away) homeWon++;
      else if (s.away > s.home) awayWon++;
    }
    return homeWon >= 2 || awayWon >= 2;
  }

  int get _homeSetsWon =>
      _completedSets.where((s) => s.home > s.away).length;
  int get _awaySetsWon =>
      _completedSets.where((s) => s.away > s.home).length;

  bool get _showNextSetDialog =>
      _currentSet.isComplete && !_isMatchComplete;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await _api.updateScore(widget.event.matchId, _currentSet.home, _currentSet.away);

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
      widget.event.homeTeam?.name ?? widget.event.awayTeam?.name ?? 'Home';
  String get _awayName =>
      widget.event.awayTeam?.name ?? widget.event.homeTeam?.name ?? 'Away';

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
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _history.isEmpty ? null : _undoCurrentSet,
          ),
          IconButton(
            icon: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check),
            tooltip: 'Submit score',
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
      body: Column(
        children: [
          // Match info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            child: Center(
              child: Text(
                '${widget.event.divisionName} · '
                '${widget.event.court != null ? "Court ${widget.event.court} · " : ""}'
                'Match #${widget.event.matchNumber}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
          ),

          // Set indicator tabs
          _SetIndicator(
            currentSet: _currentSet.number,
            completedSets: _completedSets.length,
            homeSetsWon: _homeSetsWon,
            awaySetsWon: _awaySetsWon,
            isMatchComplete: _isMatchComplete,
            homeName: _homeName,
            awayName: _awayName,
          ),

          // Error banner
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.warning,
                      size: 16, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                          fontSize: 13, color: theme.colorScheme.error),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        size: 16, color: theme.colorScheme.error),
                    onPressed: () => setState(() => _error = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // Next set dialog
          if (_showNextSetDialog)
            _NextSetBanner(onNextSet: _nextSet, onFinalize: _submit),

          // Score area
          Expanded(
            child: Row(
              children: [
                // Home team
                Expanded(
                  child: Column(
                    children: [
                      _ScoreButton(
                        icon: Icons.remove_circle_outline,
                        onPressed: _subtractPointHome,
                        disabled: _currentSet.home <= 0,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _addPointHome,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.03),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_currentSet.home}',
                                  style: const TextStyle(
                                    fontSize: 96,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
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
                      _ScoreButton(
                        icon: Icons.add_circle_outline,
                        onPressed: _addPointHome,
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  width: 1,
                  color: Colors.grey[200],
                ),

                // Away team
                Expanded(
                  child: Column(
                    children: [
                      _ScoreButton(
                        icon: Icons.remove_circle_outline,
                        onPressed: _subtractPointAway,
                        disabled: _currentSet.away <= 0,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _addPointAway,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            color: theme.colorScheme.secondary
                                .withValues(alpha: 0.03),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_currentSet.away}',
                                  style: const TextStyle(
                                    fontSize: 96,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
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
                      _ScoreButton(
                        icon: Icons.add_circle_outline,
                        onPressed: _addPointAway,
                      ),
                    ],
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _history.isEmpty ? null : _undoCurrentSet,
                    icon: const Icon(Icons.undo, size: 20),
                    label: const Text('UNDO'),
                  ),
                ),
                const SizedBox(width: 12),
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
                    label: Text(
                        _submitting ? 'SUBMITTING...' : 'SUBMIT SCORE'),
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

/// Shows set tabs and which team won each set.
class _SetIndicator extends StatelessWidget {
  final int currentSet;
  final int completedSets;
  final int homeSetsWon;
  final int awaySetsWon;
  final bool isMatchComplete;
  final String homeName;
  final String awayName;

  const _SetIndicator({
    required this.currentSet,
    required this.completedSets,
    required this.homeSetsWon,
    required this.awaySetsWon,
    required this.isMatchComplete,
    required this.homeName,
    required this.awayName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSets = isMatchComplete ? completedSets + 1 : currentSet;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show sets won by home
          if (homeSetsWon > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '$homeName $homeSetsWon',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          // Set indicators
          ...List.generate(totalSets, (i) {
            final setNum = i + 1;
            final isCurrent = setNum == currentSet;
            final isPast = setNum < currentSet;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrent
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : isPast
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Set $setNum',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isCurrent ? FontWeight.w600 : FontWeight.normal,
                  color: isCurrent
                      ? theme.colorScheme.primary
                      : isPast
                          ? Colors.green
                          : Colors.grey[500],
                ),
              ),
            );
          }),
          // Show sets won by away
          if (awaySetsWon > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '$awaySetsWon $awayName',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Banner shown when a set is complete — offers to start next set or finalize.
class _NextSetBanner extends StatelessWidget {
  final VoidCallback onNextSet;
  final VoidCallback onFinalize;

  const _NextSetBanner({
    required this.onNextSet,
    required this.onFinalize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.green.withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Set complete!',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700]),
            ),
          ),
          TextButton(
            onPressed: onFinalize,
            child: const Text('FINALIZE', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: onNextSet,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: const Text('NEXT SET'),
          ),
        ],
      ),
    );
  }
}

class _ScoreButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool disabled;

  const _ScoreButton({
    required this.icon,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          child: Center(
            child: Icon(
              icon,
              size: 28,
              color: disabled ? Colors.grey[300] : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}

