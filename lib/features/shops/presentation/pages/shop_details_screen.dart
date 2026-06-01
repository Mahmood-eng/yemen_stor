import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../data/models/product_model.dart';
import '../../../../core/widgets/yemen_store_app_bar.dart';
import '../widgets/product_card.dart';
import '../providers/product_providers.dart';

class ShopDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  ConsumerState<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends ConsumerState<ShopDetailsScreen> {
  String _selectedCategory = "الكل";

  Future<void> _submitShopReview(String shopId, double rating, String comment) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    
    String userName = 'مستخدم';
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          userName = userDoc.data()?['name'] ?? user.displayName ?? 'مستخدم';
        }
      } catch (e) {
        // Ignored
      }
    }

    final reviewDocRef = FirebaseFirestore.instance
        .collection('shops')
        .doc(shopId)
        .collection('reviews')
        .doc(uid);

    await reviewDocRef.set({
      'rating': rating,
      'comment': comment,
      'userName': userName,
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Recalculate average rating
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('shops')
        .doc(shopId)
        .collection('reviews')
        .get();

    if (reviewsSnapshot.docs.isNotEmpty) {
      double total = 0.0;
      for (var doc in reviewsSnapshot.docs) {
        total += (doc.data()['rating'] as num).toDouble();
      }
      double average = total / reviewsSnapshot.docs.length;
      average = double.parse(average.toStringAsFixed(1));

      await FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .update({'rating': average});
    }
  }

  void _showShopInfoBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shopId = widget.shop['id'] ?? '';
    final shopName = widget.shop['name'] ?? '';
    final ownerName = widget.shop['ownerName'] ?? 'غير معروف';
    final location = widget.shop['location'] ?? 'غير محدد';
    final phone = widget.shop['phone'] ?? 'لا يوجد';
    final status = widget.shop['status'] ?? 'مغلق';

    double ratingInput = 5.0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    // مقبض السحب
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // العنوان
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "معلومات وتقييمات المحل",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // كارت معلومات المحل
                            _buildShopInfoCard(theme, isDark, shopId, shopName, ownerName, location, phone, status),
                            const SizedBox(height: 20),
                            
                            // قسم كتابة تقييم
                            Text(
                              "أضف تقييمك للمحل",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.05)) : null,
                              ),
                              child: Column(
                                children: [
                                  // نجوم الاختيار
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      final starValue = index + 1.0;
                                      final isSelected = starValue <= ratingInput;
                                      return GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            ratingInput = starValue;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Icon(
                                            Icons.star_rounded,
                                            size: 36,
                                            color: isSelected ? Colors.amber : theme.colorScheme.onSurface.withOpacity(0.2),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: commentController,
                                    maxLines: 2,
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      hintText: "اكتب تعليقك هنا...",
                                      hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                      filled: true,
                                      fillColor: isDark ? theme.colorScheme.surface : const Color(0xFFF8F9FA),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: isSubmitting
                                          ? null
                                          : () async {
                                              if (commentController.text.trim().isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("الرجاء كتابة تعليق قبل الإرسال", style: TextStyle(fontFamily: 'Cairo')),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }
                                              setModalState(() {
                                                isSubmitting = true;
                                              });
                                              try {
                                                await _submitShopReview(shopId, ratingInput, commentController.text.trim());
                                                commentController.clear();
                                                setModalState(() {
                                                  ratingInput = 5.0;
                                                  isSubmitting = false;
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("تم إضافة تقييمك بنجاح", style: TextStyle(fontFamily: 'Cairo')),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                              } catch (e) {
                                                setModalState(() {
                                                  isSubmitting = false;
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("فشل في إرسال التقييم: $e", style: const TextStyle(fontFamily: 'Cairo')),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
                                        foregroundColor: theme.colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: isSubmitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                            )
                                          : const Text(
                                              "إرسال التقييم",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // قسم التقييمات السابقة
                            Text(
                              "تقييمات وآراء العملاء",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildReviewsListSection(theme, isDark, shopId),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShopInfoCard(
    ThemeData theme,
    bool isDark,
    String shopId,
    String shopName,
    String ownerName,
    String location,
    String phone,
    String status,
  ) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('shops').doc(shopId).snapshots(),
      builder: (context, snapshot) {
        double currentRating = 0.0;
        String currentStatus = status;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          currentRating = (data['rating'] ?? 0.0) as double;
          currentStatus = data['status'] ?? status;
        } else {
          currentRating = (widget.shop['rating'] ?? 0.0) as double;
        }
        final isOpen = currentStatus == "مفتوح الآن";

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.05)) : null,
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(theme, Icons.storefront, "اسم المحل", shopName),
              const Divider(height: 20),
              _buildInfoRow(theme, Icons.person_outline, "صاحب المحل", ownerName),
              const Divider(height: 20),
              _buildInfoRow(theme, Icons.location_on_outlined, "العنوان", location),
              const Divider(height: 20),
              _buildInfoRow(theme, Icons.phone_outlined, "رقم التواصل", phone),
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 20, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "التقييم العام",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  Text(
                    "$currentRating",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "الحالة",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentStatus,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOpen ? Colors.green.shade600 : Colors.red.shade600,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsListSection(ThemeData theme, bool isDark, String shopId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "لا توجد تقييمات لهذا المحل بعد. كن أول من يقيم!",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          );
        }

        final reviews = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data = reviews[index].data() as Map<String, dynamic>;
            final rUserName = data['userName'] ?? 'مستخدم';
            final rComment = data['comment'] ?? '';
            final rRating = (data['rating'] ?? 0.0) as double;
            final Timestamp? rTimestamp = data['createdAt'] as Timestamp?;
            final rDate = rTimestamp != null
                ? "${rTimestamp.toDate().year}-${rTimestamp.toDate().month}-${rTimestamp.toDate().day}"
                : "";

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.05)) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rUserName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        rDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (starIdx) {
                      return Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: starIdx < rRating ? Colors.amber : theme.colorScheme.onSurface.withOpacity(0.15),
                      );
                    }),
                  ),
                  if (rComment.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      rComment,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Cairo',
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shopId = widget.shop['id'] ?? '';
    final shopName = widget.shop['name'] ?? '';
    final marketType = widget.shop['marketType'] ?? '';

    // Watch shop products stream from the Clean Architecture layer via Riverpod
    final productsAsync = ref.watch(shopProductsStreamProvider(shopId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: YemenStoreAppBar(
          title: Text(
            shopName,
            style: theme.textTheme.titleMedium?.copyWith(
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
                Icons.info_outline,
                color: theme.appBarTheme.iconTheme?.color,
              ),
              onPressed: () => _showShopInfoBottomSheet(context),
            ),
          ],
        ),
        body: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ أثناء تحميل المنتجات: $error',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
          data: (allProductsEntities) {
            final allProducts = allProductsEntities.cast<ProductModel>();

            // Extract unique dynamic exact product types from products
            final uniqueTypes = allProducts
                .map((p) => p.exactProductType)
                .where((type) => type.isNotEmpty)
                .toSet()
                .toList();

            final categories = ["الكل", ...uniqueTypes];

            // If the selected category is no longer in the list (e.g. products changed), reset to "الكل"
            if (!categories.contains(_selectedCategory)) {
              _selectedCategory = "الكل";
            }

            // Filtered lists
            final discountedProducts = allProducts.where((p) => p.hasDiscount).toList();
            final filteredProducts = _selectedCategory == "الكل"
                ? allProducts
                : allProducts.where((p) => p.exactProductType == _selectedCategory).toList();

            return CustomScrollView(
              slivers: [
                // 1. قسم العروض المميزة
                if (discountedProducts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildOffersSection(theme, isDark, marketType, discountedProducts),
                  ),

                // 2. فلتر الفئات الديناميكي
                if (categories.length > 1)
                  SliverToBoxAdapter(
                    child: _buildCategoriesFilter(theme, categories),
                  ),

                // 3. شبكة المنتجات
                if (filteredProducts.isNotEmpty)
                  _buildProductsGrid(theme, marketType, filteredProducts)
                else
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: theme.colorScheme.onSurface.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "لا توجد منتجات مطابقة لهذا القسم حالياً",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOffersSection(
    ThemeData theme,
    bool isDark,
    String marketType,
    List<ProductModel> discountedProducts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.local_offer, color: theme.colorScheme.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                "عروض مميزة",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: discountedProducts.length,
            itemBuilder: (context, index) {
              return Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: ProductCard(
                  product: discountedProducts[index],
                  marketType: marketType,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesFilter(ThemeData theme, List<String> categories) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  fontFamily: 'Cairo',
                ),
              ),
              selected: isSelected,
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid(ThemeData theme, String marketType, List<ProductModel> products) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ProductCard(
              product: products[index],
              marketType: marketType,
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }
}
