import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_stor/core/widgets/custom_button.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';
import '../../../markets/data/models/market_model.dart';
import '../../../shops/domain/entities/product_entity.dart';
import '../../../shops/presentation/providers/product_providers.dart';

class MerchantAddProductScreen extends ConsumerStatefulWidget {
  const MerchantAddProductScreen({super.key});

  @override
  ConsumerState<MerchantAddProductScreen> createState() =>
      _MerchantAddProductScreenState();
}

class _MerchantAddProductScreenState
    extends ConsumerState<MerchantAddProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController(
    text: '10',
  );

  // List of controllers for multiple product image URLs
  final List<TextEditingController> _imageControllers = [
    TextEditingController(),
  ];

  // Markets and categories fetched from database
  List<MarketModel> _markets = [];
  bool _isMarketsLoading = true;
  MarketModel? _selectedMarket;
  CategoryModel? _selectedCategory;

  // Exact product types and specifications
  List<String> _exactTypes = [];
  String _selectedExactType = 'أخرى';

  // Controllers for dynamic specifications mapping (default key -> controller)
  final Map<String, TextEditingController> _specControllers = {};

  // Controllers for custom specifications (custom key controller -> custom value controller)
  final List<MapEntry<TextEditingController, TextEditingController>>
  _customSpecs = [];

  String? _merchantShopId;
  String? _merchantShopName;
  String? _merchantShopMarketType; // نوع المحل الفعلي للتاجر
  bool _inStock = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchMarketsAndCategories();
    _fetchMerchantShop();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    _stockQuantityController.dispose();
    for (var c in _imageControllers) {
      c.dispose();
    }
    for (var c in _specControllers.values) {
      c.dispose();
    }
    for (var entry in _customSpecs) {
      entry.key.dispose();
      entry.value.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchMarketsAndCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('app_data/main_config/markets')
          .get();

      List<MarketModel> temp = [];
      for (var doc in snapshot.docs) {
        final catsSnap = await doc.reference.collection('categories').get();
        final cats = catsSnap.docs
            .map((d) => CategoryModel.fromFirestore(d.data(), d.id))
            .toList();
        temp.add(
          MarketModel.fromFirestore(doc.data(), doc.id, categories: cats),
        );
      }

      if (mounted) {
        setState(() {
          _markets = temp;
          _isMarketsLoading = false;
          if (_markets.isNotEmpty) {
            _selectedMarket = _markets.first;
            _selectedCategory = _selectedMarket!.categories.isNotEmpty
                ? _selectedMarket!.categories.first
                : null;
            _updateExactTypesAndSpecs();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isMarketsLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في جلب الفئات: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchMerchantShop() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final shopSnapshot = await FirebaseFirestore.instance
          .collection('shops')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get();

      if (shopSnapshot.docs.isNotEmpty) {
        final shopDoc = shopSnapshot.docs.first;
        if (mounted) {
          setState(() {
            _merchantShopId = shopDoc.id;
            _merchantShopName = shopDoc.data()['name'] ?? 'متجري';
            _merchantShopMarketType =
                shopDoc.data()['marketType'] ??
                shopDoc.data()['categoryName'] ??
                '';
            _updateExactTypesAndSpecs();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching shop: $e");
    }
  }

  List<String> _getExactProductTypes(String? shopMarketType) {
    if (shopMarketType == null) return ['أخرى'];
    final name = shopMarketType.trim();
    if (name.contains('هواتف') ||
        name.contains('جوالات') ||
        name.contains('تلفونات') ||
        name.contains('إلكترونيات')) {
      return ['أيفونات', 'سامسونج', 'هواوي', 'شاومي', 'إكسسوارات هاتف', 'أخرى'];
    } else if (name.contains('ملابس') ||
        name.contains('أزياء') ||
        name.contains('رجالي') ||
        name.contains('نسائي')) {
      return [
        'بناطيل',
        'قمصان/شمزان',
        'جاكيتات',
        'فساتين',
        'تيشرتات',
        'أحذية',
        'أخرى',
      ];
    } else if (name.contains('عطور') ||
        name.contains('تجميل') ||
        name.contains('جمال')) {
      return [
        'عطور فرنسية',
        'عطور عربية',
        'مكياج عيون',
        'أدوات تجميل',
        'عناية شخصية',
        'أخرى',
      ];
    } else if (name.contains('شبكات')) {
      return [
        'راوترات',
        'سماعات',
        'شواحن',
        'كابلات توصيل',
        'شاشات',
        'أجهزة لوحية',
        'أخرى',
      ];
    } else if (name.contains('أغذية') ||
        name.contains('بقالة') ||
        name.contains('سوبرماركت')) {
      return ['مشروبات', 'حلويات', 'معلبات', 'مخبوزات', 'زيوت وأرز', 'أخرى'];
    }
    return ['عام', 'أخرى'];
  }

  Map<String, String> _getSpecKeysForCategory(String? categoryName) {
    if (categoryName == null) return {};
    final name = categoryName.trim();
    if (name.contains('هواتف') ||
        name.contains('جوالات') ||
        name.contains('تلفونات')) {
      return {
        'الذاكرة': 'مثال: 256 جيجابايت',
        'الرام': 'مثال: 8 جيجا',
        'اللون': 'مثال: ذهبي',
        'الضمان': 'مثال: ضمان لمدة سنة',
      };
    } else if (name.contains('ملابس') ||
        name.contains('أزياء') ||
        name.contains('رجالي') ||
        name.contains('نسائي')) {
      return {
        'المقاس': 'مثال: L, XL, 32',
        'الخامة': 'مثال: قطن 100%',
        'اللون': 'مثال: أسود',
        'بلد المنشأ': 'مثال: تركيا',
      };
    } else if (name.contains('عطور') ||
        name.contains('تجميل') ||
        name.contains('جمال')) {
      return {
        'الحجم': 'مثال: 100 مل',
        'التركيز': 'مثال: Eau de Parfum',
        'النوع': 'مثال: رجالي / نسائي',
      };
    } else if (name.contains('شبكات') || name.contains('إلكترونيات')) {
      return {
        'الموديل': 'مثال: TP-Link AX50',
        'اللون': 'مثال: أبيض',
        'الضمان': 'مثال: سنتين',
      };
    }
    return {'النوع': 'مثال: طبيعي، مصنع', 'الوصف الفني': 'مثال: جودة عالية'};
  }

  void _updateExactTypesAndSpecs() {
    if (_selectedCategory == null) return;

    // تحديث قائمة الأنواع الدقيقة بناءً على نوع المحل الفعلي المكتشف
    final shopType =
        (_merchantShopMarketType != null && _merchantShopMarketType!.isNotEmpty)
        ? _merchantShopMarketType
        : _selectedCategory!.name;

    final types = _getExactProductTypes(shopType);
    _exactTypes = types;
    _selectedExactType = types.contains(_selectedExactType)
        ? _selectedExactType
        : types.first;

    // إعادة بناء المواصفات الديناميكية
    final specKeys = _getSpecKeysForCategory(_selectedCategory!.name);

    // تنظيف المتحكمات القديمة لتجنب تسريب الذاكرة
    _specControllers.forEach((key, controller) => controller.dispose());
    _specControllers.clear();

    // إنشاء متحكمات جديدة للمفاتيح المقترحة
    for (var key in specKeys.keys) {
      _specControllers[key] = TextEditingController();
    }

    // تنظيف المواصفات المخصصة
    for (var entry in _customSpecs) {
      entry.key.dispose();
      entry.value.dispose();
    }
    _customSpecs.clear();
  }

  Future<void> _saveProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء تسجيل الدخول أولاً',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }

    if (_merchantShopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يوجد متجر مرتبط بحسابك. الرجاء فتح حساب تاجر أولاً.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }

    if (_selectedMarket == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى تحديد السوق والتصنيف أولاً.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final priceInput = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final discountPercent =
          double.tryParse(_discountController.text.trim()) ?? 0.0;
      final stockQuantity =
          int.tryParse(_stockQuantityController.text.trim()) ?? 0;

      // حساب الأسعار والخصم
      double finalPrice = priceInput;
      double? originalPrice;

      if (discountPercent > 0) {
        originalPrice = priceInput; // السعر الذي أدخله هو السعر الأصلي
        finalPrice =
            priceInput * (1 - (discountPercent / 100)); // السعر الجديد المخفض
      } else {
        originalPrice = priceInput;
      }

      // تجميع روابط الصور
      final images = _imageControllers
          .map((c) => c.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      if (images.isEmpty) {
        throw Exception('الرجاء إضافة رابط صورة واحد على الأقل للمنتج.');
      }

      // تجميع المواصفات الديناميكية
      final Map<String, dynamic> specs = {};

      // 1. المواصفات الافتراضية للفئة
      _specControllers.forEach((key, controller) {
        final val = controller.text.trim();
        if (val.isNotEmpty) {
          specs[key] = val;
        }
      });

      // 2. المواصفات المخصصة المضافة من قبل التاجر
      for (var entry in _customSpecs) {
        final key = entry.key.text.trim();
        final val = entry.value.text.trim();
        if (key.isNotEmpty && val.isNotEmpty) {
          specs[key] = val;
        }
      }

      // توليد معرف مستند جديد
      final docId = FirebaseFirestore.instance.collection('products').doc().id;

      final product = ProductEntity(
        id: docId,
        name: _productNameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: finalPrice,
        originalPrice: originalPrice,
        images: images,
        category: _selectedCategory!.name, // categoryName
        shopId: _merchantShopId!,
        shopName: _merchantShopName!,
        specifications: specs,
        inStock: _inStock,
        stockQuantity: stockQuantity,
        merchantId: uid,
        marketId: _selectedMarket!.id,
        categoryId: _selectedCategory!.id,
        exactProductType: _selectedExactType,
        createdAt: FieldValue.serverTimestamp(),
        discount: discountPercent,
        rating: 5.0, // التقييم الافتراضي للمنتج الجديد
      );

      // استدعاء UseCase لإضافة المنتج عبر Riverpod
      final addProductUseCase = ref.read(addProductUseCaseProvider);
      await addProductUseCase(product);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت إضافة المنتج "${product.name}" بنجاح ✓',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في حفظ المنتج: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: YemenStoreAppBar(
          title: Text(
            'إضافة منتج جديد للتاجر',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: theme.appBarTheme.iconTheme?.color,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: _isSaving || _isMarketsLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'جاري الاتصال والتحميل...',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- بطاقة الوسائط المتعددة (صور المنتج) ---
                        _buildSectionCard(
                          title: 'صور المنتج وروابطها المتعددة',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ..._imageControllers.asMap().entries.map((entry) {
                                final index = entry.key;
                                final controller = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          label:
                                              'رابط الصورة ${index + 1} (URL) *',
                                          controller: controller,
                                          keyboardType: TextInputType.url,
                                          validator: (value) {
                                            if (index == 0 &&
                                                (value == null ||
                                                    value.isEmpty)) {
                                              return 'الرجاء إدخال رابط الصورة الرئيسي';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      if (_imageControllers.length > 1) ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _imageControllers.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _imageControllers.add(
                                      TextEditingController(),
                                    );
                                  });
                                },
                                icon: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                ),
                                label: const Text(
                                  'إضافة رابط صورة أخرى',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              // معاينة الصورة الأولى
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _imageControllers.first,
                                builder: (context, value, child) {
                                  final url = value.text.trim();
                                  if (url.isEmpty) {
                                    return Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: theme.dividerColor.withOpacity(
                                          0.03,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: theme.dividerColor.withOpacity(
                                            0.08,
                                          ),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_outlined,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              'معاينة الصورة الرئيسية ستظهر هنا عند لصق الرابط',
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: theme.dividerColor.withOpacity(
                                          0.1,
                                        ),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, o, s) => const Center(
                                        child: Text(
                                          'رابط الصورة غير صحيح أو غير متوفر حالياً',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // --- بطاقة المعلومات الأساسية ---
                        _buildSectionCard(
                          title: 'معلومات المنتج الأساسية',
                          child: Column(
                            children: [
                              _buildTextField(
                                label: 'اسم المنتج *',
                                controller: _productNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال اسم المنتج';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      label: 'السعر  *',
                                      controller: _priceController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء إدخال السعر';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'قيمة رقمية فقط';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      label: 'الخصم المئوي % (اختياري)',
                                      controller: _discountController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          final val = double.tryParse(value);
                                          if (val == null ||
                                              val < 0 ||
                                              val > 100) {
                                            return 'نسبة بين 0 و 100';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _buildTextField(
                                label: 'الكمية المتوفرة في المخزن *',
                                controller: _stockQuantityController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال كمية المخزن';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'الرجاء إدخال عدد صحيح';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _buildTextField(
                                label: 'وصف وتفاصيل المنتج العامة *',
                                controller: _descriptionController,
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال وصف تفصيلي للمنتج';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // --- بطاقة التصنيف الذكي والقسم (من قاعدة البيانات) ---
                        _buildSectionCard(
                          title: 'التصنيف والقسم في السوق (من قاعدة البيانات)',
                          child: Column(
                            children: [
                              // قائمة اختيار السوق
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'اختر السوق الرئيسي *',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<MarketModel>(
                                    value: _selectedMarket,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                    items: _markets
                                        .map(
                                          (m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(
                                              m.name,
                                              style: const TextStyle(
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (market) {
                                      if (market != null) {
                                        setState(() {
                                          _selectedMarket = market;
                                          _selectedCategory =
                                              market.categories.isNotEmpty
                                              ? market.categories.first
                                              : null;
                                          _updateExactTypesAndSpecs();
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // قائمة اختيار الفئة
                              if (_selectedMarket != null)
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'اختر الفئة أو القسم الدقيق *',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<CategoryModel>(
                                      value: _selectedCategory,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                      ),
                                      items: _selectedMarket!.categories
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(
                                                c.name,
                                                style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (category) {
                                        if (category != null) {
                                          setState(() {
                                            _selectedCategory = category;
                                            _updateExactTypesAndSpecs();
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // --- بطاقة النوع الدقيق والمواصفات الفنية الديناميكية ---
                        if (_selectedCategory != null)
                          _buildSectionCard(
                            title: 'النوع الدقيق للمنتج ومواصفاته الفنية',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // النوع الدقيق للمنتج
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'النوع الدقيق للمنتج',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _selectedExactType,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                      ),
                                      items: _exactTypes
                                          .map(
                                            (t) => DropdownMenuItem(
                                              value: t,
                                              child: Text(
                                                t,
                                                style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(
                                            () => _selectedExactType = val,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // المواصفات الديناميكية المقترحة
                                Text(
                                  'المواصفات الفنية المميزة (${_selectedCategory!.name})',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ..._specControllers.entries.map((entry) {
                                  final key = entry.key;
                                  final controller = entry.value;
                                  final specKeys = _getSpecKeysForCategory(
                                    _selectedCategory!.name,
                                  );
                                  final hint = specKeys[key] ?? '';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildTextField(
                                      label: key,
                                      controller: controller,
                                      // We don't make specifications strictly required, but highly encourage them
                                    ),
                                  );
                                }).toList(),

                                // المواصفات المخصصة
                                if (_customSpecs.isNotEmpty) ...[
                                  const Divider(height: 30),
                                  Text(
                                    'مواصفات إضافية مخصصة',
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ..._customSpecs.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              label: 'الميزة (مثال: البطارية)',
                                              controller: item.key,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _buildTextField(
                                              label: 'القيمة (مثال: 5000mAh)',
                                              controller: item.value,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _customSpecs.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],

                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _customSpecs.add(
                                        MapEntry(
                                          TextEditingController(),
                                          TextEditingController(),
                                        ),
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text(
                                    'إضافة مواصفة مخصصة أخرى',
                                    style: TextStyle(fontFamily: 'Cairo'),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 18),

                        // --- بطاقة التوفر والبيع وزر الحفظ ---
                        _buildSectionCard(
                          title: 'حالة التوفر والبيع',
                          child: Column(
                            children: [
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'متوفر للبيع الفوري وزبائن التطبيق',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                                value: _inStock,
                                onChanged: (value) =>
                                    setState(() => _inStock = value),
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'حفظ وإضافة المنتج للمتجر',
                                onPressed: _saveProduct,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo'),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
