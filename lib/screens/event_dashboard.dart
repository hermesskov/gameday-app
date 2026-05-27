import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/providers.dart';
import '../models/schedule_response.dart';
import '../models/schedule_event.dart';
import '../widgets/match_card.dart';

class EventDashboard extends ConsumerStatefulWidget {
  const EventDashboard({super.key});

  @override
  ConsumerState<EventDashboard> createState() => _EventDashboardState();
}

class _EventDashboardState extends ConsumerState<EventDashboard> {
  AsyncValue<ScheduleResponse>? _schedule;
  bool _checkedIn = false;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final api = ref.read(apiClientProvider);
    final schedule = await api.getUserSchedule('2026-06-15');
    setState(() {
      _schedule = AsyncValue.data(schedule);
    });
  }

  Future<void> _handleCheckIn() async {
    final api = ref.read(apiClientProvider);
    await api.checkIn(45678);
    setState(() => _checkedIn = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checked in successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  ScheduleEvent? get _nextMatch {
    final schedule = _schedule?.valueOrNull;
    if (schedule == null || schedule.events.isEmpty) return null;

    // First event that's upcoming or in-progress
    return schedule.events.firstWhere(
      (e) => e.isMatch && e.role == 'player',
      orElse: () => schedule.events.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schedule = _schedule?.valueOrNull;
    final isLoading = _schedule == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(schedule?.events.first.tournamentName ?? 'VBL Gameday'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/watchlist'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSchedule,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Check-in card
                  if (!_checkedIn)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: Card(
                        color: theme.colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Check In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    Text(
                                      "Confirm you're here",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme
                                            .colorScheme.onPrimaryContainer
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _handleCheckIn,
                                child: const Text('CHECK IN'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

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

                  if (schedule == null || schedule.events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No events scheduled for today',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    )
                  else
                    ...schedule.events.map((event) {
                      final isNextMatch = event == _nextMatch;
                      return Column(
                        children: [
                          if (isNextMatch && event.status != 'Started')
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 4),
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
                        ],
                      );
                    }),

                  // Quick links section
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
