import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';
import 'package:yemen_stor/features/markets/data/models/market_model.dart';
import '../providers/merchant_providers.dart';
import '../../domain/entities/merchant_shop_entity.dart';

class MerchantRegistrationScreen extends ConsumerStatefulWidget {
  const MerchantRegistrationScreen({super.key});

  @override
  ConsumerState<MerchantRegistrationScreen> createState() =>
      _MerchantRegistrationScreenState();
}

class _MerchantRegistrationScreenState extends ConsumerState<MerchantRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _documentUrlController = TextEditingController();

  MarketModel? _selectedMarketObj;
  CategoryModel? _selectedCategoryObj;
  bool _acceptedTerms = false;
  bool _isSubmitting = false;

  List<MarketModel> _fetchedMarkets = [];
  bool _isMarketsLoading = true;

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ownerNameController.dispose();
    _documentNumberController.dispose();
    _logoUrlController.dispose();
    _documentUrlController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchMarkets();
  }

  Future<void> _fetchMarkets() async {
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
          _fetchedMarkets = temp;
          _isMarketsLoading = false;
          if (_fetchedMarkets.isNotEmpty) {
            _selectedMarketObj = _fetchedMarkets.first;
            _selectedCategoryObj = _fetchedMarkets.first.categories.isNotEmpty
                ? _fetchedMarkets.first.categories.first
                : null;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isMarketsLoading = false);
    }
  }

  Future<void> _submitRegistration() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الموافقة على الشروط والأحكام.', style: TextStyle(fontFamily: 'Cairo')),
        ),
      );
      return;
    }
    if (_selectedMarketObj == null || _selectedCategoryObj == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار السوق والقسم.', style: TextStyle(fontFamily: 'Cairo')),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('المستخدم غير مسجل');

      final shopRef = FirebaseFirestore.instance.collection('shops').doc();
      final logoUrl = _logoUrlController.text.trim();

      final shop = MerchantShopEntity(
        id: shopRef.id,
        name: _storeNameController.text.trim(),
        description: _descriptionController.text.trim(),
        marketId: _selectedMarketObj!.id,
        marketName: _selectedMarketObj!.name,
        categoryId: _selectedCategoryObj!.id,
        categoryName: _selectedCategoryObj!.name,
        marketType: _selectedCategoryObj!.name,
        logoUrl: logoUrl,
        images: logoUrl.isNotEmpty ? [logoUrl] : [],
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        documentNumber: _documentNumberController.text.trim(),
        documentUrl: _documentUrlController.text.trim(),
        ownerId: uid,
        status: 'مفتوح الآن',
        rating: 5.0,
        createdAt: FieldValue.serverTimestamp(),
      );

      // Register shop through Clean Architecture register shop use case
      final registerShop = ref.read(registerShopUseCaseProvider);
      await registerShop(shop);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إضافة متجر "${shop.name}" بنجاح ✓',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.green,
        ),
      );

      context.go(AppRoutes.merchantDashboard);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إرسال الطلب: $e', style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: YemenStoreAppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.appBarTheme.iconTheme?.color),
            onPressed: () => context.go(AppRoutes.home),
          ),
          title: Text(
            'فتح حساب تاجر جديد',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- بطاقة معلومات المتجر الأساسية ---
                  _buildSectionCard(
                    title: 'معلومات المتجر الأساسية',
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'اسم المتجر *',
                          controller: _storeNameController,
                          hint: 'مثال: متجر الإلكترونيات الحديثة',
                          prefixIcon: Icons.storefront_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم المتجر';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'وصف مختصر للمتجر *',
                          controller: _descriptionController,
                          hint: 'اكتب وصفاً مختصراً يجذب العملاء للمتجر...',
                          prefixIcon: Icons.description_outlined,
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال وصف للمتجر';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        // --- اختيار السوق والفئة ---
                        if (_isMarketsLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_fetchedMarkets.isNotEmpty) ...[
                          _buildMarketDropdown(),
                          const SizedBox(height: 12),
                          if (_selectedMarketObj != null)
                            _buildCategoryDropdown(),
                        ] else
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'لا توجد أسواق متاحة حالياً في النظام',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'رابط شعار المتجر (URL) (اختياري)',
                          controller: _logoUrlController,
                          hint: 'https://example.com/logo.jpg',
                          prefixIcon: Icons.image_outlined,
                          keyboardType: TextInputType.url,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- بطاقة معلومات التواصل ---
                  _buildSectionCard(
                    title: 'معلومات التواصل والموقع الجغرافي',
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'رقم هاتف المتجر *',
                          controller: _phoneController,
                          hint: '77xxxxxxx',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'العنوان الفعلي بالتفصيل *',
                          controller: _addressController,
                          hint: 'المحافظة، المديرية، الشارع، رقم المحل',
                          prefixIcon: Icons.location_on_outlined,
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال العنوان الفعلي';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- بطاقة الوثائق الرسمية ---
                  _buildSectionCard(
                    title: 'الوثائق الرسمية والهوية للتحقق',
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'اسم المالك الكامل *',
                          controller: _ownerNameController,
                          hint: 'الاسم الكامل كما هو مدون في الهوية',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال اسم المالك';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'رقم الهوية الوطنية / جواز السفر *',
                          controller: _documentNumberController,
                          hint: 'رقم الوثيقة الرسمية للتحقق من الهوية',
                          prefixIcon: Icons.badge_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الوثيقة';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'رابط صورة الوثيقة (URL) (اختياري)',
                          controller: _documentUrlController,
                          hint: 'https://example.com/document.png',
                          prefixIcon: Icons.attach_file_outlined,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                            });
                          },
                          title: Text(
                            'أوافق على جميع شروط وأحكام التجار وسياسة الخصوصية الخاصة بيمن ستور',
                            style: textTheme.bodySmall?.copyWith(fontFamily: 'Cairo'),
                          ),
                          activeColor: colorScheme.primary,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- زر التقديم ---
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        disabledBackgroundColor: colorScheme.primary.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: colorScheme.onPrimary,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'جاري إرسال الطلب وحفظ البيانات...',
                                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          : const Text(
                              'تقديم طلب الانضمام للتاجر',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
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

  Widget _buildMarketDropdown() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'اختر السوق الرئيسي *',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<MarketModel>(
          value: _selectedMarketObj,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.store_outlined, color: theme.colorScheme.primary.withOpacity(0.7)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: _fetchedMarkets
              .map((m) => DropdownMenuItem(value: m, child: Text(m.name, style: const TextStyle(fontFamily: 'Cairo'))))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedMarketObj = value;
                _selectedCategoryObj = value.categories.isNotEmpty ? value.categories.first : null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    final theme = Theme.of(context);
    final categories = _selectedMarketObj?.categories ?? [];
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'اختر القسم الدقيق *',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<CategoryModel>(
          value: _selectedCategoryObj,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.category_outlined, color: theme.colorScheme.primary.withOpacity(0.7)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c.name, style: const TextStyle(fontFamily: 'Cairo'))))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategoryObj = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary.withOpacity(0.7)),
        labelStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.75),
          fontFamily: 'Cairo',
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontFamily: 'Cairo',
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
