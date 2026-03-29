import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/meds_providers.dart';
import '../theme.dart';

class MedsScreen extends ConsumerWidget {
  final String session;

  const MedsScreen({super.key, required this.session});

  String get _title => switch (session) {
    'morning' => 'Môre Medisyne',
    'night' => 'Aand Medisyne',
    'b12' => 'B12 Inspuiting',
    _ => 'Medisyne',
  };

  List<String> get _medNames => switch (session) {
    'morning' => ['Zetomax', 'Lansoloc', 'Clopiwin'],
    'night' => ['Aand medisyne'],
    'b12' => ['B12 inspuiting'],
    _ => [],
  };

  IconData get _icon => switch (session) {
    'b12' => Icons.vaccines,
    _ => Icons.medication,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsAsync = ref.watch(medsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/')),
        title: Image.asset('assets/logo_with_title.png', height: 32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(SorgvrySpacing.cardPadding),
        child: medsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Fout: $e')),
          data: (meds) {
            final taken = meds.isTaken(session);
            final takenAt = meds.takenAt(session);
            final canUndo = meds.canUndo(session);

            return Column(
              children: [
                const Spacer(),
                Icon(_icon, size: 80, color: SorgvryColors.primary),
                const SizedBox(height: 24),
                for (final name in _medNames)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                const Spacer(),
                if (!taken)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SorgvryColors.cardDone,
                      minimumSize: const Size.fromHeight(
                        SorgvrySpacing.buttonHeight,
                      ),
                    ),
                    onPressed: () {
                      ref.read(medsNotifierProvider.notifier).confirm(session);
                    },
                    child: const Text(
                      'JA, EK HET HULLE GEVAT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else ...[
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: SorgvryColors.cardDone,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    takenAt != null
                        ? 'Klaar om ${DateFormat.Hm().format(takenAt)}'
                        : 'Klaar',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (canUndo) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        ref.read(medsNotifierProvider.notifier).undo(session);
                      },
                      child: Text(
                        'Maak oop',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}
