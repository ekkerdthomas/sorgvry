import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CaregiverUnlockScreen extends ConsumerWidget {
  const CaregiverUnlockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Versorger')),
      body: const Center(child: Text('PIN invoer — placeholder')),
    );
  }
}
