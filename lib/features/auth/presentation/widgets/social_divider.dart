import 'package:flutter/material.dart';

class SocialDivider extends StatelessWidget {
  const SocialDivider({super.key});

  @override
  Widget build(BuildContext context) {
    // نحدد ما إذا كان الوضع ليلي لتعديل لون الخط الفاصل
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            // في الوضع الليلي نجعل الخط أغمق قليلاً ليناسب الخلفية السوداء
            color: isDark ? Colors.white10 : const Color(0xFFEEEEEE),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "أو سجل عبر",
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: isDark ? Colors.white10 : const Color(0xFFEEEEEE),
          ),
        ),
      ],
    );
  }
}
