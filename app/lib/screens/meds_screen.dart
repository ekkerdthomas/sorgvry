import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/meds_providers.dart';
import '../theme.dart';
import '../utils/b12.dart';
import '../widgets/photo_capture_button.dart';

class _MedInfo {
  final String name;
  final String dosage;
  final String purpose;

  const _MedInfo(this.name, this.dosage, this.purpose);
}

class MedsScreen extends ConsumerWidget {
  final String session;

  const MedsScreen({super.key, required this.session});

  String get _sessionTitle => switch (session) {
    'morning' => 'Oggend Medisyne',
    'night' => 'Aand Medisyne',
    'b12' => 'B12 Inspuiting',
    _ => 'Medisyne',
  };

  List<_MedInfo> get _meds => switch (session) {
    'morning' => const [
      _MedInfo('Zetomax', '10mg', 'Verlaag cholesterol'),
      _MedInfo('Lansoloc', '15mg', 'Maag beskermer'),
      _MedInfo('Clopiwin', '75mg', 'Voorkom bloedklonte'),
    ],
    'night' => const [
      _MedInfo('Simvastatin', '10mg', 'Verlaag cholesterol (statien)'),
      _MedInfo('Mag Glycinate', '75mg', 'Magnesium — brein & are'),
    ],
    'b12' => const [_MedInfo('B12', '1000µg', 'B12 tekort behandeling')],
    _ => const [],
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
        title: Text(_sessionTitle),
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

            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_icon, size: 80, color: SorgvryColors.primary),
                      const SizedBox(height: 24),
                      for (final med in _meds)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: SorgvryColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${med.name} ${med.dosage}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          med.purpose,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (session == 'b12') ...[
                        const SizedBox(height: 16),
                        Text(
                          'Inspuiting ${b12InjectionNumber(DateTime.now())} van $b12Total',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Volgende: ${DateFormat('d MMM yyyy').format(nextB12(DateTime.now().add(const Duration(days: 1))))}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (!taken)
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: SorgvryColors.cardDone,
                            minimumSize: const Size.fromHeight(
                              SorgvrySpacing.buttonHeight,
                            ),
                          ),
                          onPressed: () {
                            ref
                                .read(medsNotifierProvider.notifier)
                                .confirm(session);
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
                        const SizedBox(height: 16),
                        PhotoCaptureButton(module: 'meds', session: session),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.go('/'),
                          child: const Text('KLAAR'),
                        ),
                        if (canUndo) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(medsNotifierProvider.notifier)
                                  .undo(session);
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
