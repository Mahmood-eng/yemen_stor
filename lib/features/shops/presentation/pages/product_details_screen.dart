import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../data/models/product_model.dart';
import '../../../../core/widgets/yemen_store_app_bar.dart';
import '../../../orders/presentation/providers/favorites_providers.dart';
import '../widgets/product_info_widget.dart';
import '../widgets/product_specifications_widget.dart';
import '../widgets/shop_info_widget.dart';
import '../widgets/product_bottom_bar.dart';
import '../../../../core/widgets/custom_favorite_button.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  double _productRatingInput = 5.0;
  late final TextEditingController _productCommentController;
  bool _isSubmittingProductReview = false;

  @override
  void initState() {
    super.initState();
    _productCommentController = TextEditingController();
  }

  @override
  void dispose() {
    _productCommentController.dispose();
    super.dispose();
  }

  Future<void> _submitProductReview(String productId, double rating, String comment) async {
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
        .collection('products')
        .doc(productId)
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
        .collection('products')
        .doc(productId)
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
          .collection('products')
          .doc(productId)
          .update({'rating': average});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final initialProductModel = ProductModel.fromJson(widget.product);
    final productId = initialProductModel.id;

    final favoritesList = ref.watch(favoritesStreamProvider).value ?? [];
    final isFav = favoritesList.any((item) => item.productId == productId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('products').doc(productId).snapshots(),
        builder: (context, snapshot) {
          final productModel = snapshot.hasData && snapshot.data!.exists
              ? ProductModel.fromJson(snapshot.data!.data() as Map<String, dynamic>..['id'] = productId)
              : initialProductModel;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: YemenStoreAppBar(
              title: Text(
                productModel.name,
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
                  icon: Icon(Icons.share_outlined, color: theme.appBarTheme.iconTheme?.color),
                  onPressed: () {},
                ),
                CustomFavoriteButton(
                  isFavorite: isFav,
                  onTap: () {
                    ref.read(favoritesActionsProvider).toggleFavorite(
                      productId: productModel.id,
                      productName: productModel.name,
                      price: productModel.hasDiscount ? productModel.price : productModel.originalPrice ?? productModel.price,
                      imageUrl: productModel.images.isNotEmpty ? productModel.images.first : '',
                      description: productModel.description,
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة المنتج
                  _buildProductImage(theme, isDark, productModel),

                  // معلومات المنتج
                  ProductInfoWidget(product: productModel),

                  // المواصفات
                  ProductSpecificationsWidget(product: productModel),

                  // معلومات المحل الديناميكية
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('shops').doc(productModel.shopId).snapshots(),
                    builder: (context, shopSnapshot) {
                      final shopData = shopSnapshot.hasData && shopSnapshot.data!.exists
                          ? shopSnapshot.data!.data() as Map<String, dynamic>
                          : {
                              'name': productModel.shopName,
                              'rating': 5.0,
                              'location': 'اليمن',
                              'status': 'مفتوح الآن',
                            };
                      
                      if (shopSnapshot.hasData && shopSnapshot.data!.exists) {
                        shopData['id'] = shopSnapshot.data!.id;
                      } else {
                        shopData['id'] = productModel.shopId;
                      }

                      return ShopInfoWidget(shop: shopData);
                    },
                  ),

                  const SizedBox(height: 20),

                  // قسم التقييمات التفاعلية للمنتج
                  _buildProductReviewsSection(theme, isDark, productModel.id),

                  const SizedBox(height: 30), // مساحة أسفل الصفحة
                ],
              ),
            ),
            bottomNavigationBar: ProductBottomBar(product: productModel),
          );
        }
      ),
    );
  }

  Widget _buildProductReviewsSection(ThemeData theme, bool isDark, String productId) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "آراء وتقييمات المنتج",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              
              // كارت إضافة تقييم
              Container(
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
                  children: [
                    // النجوم
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        final isSelected = starValue <= _productRatingInput;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _productRatingInput = starValue;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.star_rounded,
                              size: 32,
                              color: isSelected ? Colors.amber : theme.colorScheme.onSurface.withOpacity(0.15),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _productCommentController,
                      maxLines: 2,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: "اكتب رأيك بالمنتج هنا...",
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
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _isSubmittingProductReview
                            ? null
                            : () async {
                                if (_productCommentController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("الرجاء كتابة تعليق قبل الإرسال", style: TextStyle(fontFamily: 'Cairo')),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _isSubmittingProductReview = true;
                                });
                                try {
                                  await _submitProductReview(productId, _productRatingInput, _productCommentController.text.trim());
                                  _productCommentController.clear();
                                  setState(() {
                                    _productRatingInput = 5.0;
                                    _isSubmittingProductReview = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("تم إضافة تقييمك للمنتج بنجاح", style: TextStyle(fontFamily: 'Cairo')),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  setState(() {
                                    _isSubmittingProductReview = false;
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
                        child: _isSubmittingProductReview
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
              const SizedBox(height: 16),
              
              // دفق المراجعات
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .collection('reviews')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "لا توجد تعليقات للمنتج بعد. كن أول من يضيف تقييماً!",
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
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildProductImage(ThemeData theme, bool isDark, ProductModel product) {
    if (product.images.isEmpty) {
      return Container(
        height: 320,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : const Color(0xFFF3F5F7),
          borderRadius: BorderRadius.circular(24),
          border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.05)) : null,
        ),
        child: Center(
          child: Icon(
            _getIconForCategory(product.category),
            size: 120,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
      );
    }

    int activePage = 0;
    return Container(
      height: 320,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.05)) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Stack(
            children: [
              PageView.builder(
                itemCount: product.images.length,
                onPageChanged: (page) {
                  setState(() {
                    activePage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    product.images[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        _getIconForCategory(product.category),
                        size: 80,
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                  );
                },
              ),
              if (product.images.length > 1) ...[
                // Dots indicator
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      product.images.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: activePage == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: activePage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                // Numbers indicator (top right)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${activePage + 1} / ${product.images.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case "هواتف ذكية":
        return Icons.smartphone;
      case "ملابس رجالية":
        return Icons.man;
      case "ملابس نسائية":
        return Icons.woman;
      case "عطور":
        return Icons.opacity;
      case "مكياج":
        return Icons.brush;
      default:
        return Icons.inventory_2;
    }
  }
}
