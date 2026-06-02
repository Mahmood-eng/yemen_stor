import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/arta_product.dart';
import '../providers/arta_market_providers.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';

class ArtaAddSheet extends ConsumerStatefulWidget {
  const ArtaAddSheet({super.key});

  @override
  ConsumerState<ArtaAddSheet> createState() => _ArtaAddSheetState();
}

class _ArtaAddSheetState extends ConsumerState<ArtaAddSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _sellerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_validateForm);
    _priceController.addListener(_validateForm);
    _sellerController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _locationController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _titleController.text.trim().isNotEmpty &&
          _priceController.text.trim().isNotEmpty &&
          _sellerController.text.trim().isNotEmpty &&
          _phoneController.text.trim().isNotEmpty &&
          _locationController.text.trim().isNotEmpty &&
          _descriptionController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_validateForm);
    _priceController.removeListener(_validateForm);
    _sellerController.removeListener(_validateForm);
    _phoneController.removeListener(_validateForm);
    _locationController.removeListener(_validateForm);
    _descriptionController.removeListener(_validateForm);
    
    _titleController.dispose();
    _priceController.dispose();
    _sellerController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final product = ArtaProduct(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        seller: _sellerController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageController.text.trim().isNotEmpty
            ? _imageController.text.trim()
            : 'https://images.unsplash.com/photo-1546868871-7041f2a55e12',
        createdAt: DateTime.now(),
      );

      await ref.read(artaMarketNotifierProvider.notifier).addProduct(product);
      
      final state = ref.read(artaMarketNotifierProvider);
      if (state.isSuccess && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تمت إضافة العرطة بنجاح!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else if (state.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${state.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final state = ref.watch(artaMarketNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "إضافة عرطة جديدة",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildTextField("اسم المنتج", _titleController, icon: Icons.shopping_bag),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField("السعر (ر.ي)", _priceController, icon: Icons.money, isNumber: true),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField("الموقع", _locationController, icon: Icons.location_on),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField("اسم البائع", _sellerController, icon: Icons.person),
              const SizedBox(height: 10),
              _buildTextField("رقم الجوال", _phoneController, icon: Icons.phone, isNumber: true),
              const SizedBox(height: 10),
              _buildTextField("الوصف", _descriptionController, icon: Icons.description, maxLines: 3),
              const SizedBox(height: 10),
              _buildTextField("رابط الصورة (اختياري)", _imageController, icon: Icons.image, isRequired: false),
              const SizedBox(height: 20),
              
              state.isLoading
                  ? const CustomLoadingIndicator()
                  : ElevatedButton(
                      onPressed: _isFormValid ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("نشر العرطة", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {required IconData icon, bool isNumber = false, int maxLines = 1, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return "هذا الحقل مطلوب";
        }
        return null;
      },
    );
  }
}
