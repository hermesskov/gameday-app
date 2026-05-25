import 'package:flutter/material.dart';
import '../models/schedule_event.dart';

class MatchCard extends StatelessWidget {
  final ScheduleEvent event;
  final VoidCallback? onTap;

  const MatchCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine status color
    Color statusColor;
    String statusLabel;

    switch (event.status) {
      case 'Started':
        statusColor = Colors.red;
        statusLabel = 'LIVE';
        break;
      case 'Finished':
        statusColor = Colors.grey;
        statusLabel = 'FINAL';
        break;
      default:
        statusColor = theme.colorScheme.primary;
        statusLabel = 'UPCOMING';
    }

    final homeName = event.homeTeam?.name ?? 'TBD';
    final awayName = event.awayTeam?.name ?? 'TBD';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: division, status, court
              Row(
                children: [
                  Text(
                    event.divisionName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  if (event.court != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Court ${event.court}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Teams
              Row(
                children: [
                  // Home team
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          homeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (event.homeTeam?.seed != null)
                          Text(
                            'Seed #${event.homeTeam!.seed}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Score
                  if (event.games != null && event.games!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${event.games!.first.home ?? 0} - ${event.games!.first.away ?? 0}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'vs',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Away team
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          awayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (event.awayTeam?.seed != null)
                          Text(
                            'Seed #${event.awayTeam!.seed}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Time or round info
              if (event.scheduledStartDisplay != null)
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      event.scheduledStartDisplay!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Text(
                      'Match #${event.matchNumber}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
