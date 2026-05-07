import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/features/menu/presentation/widgets/menu_section_card.dart';
import 'package:yemen_store/features/menu/presentation/widgets/menu_text_form_field.dart';

class AddPrivateNetworkScreen extends StatefulWidget {
  const AddPrivateNetworkScreen({super.key});

  @override
  State<AddPrivateNetworkScreen> createState() =>
      _AddPrivateNetworkScreenState();
}

class _AddPrivateNetworkScreenState extends State<AddPrivateNetworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _networkNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _idNumberController = TextEditingController();

  String _networkType = 'شبكة واي فاي عامة';
  final List<String> _networkTypes = [
    'شبكة واي فاي عامة',
    'شبكة خاصة',
    'نقطة اتصال متعددة المستخدمين',
  ];

  @override
  void dispose() {
    _networkNameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _ownerNameController.dispose();
    _whatsappController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'أضف شبكتك',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MenuSectionCard(
                  step: 1,
                  title: 'معلومات الشبكة الأساسية',
                  child: Column(
                    children: [
                      MenuTextFormField(
                        label: 'اسم الشبكة (كما يظهر للمستخدمين)',
                        controller: _networkNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم الشبكة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      MenuTextFormField(
                        label: 'وصف مختصر للشبكة (اختياري)',
                        controller: _descriptionController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'نوع الشبكة',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface.withOpacity(0.85),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _networkType,
                        style: textTheme.bodyMedium,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        items: _networkTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _networkType = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MenuSectionCard(
                  step: 2,
                  title: 'الموقع الجغرافي',
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.location_pin),
                        label: Text(
                          'حدد الموقع على الخريطة',
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
                      const SizedBox(height: 16),
                      MenuTextFormField(
                        label: 'المدينة/المحافظة',
                        controller: _cityController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال المدينة أو المحافظة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      MenuTextFormField(
                        label: 'الحي/الشارع',
                        controller: _areaController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الحي أو الشارع';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MenuSectionCard(
                  step: 3,
                  title: 'بيانات صاحب الشبكة',
                  child: Column(
                    children: [
                      MenuTextFormField(
                        label: 'اسم المالك الكامل',
                        controller: _ownerNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم المالك';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      MenuTextFormField(
                        label: 'رقم التواصل (واتساب)',
                        controller: _whatsappController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم التواصل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      MenuTextFormField(
                        label: 'رقم الهوية الوطنية/جواز السفر',
                        controller: _idNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الهوية أو جواز السفر';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      context.push(AppRoutes.manageCards);
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
                    'تقديم طلب الإضافة',
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
}
