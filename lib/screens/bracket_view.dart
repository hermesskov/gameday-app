import 'package:flutter/material.dart';

class BracketView extends StatelessWidget {
  const BracketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Bracket'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_tree,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Tournament Bracket',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Bracket view will be available once\ntournament data is loaded.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
