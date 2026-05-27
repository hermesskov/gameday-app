import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/providers.dart';
import '../services/real_api_client.dart';
import '../models/schedule_response.dart';
import '../models/schedule_event.dart';
import '../widgets/match_card.dart';

class EventDashboard extends ConsumerStatefulWidget {
  const EventDashboard({super.key});

  @override
  ConsumerState<EventDashboard> createState() => _EventDashboardState();
}

class _EventDashboardState extends ConsumerState<EventDashboard> {
  /// One of: loading | data | error — driven by API call result.
  AsyncValue<ScheduleResponse> _schedule = const AsyncLoading();

  /// Tournament IDs that have been checked in this session.
  final Set<int> _checkedInTournaments = {};

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    // Today's date in YYYY-MM-DD format for the VBL API
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    setState(() => _schedule = const AsyncLoading());

    try {
      final api = ref.read(apiClientProvider);
      final schedule = await api.getUserSchedule(dateStr);
      if (!mounted) return;
      setState(() => _schedule = AsyncValue.data(schedule));
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _schedule = AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  ScheduleEvent? get _nextMatch {
    final schedule = _schedule.valueOrNull;
    if (schedule == null || schedule.events.isEmpty) return null;

    // First event that's upcoming or in-progress
    return schedule.events.firstWhere(
      (e) => e.isMatch && e.role == 'player',
      orElse: () => schedule.events.first,
    );
  }

  Future<void> _handleCheckIn(int tournamentId) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.checkIn(tournamentId);
      if (!mounted) return;
      setState(() => _checkedInTournaments.add(tournamentId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checked in!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } on AuthExpiredException {
      // handled globally
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in failed. Try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _schedule.whenOrNull(
                data: (s) => s.events.isNotEmpty
                    ? s.events.first.tournamentName
                    : 'VBL Gameday',
              ) ??
              'VBL Gameday',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/watchlist'),
          ),
        ],
      ),
      body: _schedule.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _buildError(err),
        data: (schedule) => RefreshIndicator(
          onRefresh: _loadSchedule,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (schedule.events.isEmpty) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No upcoming events',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Section: Your Schedule
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Your Schedule',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                ...schedule.events.map((event) {
                  final isNextMatch = event == _nextMatch;
                  return Column(
                    children: [
                      if (isNextMatch && event.status != 'Started')
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: Row(
                            children: [
                              Icon(Icons.star,
                                  size: 14,
                                  color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                'NEXT UP',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      MatchCard(
                        event: event,
                        onTap: event.canScore && event.liveScoring != null
                            ? () => context.go('/live-score',
                                extra: event)
                            : null,
                      ),
                      // Check-in button (per tournament, once per session)
                      if (event.tournamentId > 0 &&
                          !_checkedInTournaments.contains(event.tournamentId))
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 6),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _handleCheckIn(event.tournamentId),
                              icon: const Icon(Icons.login, size: 16),
                              label: const Text('CHECK IN'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green[700],
                                side: BorderSide(color: Colors.green[300]!),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),

                // Quick links
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'Quick Links',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _QuickLinkCard(
                  icon: Icons.account_tree,
                  title: 'Tournament Bracket',
                  subtitle: 'View full bracket and standings',
                  onTap: () => context.go('/bracket'),
                ),
                _QuickLinkCard(
                  icon: Icons.favorite_border,
                  title: 'Watchlist',
                  subtitle: 'Bookmarked matches and teams',
                  onTap: () => context.go('/watchlist'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(Object err) {
    // Auth expired — redirect to login
    if (err is AuthExpiredException) {
      // Schedule redirect after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
      return const Center(child: CircularProgressIndicator());
    }

    final message = err.toString();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Could not load schedule',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.contains('401') || message.contains('Unauthorized')
                  ? 'Session expired. Please sign in again.'
                  : 'Check your connection and try again.',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSchedule,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
