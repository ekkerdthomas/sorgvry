import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/water_providers.dart';
import '../theme.dart';

class WaterScreen extends ConsumerWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(waterNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/')),
        title: Image.asset('assets/logo_with_title.png', height: 32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(SorgvrySpacing.cardPadding),
        child: waterAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Fout: $e')),
          data: (water) {
            final glasses = water.glasses;
            return Column(
              children: [
                const Spacer(),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: List.generate(8, (i) {
                    final filled = i < glasses;
                    return GestureDetector(
                      onTap: () {
                        if (!filled) {
                          ref
                              .read(waterNotifierProvider.notifier)
                              .setGlasses(i + 1);
                        }
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled ? Colors.blue : Colors.transparent,
                          border: Border.all(
                            color: filled ? Colors.blue : Colors.grey.shade400,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.water_drop,
                          color: filled ? Colors.white : Colors.grey.shade400,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                Text(
                  '$glasses van 8 glase',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: LinearProgressIndicator(
                    value: glasses / 8.0,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
                const SizedBox(height: 24),
                if (glasses > 0)
                  TextButton.icon(
                    onPressed: () {
                      ref
                          .read(waterNotifierProvider.notifier)
                          .setGlasses(glasses - 1);
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Een minder'),
                  ),
                const Spacer(flex: 2),
              ],
            );
          },
        ),
      ),
    );
  }
}
