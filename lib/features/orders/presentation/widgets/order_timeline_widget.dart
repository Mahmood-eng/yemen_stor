import 'package:flutter/material.dart';

class OrderTimelineWidget extends StatelessWidget {
  const OrderTimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildStep(
          context,
          title: "تم تأكيد الطلب",
          time: "10:30 ص",
          isCompleted: true,
          isLast: false,
        ),
        _buildStep(
          context,
          title: "جاري تجهيز طلبك",
          time: "10:45 ص",
          isCompleted: true,
          isLast: false,
        ),
        _buildStep(
          context,
          title: "السائق في الطريق إليك",
          time: "يصل خلال 15 دقيقة",
          isCompleted: false,
          isActive: true,
          isLast: false,
        ),
        _buildStep(
          context,
          title: "تم التسليم",
          time: "الوقت المتوقع 11:15 ص",
          isCompleted: false,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String title,
    required String time,
    required bool isCompleted,
    bool isActive = false,
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final neutralColor = theme.brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey[200]!;
    final iconColor = isCompleted || isActive
        ? primaryColor
        : Colors.grey[400]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العمود الجانبي (الأيقونة والخط)
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? primaryColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted || isActive
                      ? primaryColor
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : isActive
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 45,
                color: isCompleted ? primaryColor : neutralColor,
              ),
          ],
        ),
        const SizedBox(width: 15),
        // بيانات الحالة
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: isCompleted || isActive
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 14,
                  color: isCompleted || isActive
                      ? theme.colorScheme.onSurface
                      : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
