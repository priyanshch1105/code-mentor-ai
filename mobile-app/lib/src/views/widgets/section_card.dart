import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.child, this.padding});

  final Widget? child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.surfaceVariant,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(18),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
