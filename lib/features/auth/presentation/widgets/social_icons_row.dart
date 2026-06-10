import 'package:flutter/material.dart';

class SocialIconsRow extends StatelessWidget {
  final VoidCallback? onFingerprintTap;

  const SocialIconsRow({super.key, this.onFingerprintTap});

  @override
  Widget build(BuildContext context) {
    // نتحقق من حالة الثيم
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon(Icons.apple, isDark ? Colors.white : Colors.black, isDark),
        const SizedBox(width: 15),

        _buildIcon(
          Icons.email_outlined,
          Colors.redAccent,
          isDark,
        ), // قمت بتغييرها لأيقونة قوقل/ايميل أجمل
        const SizedBox(width: 15),

        _buildIcon(Icons.facebook, Colors.blue, isDark),
        const SizedBox(width: 15),

        GestureDetector(
          onTap: onFingerprintTap,
          child: _buildIcon(
            Icons.fingerprint,
            Colors.teal,
            isDark,
          ),
        ), // إضافة خيار الهاتف كأيقونة تواصل
      ],
    );
  }

  Widget _buildIcon(IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
        ],
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
