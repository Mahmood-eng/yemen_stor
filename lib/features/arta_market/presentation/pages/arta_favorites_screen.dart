import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../providers/arta_market_providers.dart';
import '../widgets/arta_product_card.dart';

class ArtaFavoritesScreen extends ConsumerWidget {
  const ArtaFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final favoritesAsync = ref.watch(artaFavoritesStreamProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: primaryColor, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "مفضلة العرطة",
            style: theme.textTheme.titleLarge?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: favoritesAsync.when(
          loading: () => const CustomLoadingIndicator(),
          error: (err, stack) => Center(
            child: Text(
              "حدث خطأ: ${err.toString()}",
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          data: (products) {
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "لا توجد منتجات مفضلة هنا",
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ArtaProductCard(product: products[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
