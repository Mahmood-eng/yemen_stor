import 'package:flutter/material.dart';

class ServicesGrid extends StatelessWidget {
  final List<Widget> children;

  const ServicesGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 0.85,
      children: children,
    );
  }
}
