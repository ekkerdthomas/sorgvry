import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config.dart';
import '../providers/bp_providers.dart';
import '../providers/db_providers.dart';
import '../providers/meds_providers.dart';
import '../services/sync_status.dart';
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
  int _versionTapCount = 0;
  DateTime _lastVersionTap = DateTime(2000);
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = '${info.version}+${info.buildNumber}');
      }
    });
  }

  void _onVersionTap() {
    final now = DateTime.now();
    if (now.difference(_lastVersionTap).inMilliseconds > 1500) {
      _versionTapCount = 0;
    }
    _lastVersionTap = now;
    _versionTapCount++;
    if (_versionTapCount >= 5) {
      _versionTapCount = 0;
      _showDebugDialog();
    }
  }

  void _showDebugDialog() {
    String deviceId;
    try {
      deviceId = ref.read(deviceIdProvider);
    } catch (_) {
      deviceId = 'onbekend';
    }
    final syncNotifier = ref.read(syncStatusProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _debugRow('Weergawe', _version),
              _debugRow('Backend', backendUrl),
              _debugRow('Toestel-ID', deviceId),
              const Divider(),
              const Text(
                'Sinkronisasie',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ValueListenableBuilder<SyncStatus>(
                valueListenable: syncNotifier,
                builder: (context, status, _) {
                  final unsyncedStr = status.unsyncedCounts.entries
                      .where((e) => e.value > 0)
                      .map((e) => '${e.key}: ${e.value}')
                      .join(', ');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _debugRow(
                        'Laaste sukses',
                        status.lastSuccessfulSync
                                ?.toLocal()
                                .toString()
                                .substring(0, 19) ??
                            'Nog nooit',
                      ),
                      _debugRow(
                        'Status',
                        status.isHealthy
                            ? 'Gesond'
                            : 'Fout (${status.consecutiveErrors}x)',
                      ),
                      if (status.lastError != null)
                        _debugRow('Laaste fout', status.lastError!),
                      _debugRow(
                        'Ongesinkroniseer',
                        unsyncedStr.isEmpty ? 'Geen' : unsyncedStr,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('SLUIT'),
          ),
        ],
      ),
    );
  }

  Widget _debugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

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
    final medsSubtitle = morningDone ? 'Klaar' : 'Nog nie gedoen';

    // Night meds card state
    final nightDone = medsData?.nightTaken ?? false;
    final nightColor = nightDone
        ? SorgvryColors.cardDone
        : (hour >= 20 ? SorgvryColors.cardLate : SorgvryColors.cardPending);
    final nightSubtitle = nightDone ? 'Klaar' : 'Nog nie gedoen';

    // BP card state
    final bpData = bp.value;
    final bpDone = bpData?.hasReading ?? false;
    final bpMap = bpData?.meanArterialPressure;
    final bpColor = bpDone
        ? (bpMap != null && bpMap > 110
              ? SorgvryColors.cardAlert
              : SorgvryColors.cardDone)
        : (hour >= 11 ? SorgvryColors.cardLate : SorgvryColors.cardPending);
    final bpSubtitle = bpDone
        ? '${bpData!.systolic}/${bpData.diastolic ?? 0} · MAP ${bpMap?.round() ?? '--'}'
        : 'Nog nie gedoen';

    // Water card state
    final waterData = water.value;
    final glasses = waterData?.glasses ?? 0;
    final waterColor = glasses >= 8
        ? SorgvryColors.cardDone
        : SorgvryColors.waterPending;
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
        : 'Nog nie gedoen';

    // B12 card state
    final b12Done = medsData?.b12Taken ?? false;
    final b12Color = b12Done ? SorgvryColors.cardDone : SorgvryColors.cardLate;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _onTitleTap,
          child: const SorgvryLogo(height: 36),
        ),
        actions: [
          if (_version.isNotEmpty)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onVersionTap,
              child: SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: Center(
                    child: Text(
                      'v${_version.split('+').first}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 28 (heading) + 16 (gap) + padding = ~60px above grid
          final availableHeight = constraints.maxHeight - 60;
          final cardHeight = (availableHeight - 2 * SorgvrySpacing.gridGap) / 3;
          final cardWidth =
              (constraints.maxWidth - 3 * SorgvrySpacing.gridGap) / 2;
          final aspectRatio = (cardWidth / cardHeight).clamp(0.7, 1.2);

          return Padding(
            padding: const EdgeInsets.all(SorgvrySpacing.gridGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: aspectRatio,
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
          );
        },
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
    final isLight = color.computeLuminance() > 0.5;
    final foreground = isLight ? Colors.black87 : Colors.white;
    final foregroundMuted = isLight ? Colors.black54 : Colors.white70;

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
              Icon(icon, size: 48, color: foreground),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: foreground,
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
                    ).textTheme.bodyLarge?.copyWith(color: foregroundMuted),
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
