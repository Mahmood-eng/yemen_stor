import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/arta_product.dart';
import '../providers/arta_market_providers.dart';
import '../../../../core/widgets/custom_favorite_button.dart';
import '../../../../core/widgets/app_dialogs.dart';

class ArtaProductCard extends ConsumerWidget {
  final ArtaProduct product;
  
  const ArtaProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Check if it's in the favorite stream
    final favoritesAsync = ref.watch(artaFavoritesStreamProvider);
    final isFavorite = favoritesAsync.maybeWhen(
      data: (favs) => favs.any((f) => f.id == product.id),
      orElse: () => false,
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person, color: primaryColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.seller,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product.location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Custom Favorite Button dynamically reacting to Riverpod State
                CustomFavoriteButton(
                  isFavorite: isFavorite,
                  onTap: () async {
                    // Call the toggle favorite use case via provider
                    await ref.read(artaMarketNotifierProvider.notifier).toggleFavorite(product);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (product.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                product.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${product.price} ر.ي",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Contact seller logic could be a simple dialog or tel:// launch
                    AppDialogs.showConfirmDialog(
                      context,
                      title: 'تواصل مع البائع',
                      content: 'رقم البائع: ${product.phone}\nهل ترغب في الاتصال به؟',
                      confirmText: 'اتصال',
                    ).then((value) {
                       if(value) {
                         // Action to call
                       }
                    });
                  },
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text("تواصل"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
