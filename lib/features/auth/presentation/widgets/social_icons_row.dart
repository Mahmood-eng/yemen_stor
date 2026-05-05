import 'package:flutter/material.dart';

class SocialIconsRow extends StatelessWidget {
  const SocialIconsRow({super.key});

  @override
  Widget build(BuildContext context) {
    // نتحقق من حالة الثيم
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon(Icons.apple, isDark ? Colors.white : Colors.black, isDark),
        const SizedBox(width: 15),

        _buildIcon(Icons.g_mobiledata, Colors.red, isDark),
        const SizedBox(width: 15),

        _buildIcon(Icons.facebook, Colors.blue, isDark),
      ],
    );
  }

  Widget _buildIcon(IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // تغيير لون الحدود بناءً على الوضع
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),

        color: isDark
            ? Colors.white.withAlpha((0.05 * 255).round())
            : Colors.transparent,
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
