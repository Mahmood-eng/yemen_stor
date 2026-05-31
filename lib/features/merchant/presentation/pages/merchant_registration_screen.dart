import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemen_store/features/merchant/presentation/widgets/merchant_section_card.dart';
import 'package:yemen_store/features/markets/data/models/market_model.dart';

class MerchantRegistrationScreen extends StatefulWidget {
  const MerchantRegistrationScreen({super.key});

  @override
  State<MerchantRegistrationScreen> createState() =>
      _MerchantRegistrationScreenState();
}

class _MerchantRegistrationScreenState
    extends State<MerchantRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _documentUrlController = TextEditingController();

  String? _selectedMarket;
  String? _selectedSection;
  bool _acceptedTerms = false;
  String _logoFileName = '';
  String _documentFileName = '';

  List<MarketModel> _fetchedMarkets = [];
  bool _isMarketsLoading = true;

  @override
  void dispose() {
    _storeNameController.dispose();
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
            _selectedMarket = _fetchedMarkets.first.name;
            _selectedSection = _fetchedMarkets.first.categories.isNotEmpty
                ? _fetchedMarkets.first.categories.first.name
                : null;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isMarketsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: Text(
          'فتح حساب تاجر',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MerchantSectionCard(
                  title: 'معلومات المتجر الأساسية',
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'اسم المتجر (بالعربية)',
                        controller: _storeNameController,
                        hint: 'اسم المتجر (بالعربية)',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم المتجر';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_isMarketsLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      else if (_fetchedMarkets.isNotEmpty) ...[
                        _buildDropdown(
                          label: 'اختر السوق',
                          value: _selectedMarket!,
                          items: _fetchedMarkets.map((m) => m.name).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedMarket = value;
                                final market = _fetchedMarkets.firstWhere(
                                  (m) => m.name == value,
                                );
                                _selectedSection = market.categories.isNotEmpty
                                    ? market.categories.first.name
                                    : null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_selectedMarket != null)
                          _buildDropdown(
                            label: 'القسم',
                            value: _selectedSection ?? '',
                            items: _fetchedMarkets
                                .firstWhere((m) => m.name == _selectedMarket)
                                .categories
                                .map((c) => c.name)
                                .toList(),
                            onChanged: (value) {
                              if (value != null)
                                setState(() => _selectedSection = value);
                            },
                          ),
                      ],
                      const SizedBox(height: 12),
                      // Logo as URL input (user will paste URL)
                      _buildTextField(
                        label: 'رابط شعار المتجر (URL)',
                        controller: _logoUrlController,
                        hint: 'https://.../logo.jpg',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رابط الشعار';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MerchantSectionCard(
                  title: 'معلومات التواصل والموقع',
                  child: Column(
                    children: [
                      _buildPhoneField(
                        controller: _phoneController,
                        hint: 'رقم هاتف المتجر',
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: 'العنوان الفعلي (بالتفصيل)',
                        controller: _addressController,
                        hint: 'العنوان الفعلي (بالتفصيل)',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال العنوان الفعلي';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MerchantSectionCard(
                  title: 'الوثائق الرسمية للتحقق',
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'اسم المالك الكامل',
                        controller: _ownerNameController,
                        hint: 'اسم المالك الكامل',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم المالك';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: 'رقم الهوية / جواز السفر',
                        controller: _documentNumberController,
                        hint: 'رقم الوثيقة الرسمية',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الوثيقة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: 'رابط صورة الوثيقة (URL)',
                        controller: _documentUrlController,
                        hint: 'https://.../id.jpg',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رابط الوثيقة';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.url,
                      ),
                      CheckboxListTile(
                        value: _acceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                        title: const Text(
                          'أوافق على شروط وأحكام التجار وسياسة الخصوصية',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    if (!_acceptedTerms) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى الموافقة على الشروط والأحكام.'),
                        ),
                      );
                      return;
                    }

                    try {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) throw Exception('المستخدم غير مسجل');

                      final shopData = {
                        'name': _storeNameController.text.trim(),
                        'market': _selectedMarket,
                        'section': _selectedSection,
                        'logoUrl': _logoUrlController.text.trim(),
                        'phone': _phoneController.text.trim(),
                        'address': _addressController.text.trim(),
                        'ownerName': _ownerNameController.text.trim(),
                        'documentNumber': _documentNumberController.text.trim(),
                        'documentUrl': _documentUrlController.text.trim(),
                        'ownerId': uid,
                        'status': 'pending',
                        'createdAt': FieldValue.serverTimestamp(),
                      };

                      final shopRef = await FirebaseFirestore.instance
                          .collection('shops')
                          .add(shopData);

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .update({'role': 'merchant', 'shopId': shopRef.id});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم إضافة محل ${shopData['name']} في ${shopData['market']} إلى قسم ${shopData['section']}',
                          ),
                        ),
                      );

                      context.go(AppRoutes.merchantDashboard);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('فشل في إرسال الطلب: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'تقديم طلب الانضمام',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.75),
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildPhoneField({
    required TextEditingController controller,
    required String hint,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'رقم الهاتف',
        hintText: 'رقم هاتف المتجر',
        labelStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.75),
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال رقم الهاتف';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFilePicker({
    required String label,
    required String fileName,
    required VoidCallback onPressed,
    String? extraText,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: Text(
                fileName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                minimumSize: const Size(80, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('تحميل'),
            ),
          ],
        ),
        if (extraText != null) ...[
          const SizedBox(height: 8),
          Text(
            extraText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}
