import 'package:flutter/material.dart';
import '../../data/models/order_status.dart';

class OrderTimelineWidget extends StatelessWidget {
  final OrderStatus status;
  const OrderTimelineWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData(
        title: 'تم تأكيد الطلب',
        subtitle: 'استلمنا طلبك بنجاح',
        isCompleted: true,
        isActive: false,
      ),
      _StepData(
        title: 'جاري تجهيز طلبك',
        subtitle: 'المتجر يقوم بتحضير طلبك',
        isCompleted: status == OrderStatus.onWay ||
            status == OrderStatus.completed,
        isActive: status == OrderStatus.processing,
      ),
      _StepData(
        title: 'السائق في الطريق إليك',
        subtitle: 'طلبك في الطريق',
        isCompleted: status == OrderStatus.completed,
        isActive: status == OrderStatus.onWay,
      ),
      _StepData(
        title: 'تم التسليم',
        subtitle: 'استمتع بمشترياتك',
        isCompleted: status == OrderStatus.completed,
        isActive: false,
      ),
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        return _buildStep(
          context,
          title: step.title,
          subtitle: step.subtitle,
          isCompleted: step.isCompleted,
          isActive: step.isActive,
          isLast: i == steps.length - 1,
        );
      }).toList(),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isActive = false,
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final neutralColor = theme.brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey[200]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العمود الجانبي
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
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
                            width: 10,
                            height: 10,
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
        // النص
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
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
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepData {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  _StepData({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
  });
}
