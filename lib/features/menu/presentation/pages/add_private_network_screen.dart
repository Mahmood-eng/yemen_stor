import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _documentUrlController = TextEditingController();

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
    _documentUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
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
                      // map picker removed; use address fields instead
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
                        label: 'رقم الهوية الوطنية/جواز سفر',
                        controller: _idNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الهوية أو جواز السفر';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      MenuTextFormField(
                        label: 'رابط صورة الهوية (URL)',
                        controller: _documentUrlController,
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رابط صورة الهوية';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;

                    try {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) throw Exception('المستخدم غير مسجل');

                      final data = {
                        'name': _networkNameController.text.trim(),
                        'description': _descriptionController.text.trim(),
                        'type': _networkType,
                        'city': _cityController.text.trim(),
                        'area': _areaController.text.trim(),
                        'ownerName': _ownerNameController.text.trim(),
                        'whatsapp': _whatsappController.text.trim(),
                        'idNumber': _idNumberController.text.trim(),
                        'documentUrl': _documentUrlController.text.trim(),
                        'ownerId': uid,
                        'status': 'pending',
                        'createdAt': FieldValue.serverTimestamp(),
                      };

                      final ref = await FirebaseFirestore.instance
                          .collection('networks')
                          .add(data);

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .update({
                            'role': 'network_owner',
                            'networkId': ref.id,
                          });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم إضافة شبكتك ${data['name']} بنجاح'),
                        ),
                      );

                      context.push(AppRoutes.manageCards);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('فشل في الإضافة: $e')),
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
