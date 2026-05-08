import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/features/merchant/presentation/widgets/merchant_section_card.dart';

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

  String _storeCategory = 'موبايلات وأجهزة ذكية';
  bool _acceptedTerms = false;
  String _logoFileName = 'لم يتم اختيار ملف بعد';
  String _documentFileName = 'لم يتم اختيار ملف بعد';

  final List<String> _categories = [
    'موبايلات وأجهزة ذكية',
    'أزياء وإكسسوارات',
    'مستلزمات منزلية',
    'منتجات تجميل وعناية',
  ];

  @override
  void dispose() {
    _storeNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ownerNameController.dispose();
    _documentNumberController.dispose();
    super.dispose();
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
                      _buildDropdown(
                        label: 'نوع النشاط / القسم',
                        value: _storeCategory,
                        items: _categories,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _storeCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildFilePicker(
                        label: 'شعار المتجر',
                        fileName: _logoFileName,
                        onPressed: () {
                          setState(() {
                            _logoFileName = 'logo_shop.png';
                          });
                        },
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
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on_outlined),
                        label: Text(
                          'الموقع على الخريطة',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
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
                      _buildFilePicker(
                        label: 'صورة الوثيقة الرسمية',
                        fileName: _documentFileName,
                        onPressed: () {
                          setState(() {
                            _documentFileName = 'document_id.jpg';
                          });
                        },
                        extraText:
                            'يرجى رفع صورة واضحة للهوية أو السجل التجاري.',
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
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (!_acceptedTerms) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى الموافقة على الشروط والأحكام.'),
                          ),
                        );
                        return;
                      }
                      context.go(AppRoutes.merchantDashboard);
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
