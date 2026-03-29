import 'package:flutter/material.dart';

import '../theme.dart';

class NumericKeypad extends StatelessWidget {
  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;

  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    Widget row(List<Widget> children) {
      return Row(
        children:
            children
                .expand((w) => [Expanded(child: w), const SizedBox(width: 8)])
                .toList()
              ..removeLast(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([
          for (var i = 1; i <= 3; i++)
            _KeyButton(label: '$i', onTap: () => onDigit(i)),
        ]),
        const SizedBox(height: 8),
        row([
          for (var i = 4; i <= 6; i++)
            _KeyButton(label: '$i', onTap: () => onDigit(i)),
        ]),
        const SizedBox(height: 8),
        row([
          for (var i = 7; i <= 9; i++)
            _KeyButton(label: '$i', onTap: () => onDigit(i)),
        ]),
        const SizedBox(height: 8),
        row([
          _KeyButton(label: 'DEL', onTap: onDelete, isAction: true),
          _KeyButton(label: '0', onTap: () => onDigit(0)),
          _KeyButton(label: 'OK', onTap: onSubmit, isAction: true),
        ]),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isAction;

  const _KeyButton({
    required this.label,
    required this.onTap,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Material(
        color: isAction ? SorgvryColors.primary : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(SorgvrySpacing.buttonRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SorgvrySpacing.buttonRadius),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isAction ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
