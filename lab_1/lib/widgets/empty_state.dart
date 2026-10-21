import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}
