import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import '../providers/merchant_providers.dart';
import '../../domain/entities/merchant_shop_entity.dart';

class MerchantEditShopScreen extends ConsumerStatefulWidget {
  const MerchantEditShopScreen({super.key});

  @override
  ConsumerState<MerchantEditShopScreen> createState() => _MerchantEditShopScreenState();
}

class _MerchantEditShopScreenState extends ConsumerState<MerchantEditShopScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _storeNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _logoUrlController;

  bool _isInit = false;
  bool _isSubmitting = false;
  MerchantShopEntity? _currentShop;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _logoUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _initializeFields(MerchantShopEntity shop) {
    if (!_isInit) {
      _currentShop = shop;
      _storeNameController.text = shop.name;
      _descriptionController.text = shop.description;
      _phoneController.text = shop.phone;
      _addressController.text = shop.address;
      _logoUrlController.text = shop.logoUrl;
      _isInit = true;
    }
  }

  Future<void> _submitUpdates() async {
    if (_currentShop == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final updatedShop = MerchantShopEntity(
        id: _currentShop!.id,
        name: _storeNameController.text.trim(),
        description: _descriptionController.text.trim(),
        marketId: _currentShop!.marketId,
        marketName: _currentShop!.marketName,
        categoryId: _currentShop!.categoryId,
        categoryName: _currentShop!.categoryName,
        marketType: _currentShop!.marketType,
        logoUrl: _logoUrlController.text.trim(),
        images: _logoUrlController.text.trim().isNotEmpty ? [_logoUrlController.text.trim()] : _currentShop!.images,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        ownerName: _currentShop!.ownerName,
        documentNumber: _currentShop!.documentNumber,
        documentUrl: _currentShop!.documentUrl,
        ownerId: _currentShop!.ownerId,
        status: _currentShop!.status,
        rating: _currentShop!.rating,
        createdAt: _currentShop!.createdAt,
      );

      final updateShop = ref.read(updateShopUseCaseProvider);
      await updateShop(updatedShop);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تحديث معلومات المتجر بنجاح ✓',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في التحديث: $e', style: const TextStyle(fontFamily: 'Cairo')),
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        body: Center(
          child: Text('الرجاء تسجيل الدخول أولاً', style: const TextStyle(fontFamily: 'Cairo')),
        ),
      );
    }

    final shopAsync = ref.watch(merchantShopStreamProvider(uid));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: YemenStoreAppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.appBarTheme.iconTheme?.color),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'تعديل معلومات المتجر',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: shopAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('حدث خطأ في تحميل البيانات: $err', style: const TextStyle(fontFamily: 'Cairo')),
            ),
            data: (shop) {
              if (shop == null) {
                return Center(
                  child: Text('لا يوجد متجر مسجل لحسابك لتعديله', style: const TextStyle(fontFamily: 'Cairo')),
                );
              }
              _initializeFields(shop);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                        ),
                        child: Column(
                          children: [
                            // شعار المتجر الدائري للمعاينة
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: colorScheme.primary.withOpacity(0.1),
                              backgroundImage: _logoUrlController.text.trim().isNotEmpty
                                  ? NetworkImage(_logoUrlController.text.trim())
                                  : null,
                              child: _logoUrlController.text.trim().isEmpty
                                  ? Icon(Icons.storefront, size: 40, color: colorScheme.primary)
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            
                            _buildTextField(
                              label: 'اسم المتجر *',
                              controller: _storeNameController,
                              hint: 'أدخل اسم متجرك الجديد',
                              prefixIcon: Icons.storefront_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال اسم المتجر';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'وصف المتجر *',
                              controller: _descriptionController,
                              hint: 'اكتب وصف متجرك الجديد المحدث...',
                              prefixIcon: Icons.description_outlined,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال وصف للمتجر';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معلومات التواصل والموقع',
                              style: textTheme.titleMedium?.copyWith(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 24),
                            _buildTextField(
                              label: 'رقم الهاتف *',
                              controller: _phoneController,
                              hint: 'أدخل رقم هاتف التواصل',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال رقم الهاتف';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'العنوان بالتفصيل *',
                              controller: _addressController,
                              hint: 'المحافظة، الحي، الشارع، المحل',
                              prefixIcon: Icons.location_on_outlined,
                              maxLines: 2,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال العنوان';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'رابط شعار المتجر الجديد (URL)',
                              controller: _logoUrlController,
                              hint: 'أدخل رابط الصورة لتحديث شعار المتجر',
                              prefixIcon: Icons.image_outlined,
                              keyboardType: TextInputType.url,
                              onChanged: (val) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitUpdates,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
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
                                      child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2.5),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('جاري حفظ التعديلات حية...', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : const Text(
                                  'حفظ التغييرات الآن',
                                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
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
    void Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      onChanged: onChanged,
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
