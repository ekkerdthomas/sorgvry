import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedsScreen extends ConsumerWidget {
  final String session;

  const MedsScreen({super.key, required this.session});

  String get _title => switch (session) {
    'morning' => 'Môre Medisyne',
    'night' => 'Aand Medisyne',
    'b12' => 'B12 Inspuiting',
    _ => 'Medisyne',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Center(child: Text('$_title — placeholder')),
    );
  }
}
