import 'package:flutter/material.dart';

class CustomFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  const CustomFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isFavorite 
              ? theme.colorScheme.primary.withOpacity(0.1) 
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: theme.colorScheme.primary,
          size: size,
        ),
      ),
    );
  }
}
