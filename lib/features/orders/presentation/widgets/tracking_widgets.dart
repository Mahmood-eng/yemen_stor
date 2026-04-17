import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart';

// ويدجت شريط الحالات (Timeline Step)
class TrackingStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  const TrackingStep({
    super.key,
    required this.label,
    required this.icon,
    this.isDone = false,
    this.isCurrent = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color circleColor;
    Color iconColor = Colors.white;

    if (isCurrent) {
      circleColor = Colors.orange;
    } else if (isDone) {
      circleColor = AppColors.primary;
    } else if (isLast) {
      circleColor = isDark ? Colors.white10 : Colors.grey[100]!;
      iconColor = Colors.green.withOpacity(0.4);
    } else {
      circleColor = isDark ? Colors.white10 : Colors.grey[200]!;
      iconColor = Colors.grey;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent 
                ? Colors.orange 
                : (isDone ? AppColors.primary : Colors.grey.withOpacity(0.7)),
          ),
        ),
      ],
    );
  }
}

// ويدجت معلومات المندوب
class DriverInfoCard extends StatelessWidget {
  const DriverInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage("assets/images/driver.png"),
        ),
        const SizedBox(width: 15),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("المندوب: أحمد سعيد", 
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
              Text("وقت الوصول المتوقع: 15 دقيقة", 
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(12)
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone_in_talk, color: Colors.green),
          ),
        ),
      ],
    );
  }
}