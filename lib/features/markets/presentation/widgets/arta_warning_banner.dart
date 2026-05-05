import 'package:flutter/material.dart';

class ArtaWarningBanner extends StatelessWidget {
  final Color accentColor;

  const ArtaWarningBanner({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accentColor.withAlpha((0.2 * 255).round())),
      ),
      child: Row(
        children: [
          Icon(Icons.gpp_maybe_rounded, color: accentColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "تنبيه: هنا في العرطات التطبيق مجرد وسيط للعرض، عمليات الدفع والتسليم تتم بين البائع والمشتري مباشرة دون أي مسؤولية على التطبيق.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.8 * 255).round(),
                ),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
