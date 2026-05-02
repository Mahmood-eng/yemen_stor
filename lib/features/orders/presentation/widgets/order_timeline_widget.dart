import 'package:flutter/material.dart';

class OrderTimelineWidget extends StatelessWidget {
  const OrderTimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _step(context, "تم القبول", Icons.check_circle, isDone: true),
        _step(context, "التجهيز", Icons.inventory_2, isDone: true),
        _step(context, "في الطريق", Icons.delivery_dining, isCurrent: true),
        _step(context, "الاستلام", Icons.home),
      ],
    );
  }

  Widget _step(BuildContext context, String label, IconData icon, {bool isDone = false, bool isCurrent = false}) {
    final theme = Theme.of(context);
    Color color = isCurrent ? Colors.orange : (isDone ? theme.primaryColor : Colors.grey[400]!);
    
    return Column(
      children: [
        CircleAvatar(backgroundColor: color, radius: 20, child: Icon(icon, color: Colors.white, size: 18)),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}