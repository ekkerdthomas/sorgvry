import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';

/// Calculates whether today is a B12 injection day.
bool isB12Day(DateTime date) {
  final b12Start = DateTime(2026, 3, 25);
  final diff = DateUtils.dateOnly(date).difference(DateUtils.dateOnly(b12Start)).inDays;
  return diff >= 0 && diff % 14 == 0;
}

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

    final showB12 = isB12Day(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _onTitleTap,
          child: const Text('Sorgvry'),
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
                mainAxisSpacing: SorgvrySpacing.gridGap,
                crossAxisSpacing: SorgvrySpacing.gridGap,
                children: [
                  _HomeCard(
                    title: 'Môre Medisyne',
                    icon: Icons.medication,
                    color: SorgvryColors.cardPending,
                    subtitle: 'Nog nie gedoen',
                    onTap: () => context.go('/medisyne?session=morning'),
                  ),
                  _HomeCard(
                    title: 'Bloeddruk',
                    icon: Icons.favorite,
                    color: SorgvryColors.cardPending,
                    subtitle: 'Nog nie gedoen',
                    onTap: () => context.go('/bloeddruk'),
                  ),
                  _HomeCard(
                    title: 'Water',
                    icon: Icons.water_drop,
                    color: SorgvryColors.cardPending,
                    subtitle: '0/8 glase',
                    onTap: () => context.go('/water'),
                  ),
                  _HomeCard(
                    title: 'Stap',
                    icon: Icons.directions_walk,
                    color: SorgvryColors.cardPending,
                    subtitle: 'Nog nie gedoen',
                    onTap: () => context.go('/stap'),
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
                  color: SorgvryColors.cardLate,
                  subtitle: 'Vandag',
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
          padding: const EdgeInsets.all(SorgvrySpacing.cardPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
