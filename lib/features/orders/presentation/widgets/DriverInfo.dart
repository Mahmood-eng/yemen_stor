import 'package:flutter/material.dart';

class DriverInfoWidget extends StatelessWidget {
  final String name;
  const DriverInfoWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage("assets/images/driver.png"),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.displayLarge?.copyWith(fontSize: 16)),
              const Text("يمن ستور - مندوب معتمد", style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.phone_in_talk, color: Colors.green),
          style: IconButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.1)),
        ),
      ],
    );
  }
}