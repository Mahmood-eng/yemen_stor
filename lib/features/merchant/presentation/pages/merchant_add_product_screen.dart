import 'package:flutter/material.dart';
import 'package:yemen_store/core/widgets/custom_button.dart';

class MerchantAddProductScreen extends StatefulWidget {
  const MerchantAddProductScreen({super.key});

  @override
  State<MerchantAddProductScreen> createState() =>
      _MerchantAddProductScreenState();
}

class _MerchantAddProductScreenState extends State<MerchantAddProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _mainCategory = 'إلكترونيات';
  String _subCategory = 'هواتف';
  bool _inStock = true;

  final List<String> _mainCategories = [
    'إلكترونيات',
    'أزياء',
    'مستلزمات المنزل',
  ];

  final Map<String, List<String>> _subCategories = {
    'إلكترونيات': ['هواتف', 'سماعات', 'أجهزة لوحية'],
    'أزياء': ['رجالي', 'نسائي', 'أطفال'],
    'مستلزمات المنزل': ['مطبخ', 'ديكور', 'أدوات'],
  };

  final List<String> _availableColors = ['أسود', 'أبيض', 'أزرق'];
  final List<String> _selectedColors = [];

  final List<String> _extraFeatures = ['ضمان', 'شحن مجاني', 'إرجاع 7 أيام'];
  final List<String> _selectedFeatures = [];

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة منتج جديد',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'الوسائط',
                child: Column(
                  children: [
                    _buildFilePicker('الصورة الرئيسية *'),
                    const SizedBox(height: 12),
                    _buildHorizontalImageList(),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'المعلومات الأساسية',
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
                    _buildTextField(
                      label: 'السعر الأساسي *',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال السعر';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      label: 'وصف المنتج *',
                      controller: _descriptionController,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال وصف المنتج';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'التصنيف',
                child: Column(
                  children: [
                    _buildDropdown(
                      label: 'التصنيف الرئيسي *',
                      value: _mainCategory,
                      items: _mainCategories,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _mainCategory = value;
                            _subCategory = _subCategories[value]!.first;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildDropdown(
                      label: 'التصنيف الفرعي *',
                      value: _subCategory,
                      items: _subCategories[_mainCategory]!,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _subCategory = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'الخصائص المتغيرة',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'الألوان المتاحة',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildChipGroup(
                      options: _availableColors,
                      selectedItems: _selectedColors,
                      isFilter: false,
                      onSelectionChanged: (item, selected) {
                        setState(() {
                          if (selected) {
                            _selectedColors.add(item);
                          } else {
                            _selectedColors.remove(item);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'ميزات إضافية',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildChipGroup(
                      options: _extraFeatures,
                      selectedItems: _selectedFeatures,
                      isFilter: true,
                      onSelectionChanged: (item, selected) {
                        setState(() {
                          if (selected) {
                            _selectedFeatures.add(item);
                          } else {
                            _selectedFeatures.remove(item);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'التوفر',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('متوفر للبيع'),
                      value: _inStock,
                      onChanged: (value) => setState(() => _inStock = value),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(text: 'حفظ المنتج', onPressed: _saveProduct),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ المنتج بنجاح')));
    }
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
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

  Widget _buildFilePicker(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('تحميل'),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalImageList() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 90,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.image, color: Colors.grey, size: 30),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required List<String> selectedItems,
    required bool isFilter,
    required void Function(String item, bool selected) onSelectionChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: options.map((option) {
          final selected = selectedItems.contains(option);
          return isFilter
              ? FilterChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: (value) => onSelectionChanged(option, value),
                )
              : ChoiceChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: (value) => onSelectionChanged(option, value),
                );
        }).toList(),
      ),
    );
  }
}
