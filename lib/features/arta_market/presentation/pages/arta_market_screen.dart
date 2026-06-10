import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../../../core/widgets/smart_search_delegate.dart';
import '../providers/arta_market_providers.dart';
import '../widgets/arta_add_sheet.dart';
import '../widgets/arta_product_card.dart';

class ArtaMarketScreen extends ConsumerWidget {
  const ArtaMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final productsAsync = ref.watch(artaProductsStreamProvider);

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
            "سوق العرطة",
            style: theme.textTheme.titleLarge?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: primaryColor),
              onPressed: () {
                // In Riverpod with StreamProvider, refreshing invalidates the provider
                ref.invalidate(artaProductsStreamProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'تم تحديث المنتجات بنجاح ✓',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    duration: const Duration(milliseconds: 800),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: primaryColor,
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite_rounded, color: primaryColor),
              onPressed: () => context.push(
                AppRoutes.artaFavorites,
              ), // We will add this route
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton(
            heroTag: 'arta_add_product',
            onPressed: () => _showAddArtaSheet(context, theme),
            backgroundColor: primaryColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            // ── شريط البحث ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: GestureDetector(
                onTap: () async {
                  final result = await showSearch(
                    context: context,
                    delegate: SmartSearchDelegate(
                      ref: ref,
                      searchHint: "ابحث في سوق العرطة...",
                    ),
                  );
                  if (result != null && result.isNotEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('جاري البحث عن: $result', style: const TextStyle(fontFamily: 'Cairo'))),
                      );
                    }
                  }
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search, color: primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        "ابحث في سوق العرطة...",
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: theme.hintColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Strict Warning Banner
            Container(
              width: MediaQuery.of(context).size.width * 0.94,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 245, 136, 11),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تنبيه : التطبيق غير مسؤول عن عمليات البيع المباشر والشراء بين المستخدمين هنا. يرجى أخذ الحيطة والحذر عند التعامل.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Products List
            Expanded(
              child: productsAsync.when(
                loading: () => const CustomLoadingIndicator(),
                error: (err, stack) => Center(
                  child: Text(
                    "حدث خطأ أثناء جلب البيانات: ${err.toString()}",
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        "لا توجد منتجات في سوق العرطة حالياً",
                        style: theme.textTheme.titleMedium,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 100),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ArtaProductCard(product: products[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddArtaSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ArtaAddSheet(),
    );
  }
}
