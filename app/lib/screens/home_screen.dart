import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/bp_providers.dart';
import '../providers/meds_providers.dart';
import '../providers/walk_providers.dart';
import '../providers/water_providers.dart';
import '../theme.dart';
import '../utils/b12.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _titleTapCount = 0;
  DateTime _lastTap = DateTime(2000);

  void _onTitleTap() {
    final now = DateTime.now();
    if (now.difference(_lastTap).inMilliseconds > 1500) {
      _titleTapCount = 0;
    }
    _lastTap = now;
    _titleTapCount++;
    if (_titleTapCount >= 5) {
      _titleTapCount = 0;
      context.go('/versorger');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = switch (hour) {
      >= 6 && < 12 => 'Goeie môre, Amanda',
      >= 12 && < 18 => 'Goeie middag, Amanda',
      _ => 'Goeie naand, Amanda',
    };

    final meds = ref.watch(medsNotifierProvider);
    final bp = ref.watch(bpNotifierProvider);
    final water = ref.watch(waterNotifierProvider);
    final walk = ref.watch(walkNotifierProvider);
    final showB12 = isB12Day(DateTime.now());

    // Meds card state (morning)
    final medsData = meds.value;
    final morningDone = medsData?.morningTaken ?? false;
    final medsColor = morningDone
        ? SorgvryColors.cardDone
        : (hour >= 9 ? SorgvryColors.cardLate : SorgvryColors.cardPending);
    final medsSubtitle = morningDone ? 'Klaar' : 'Uitstaande';

    // Night meds card state
    final nightDone = medsData?.nightTaken ?? false;
    final nightColor = nightDone
        ? SorgvryColors.cardDone
        : (hour >= 20 ? SorgvryColors.cardLate : SorgvryColors.cardPending);
    final nightSubtitle = nightDone ? 'Klaar' : 'Uitstaande';

    // BP card state
    final bpData = bp.value;
    final bpDone = bpData?.hasReading ?? false;
    final bpMap = bpData?.meanArterialPressure;
    final bpColor = bpDone
        ? (bpMap != null && bpMap > 110
              ? SorgvryColors.cardAlert
              : SorgvryColors.cardDone)
        : (hour >= 11 ? SorgvryColors.cardLate : SorgvryColors.cardPending);
    final bpSubtitle = bpDone ? '${bpMap?.round()} MAP' : 'Uitstaande';

    // Water card state
    final waterData = water.value;
    final glasses = waterData?.glasses ?? 0;
    final waterColor = glasses >= 8
        ? SorgvryColors.cardDone
        : SorgvryColors.cardPending;
    final waterSubtitle = '$glasses/8 glase';

    // Walk card state
    final walkData = walk.value;
    final walked = walkData?.walked ?? false;
    final walkColor = walked
        ? SorgvryColors.cardDone
        : (hour >= 17 ? SorgvryColors.cardLate : SorgvryColors.cardPending);
    final walkSubtitle = walked
        ? (walkData?.durationMin != null
              ? '${walkData!.durationMin} min'
              : 'Klaar')
        : 'Uitstaande';

    // B12 card state
    final b12Done = medsData?.b12Taken ?? false;
    final b12Color = b12Done ? SorgvryColors.cardDone : SorgvryColors.cardLate;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _onTitleTap,
          child: const SorgvryLogo(height: 36),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(SorgvrySpacing.gridGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                mainAxisSpacing: SorgvrySpacing.gridGap,
                crossAxisSpacing: SorgvrySpacing.gridGap,
                children: [
                  _HomeCard(
                    title: 'Oggend Medisyne',
                    icon: Icons.medication,
                    color: medsColor,
                    subtitle: medsSubtitle,
                    onTap: () => context.go('/medisyne?session=morning'),
                  ),
                  _HomeCard(
                    title: 'Bloeddruk',
                    icon: Icons.favorite,
                    color: bpColor,
                    subtitle: bpSubtitle,
                    onTap: () => context.go('/bloeddruk'),
                  ),
                  _HomeCard(
                    title: 'Water',
                    icon: Icons.water_drop,
                    color: waterColor,
                    subtitle: waterSubtitle,
                    onTap: () => context.go('/water'),
                  ),
                  _HomeCard(
                    title: 'Stap',
                    icon: Icons.directions_walk,
                    color: walkColor,
                    subtitle: walkSubtitle,
                    onTap: () => context.go('/stap'),
                  ),
                  _HomeCard(
                    title: 'Aand Medisyne',
                    icon: Icons.medication_liquid,
                    color: nightColor,
                    subtitle: nightSubtitle,
                    onTap: () => context.go('/medisyne?session=night'),
                  ),
                ],
              ),
            ),
            if (showB12)
              Padding(
                padding: const EdgeInsets.only(top: SorgvrySpacing.gridGap),
                child: _HomeCard(
                  title: 'B12 Inspuiting',
                  icon: Icons.vaccines,
                  color: b12Color,
                  subtitle: b12Done ? 'Klaar' : 'Vandag',
                  onTap: () => context.go('/medisyne?session=b12'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SorgvrySpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SorgvrySpacing.cardPadding,
            vertical: 12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    subtitle!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
