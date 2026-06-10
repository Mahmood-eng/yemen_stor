import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/yemen_store_app_bar.dart';
import '../../data/models/shop_model.dart';

class ShopsListScreen extends StatefulWidget {
  final String marketId;
  final String marketName;
  final String categoryId;
  final String subcategoryName;

  const ShopsListScreen({
    super.key,
    required this.marketId,
    required this.marketName,
    required this.categoryId,
    required this.subcategoryName,
  });

  @override
  State<ShopsListScreen> createState() => _ShopsListScreenState();
}

class _ShopsListScreenState extends State<ShopsListScreen> {
  late Stream<QuerySnapshot> _shopsStream;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final marketId = widget.marketId;
    _shopsStream = marketId.isNotEmpty 
        ? FirebaseFirestore.instance
            .collection('shops')
            .where('marketId', isEqualTo: marketId)
            .snapshots()
        : FirebaseFirestore.instance
            .collection('shops')
            .snapshots();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final marketName = widget.marketName;
    final marketId = widget.marketId;
    final subcategoryName = widget.subcategoryName;
    final categoryId = widget.categoryId;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: YemenStoreAppBar(
          title: Text(
            subcategoryName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: theme.appBarTheme.iconTheme?.color,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: theme.appBarTheme.iconTheme?.color,
              ),
              onPressed: () => context.push(AppRoutes.cart),
            ),
          ],
        ),
        body: Column(
          children: [
            // شريط البحث في المحلات
            _buildSearchField(theme, isDark),

            // قائمة المحلات
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _shopsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: theme.colorScheme.primary),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  final shops = snapshot.data!.docs.map((doc) {
                    final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
                    if (data['id'] == null || data['id'] == '') {
                      data['id'] = doc.id;
                    }
                    return ShopModel.fromJson(data);
                  }).where((shop) {
                    // Match market: by ID or name
                    final String shopMarketName = shop.toJson()['marketName'] ?? '';
                    final bool matchesMarket = (marketId.isNotEmpty && shop.marketId == marketId) ||
                        (marketName.isNotEmpty && shopMarketName == marketName) ||
                        (marketId.isEmpty && marketName.isEmpty);

                    // Match category: by ID or name
                    final String shopCategoryName = shop.toJson()['categoryName'] ?? shop.marketType;
                    final bool matchesCategory = (categoryId.isNotEmpty && shop.categoryId == categoryId) ||
                        (subcategoryName.isNotEmpty && (shopCategoryName == subcategoryName || shop.marketType == subcategoryName)) ||
                        (categoryId.isEmpty && subcategoryName.isEmpty);

                    final bool matchesSearch = _searchQuery.isEmpty || 
                        shop.name.toLowerCase().contains(_searchQuery) ||
                        shop.description.toLowerCase().contains(_searchQuery);

                    return matchesMarket && matchesCategory && matchesSearch;
                  }).toList();

                  if (shops.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: shops.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildShopCard(context, shops[index], theme, isDark);
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

  Widget _buildSearchField(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: "ابحث عن محل...",
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "لا توجد محلات متاحة حالياً",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, ShopModel shop, ThemeData theme, bool isDark) {
    final isOpen = shop.status == "مفتوح الآن";

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
        border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.05)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push(AppRoutes.shopDetails, extra: {'shop': shop.toJson()});
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                 // صورة المحل أو الحرف الأول
                 Container(
                   width: 64,
                   height: 64,
                   decoration: BoxDecoration(
                     color: theme.colorScheme.surface,
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                   ),
                   clipBehavior: Clip.antiAlias,
                   child: shop.logoUrl.isNotEmpty
                       ? Image.network(
                           shop.logoUrl,
                           fit: BoxFit.cover,
                           loadingBuilder: (context, child, loadingProgress) {
                             if (loadingProgress == null) return child;
                             return const Center(
                               child: CircularProgressIndicator(strokeWidth: 2),
                             );
                           },
                           errorBuilder: (context, error, stackTrace) => Container(
                             decoration: BoxDecoration(
                               gradient: LinearGradient(
                                 colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
                               ),
                             ),
                             child: Center(
                               child: Text(
                                 shop.name.isNotEmpty ? shop.name[0] : 'S',
                                 style: const TextStyle(
                                   color: Colors.white,
                                   fontSize: 24,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                             ),
                           ),
                         )
                       : Container(
                           decoration: BoxDecoration(
                             gradient: LinearGradient(
                               colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
                             ),
                           ),
                           child: Center(
                             child: Text(
                               shop.name.isNotEmpty ? shop.name[0] : 'S',
                               style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 24,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           ),
                         ),
                 ),
                const SizedBox(width: 16),
                
                // تفاصيل المحل
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        shop.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            shop.rating.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              shop.status,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isOpen ? Colors.green.shade600 : Colors.red.shade600,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (shop.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          shop.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // سهم الانتقال
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
