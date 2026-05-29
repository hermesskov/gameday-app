import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/real_api_client.dart';
import '../models/schedule_response.dart';
import '../models/schedule_event.dart';
import '../widgets/match_card.dart';

class EventDashboard extends StatefulWidget {
  const EventDashboard({super.key});

  @override
  State<EventDashboard> createState() => _EventDashboardState();
}

class _EventDashboardState extends State<EventDashboard> {
  final _api = RealApiClient();
  AsyncValue<ScheduleResponse> _events = const AsyncLoading();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _events = const AsyncLoading());
    try {
      final schedule = await _api.getPublicEvents();
      if (!mounted) return;
      setState(() => _events = AsyncValue.data(schedule));
    } catch (e) {
      if (!mounted) return;
      setState(() => _events = AsyncValue.error(e, StackTrace.current));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VBL Gameday'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree),
            onPressed: () => context.go('/bracket'),
          ),
        ],
      ),
      body: _events.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _buildError(err),
        data: (schedule) => RefreshIndicator(
          onRefresh: _loadEvents,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (schedule.events.isEmpty)
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
                          'No events today',
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
                )
              else ...[
                // Section: Today's Events
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Today's Events",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...schedule.events.map((event) => MatchCard(
                  event: event,
                  onTap: event.isMatch
                      ? () => context.go('/live-score', extra: event)
                      : null,
                )),

                // Quick Links
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
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(Object err) {
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
              'Could not load events',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// AsyncValue without Riverpod dependency
class AsyncValue<T> {
  final T? _value;
  final Object? _error;
  final StackTrace? _stackTrace;
  final bool _isLoading;

  const AsyncValue._(this._value, this._error, this._stackTrace, this._isLoading);

  const AsyncValue.data(T value) : this._(value, null, null, false);
  const AsyncValue.error(Object error, StackTrace stackTrace)
      : this._(null, error, stackTrace, false);
  const AsyncLoading() : this._(null, null, null, true);

  bool get isLoading => _isLoading;
  bool get hasData => _value != null;
  bool get hasError => _error != null;
  T? get valueOrNull => _value;

  Widget when({
    required Widget Function() loading,
    required Widget Function(Object error, StackTrace stackTrace) error,
    required Widget Function(T data) data,
  }) {
    if (_isLoading) return loading();
    if (_error != null) return error(_error!, _stackTrace ?? StackTrace.current);
    return data(_value as T);
  }

  T? whenOrNull({required T Function(T data) data}) {
    return hasData ? data(_value as T) : null;
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
