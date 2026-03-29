import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/bp_providers.dart';
import '../theme.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/photo_capture_button.dart';

class BpScreen extends ConsumerStatefulWidget {
  const BpScreen({super.key});

  @override
  ConsumerState<BpScreen> createState() => _BpScreenState();
}

class _BpScreenState extends ConsumerState<BpScreen> {
  String _systolicDigits = '';
  String _diastolicDigits = '';
  bool _editingSystolic = true;
  bool _saved = false;

  int? get _systolic =>
      _systolicDigits.isNotEmpty ? int.tryParse(_systolicDigits) : null;
  int? get _diastolic =>
      _diastolicDigits.isNotEmpty ? int.tryParse(_diastolicDigits) : null;

  double? get _map {
    final s = _systolic;
    final d = _diastolic;
    if (s == null || d == null) return null;
    if (_diastolicDigits.length < 2) return null;
    return (s + 2 * d) / 3.0;
  }

  Color _mapColor(double map) {
    if (map > 110) return SorgvryColors.cardAlert;
    if (map < 80) return SorgvryColors.cardLate;
    return SorgvryColors.cardDone;
  }

  String _mapMessage(double map) {
    if (map > 110) return 'Sê vir jou versorger';
    if (map < 80) return 'Hou dop';
    return 'Goed so!';
  }

  void _onDigit(int digit) {
    setState(() {
      if (_editingSystolic) {
        if (_systolicDigits.length < 3) _systolicDigits += '$digit';
      } else {
        if (_diastolicDigits.length < 3) _diastolicDigits += '$digit';
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_editingSystolic) {
        if (_systolicDigits.isNotEmpty) {
          _systolicDigits = _systolicDigits.substring(
            0,
            _systolicDigits.length - 1,
          );
        }
      } else {
        if (_diastolicDigits.isNotEmpty) {
          _diastolicDigits = _diastolicDigits.substring(
            0,
            _diastolicDigits.length - 1,
          );
        }
      }
    });
  }

  void _onSubmit() {
    setState(() {
      if (_editingSystolic && _systolicDigits.isNotEmpty) {
        _editingSystolic = false;
      } else if (!_editingSystolic &&
          _systolicDigits.isNotEmpty &&
          _diastolicDigits.isNotEmpty) {
        _save();
      }
    });
  }

  Future<void> _save() async {
    final s = _systolic;
    final d = _diastolic;
    if (s == null || d == null) return;
    if (s < 50 || s > 300 || d < 30 || d > 200) return;

    await ref.read(bpNotifierProvider.notifier).save(systolic: s, diastolic: d);
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final bpAsync = ref.watch(bpNotifierProvider);
    final existingReading = bpAsync.value;

    if (existingReading != null && existingReading.hasReading) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go('/')),
          title: const SorgvryLogo(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(SorgvrySpacing.cardPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: SorgvryColors.cardDone),
              const SizedBox(height: 16),
              Text(
                '${existingReading.systolic}/${existingReading.diastolic}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'MAP: ${existingReading.meanArterialPressure?.round() ?? '—'}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              if (!_saved)
                Text(
                  'Reeds vandag gemeet',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              if (_saved) ...[
                const PhotoCaptureButton(module: 'bp'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('KLAAR'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final map = _map;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/')),
        title: const SorgvryLogo(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SorgvrySpacing.cardPadding),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _editingSystolic = true),
              child: _FieldDisplay(
                label: 'BOONSTE GETAL',
                value: _systolicDigits,
                active: _editingSystolic,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                if (_systolicDigits.isNotEmpty) {
                  setState(() => _editingSystolic = false);
                }
              },
              child: _FieldDisplay(
                label: 'ONDERSTE GETAL',
                value: _diastolicDigits,
                active: !_editingSystolic,
              ),
            ),
            const SizedBox(height: 16),
            if (map != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _mapColor(map).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(
                    SorgvrySpacing.cardRadius,
                  ),
                  border: Border.all(color: _mapColor(map), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'MAP: ${map.round()}',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: _mapColor(map)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _mapMessage(map),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SorgvryColors.cardDone,
                  minimumSize: const Size.fromHeight(
                    SorgvrySpacing.buttonHeight,
                  ),
                ),
                onPressed: _save,
                child: const Text(
                  'STOOR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const SizedBox(height: 16),
            NumericKeypad(
              onDigit: _onDigit,
              onDelete: _onDelete,
              onSubmit: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldDisplay extends StatelessWidget {
  final String label;
  final String value;
  final bool active;

  const _FieldDisplay({
    required this.label,
    required this.value,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: active
            ? SorgvryColors.primary.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(SorgvrySpacing.buttonRadius),
        border: Border.all(
          color: active ? SorgvryColors.primary : Colors.grey.shade300,
          width: active ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
