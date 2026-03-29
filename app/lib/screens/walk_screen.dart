import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/walk_providers.dart';
import '../theme.dart';

class WalkScreen extends ConsumerStatefulWidget {
  const WalkScreen({super.key});

  @override
  ConsumerState<WalkScreen> createState() => _WalkScreenState();
}

class _WalkScreenState extends ConsumerState<WalkScreen> {
  bool? _answeredYes;

  bool _saved = false;

  Future<void> _save({required bool walked, int? durationMin}) async {
    await ref
        .read(walkNotifierProvider.notifier)
        .save(walked: walked, durationMin: durationMin);
    if (!walked) {
      if (mounted) context.go('/');
      return;
    }
    setState(() => _saved = true);
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final walkAsync = ref.watch(walkNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/')),
        title: const Text('Stap'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(SorgvrySpacing.cardPadding),
        child: walkAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Fout: $e')),
          data: (walk) {
            if (walk.walked || _saved) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: SorgvryColors.cardDone,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      walk.durationMin != null
                          ? '${walk.durationMin} minute gestap'
                          : 'Gestap vandag',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              );
            }

            if (_answeredYes == true) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hoe lank?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  for (final mins in [15, 30, 45])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: SorgvryColors.cardDone,
                          minimumSize: const Size.fromHeight(
                            SorgvrySpacing.buttonHeight,
                          ),
                        ),
                        onPressed: () => _save(walked: true, durationMin: mins),
                        child: Text(
                          mins == 45 ? '45+ min' : '$mins min',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Het jy vandag gestap?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: SorgvryColors.cardDone,
                    minimumSize: const Size.fromHeight(
                      SorgvrySpacing.buttonHeight,
                    ),
                  ),
                  onPressed: () => setState(() => _answeredYes = true),
                  child: const Text(
                    'JA',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: SorgvryColors.cardPending,
                    minimumSize: const Size.fromHeight(
                      SorgvrySpacing.buttonHeight,
                    ),
                  ),
                  onPressed: () => _save(walked: false),
                  child: const Text(
                    'NOG NIE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
