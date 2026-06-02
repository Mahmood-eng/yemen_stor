import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/worker_entity.dart';
import '../providers/workers_providers.dart';

class WorkerRegistrationScreen extends ConsumerStatefulWidget {
  const WorkerRegistrationScreen({super.key});

  @override
  ConsumerState<WorkerRegistrationScreen> createState() =>
      _WorkerRegistrationScreenState();
}

class _WorkerRegistrationScreenState
    extends ConsumerState<WorkerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _expCtrl = TextEditingController();

  String _selectedProfession = 'سباك';
  String _selectedStatus = 'متاح';

  final List<String> _professions = [
    'سباك',
    'كهربائي',
    'نجار',
    'حداد',
    'بناء',
    'دهان',
    'مبرمج',
    'مصمم جرافيك',
    'محاسب',
    'مدرس',
    'طبيب',
    'مهندس',
    'محامي',
    'مستشار مالي',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    _imageUrlCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      _showSnack('يجب تسجيل الدخول أولاً', isError: true);
      return;
    }

    final worker = WorkerEntity(
      id: '',
      name: _nameCtrl.text.trim(),
      profession: _selectedProfession,
      experienceYears: int.tryParse(_expCtrl.text.trim()) ?? 0,
      phone: _phoneCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      imageUrl: _imageUrlCtrl.text.trim(),
      status: _selectedStatus,
      userId: userId,
      createdAt: FieldValue.serverTimestamp(),
    );

    await ref.read(workerRegisterProvider.notifier).registerWorker(worker);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen(workerRegisterProvider, (prev, next) {
      if (next.status == WorkerRegisterStatus.success) {
        _showSnack('تم التسجيل بنجاح!');
        ref.read(workerRegisterProvider.notifier).reset();
        context.pop();
      } else if (next.status == WorkerRegisterStatus.error) {
        _showSnack(next.errorMessage ?? 'حدث خطأ', isError: true);
        ref.read(workerRegisterProvider.notifier).reset();
      }
    });

    final state = ref.watch(workerRegisterProvider);
    final isLoading = state.status == WorkerRegisterStatus.loading;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          title: Text(
            'التسجيل كعامل',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: theme.appBarTheme.foregroundColor,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: theme.appBarTheme.foregroundColor),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.engineering, color: Colors.white, size: 40),
                      const SizedBox(height: 10),
                      const Text(
                        'سجّل خدماتك المهنية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'أضف بياناتك ليجدك العملاء بسهولة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _SectionHeader(title: 'البيانات الشخصية', icon: Icons.person_outline),
                const SizedBox(height: 12),

                _buildField(
                  controller: _nameCtrl,
                  label: 'الاسم الكامل',
                  icon: Icons.badge_outlined,
                  validator: (v) => v!.trim().isEmpty ? 'الاسم مطلوب' : null,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _phoneCtrl,
                  label: 'رقم الهاتف',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.trim().isEmpty ? 'رقم الهاتف مطلوب' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _cityCtrl,
                        label: 'المدينة',
                        icon: Icons.location_city_outlined,
                        validator: (v) => v!.trim().isEmpty ? 'المدينة مطلوبة' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _expCtrl,
                        label: 'سنوات الخبرة',
                        icon: Icons.timeline,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.trim().isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _addressCtrl,
                  label: 'العنوان التفصيلي',
                  icon: Icons.map_outlined,
                  validator: (v) => v!.trim().isEmpty ? 'العنوان مطلوب' : null,
                ),

                const SizedBox(height: 24),
                _SectionHeader(title: 'بيانات المهنة', icon: Icons.work_outline),
                const SizedBox(height: 12),

                // Profession Dropdown
                _buildDropdownField(
                  label: 'التخصص المهني',
                  icon: Icons.engineering_outlined,
                  value: _selectedProfession,
                  items: _professions,
                  onChanged: (v) => setState(() => _selectedProfession = v!),
                ),
                const SizedBox(height: 12),

                // Status Dropdown
                _buildDropdownField(
                  label: 'الحالة',
                  icon: Icons.toggle_on_outlined,
                  value: _selectedStatus,
                  items: const ['متاح', 'مشغول'],
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                ),
                const SizedBox(height: 12),

                _buildField(
                  controller: _bioCtrl,
                  label: 'نبذة عنك',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                  validator: (v) => v!.trim().isEmpty ? 'النبذة مطلوبة' : null,
                ),
                const SizedBox(height: 12),

                _buildField(
                  controller: _imageUrlCtrl,
                  label: 'رابط صورتك الشخصية (اختياري)',
                  icon: Icons.image_outlined,
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'تسجيل الآن',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(fontFamily: 'Cairo', color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        labelStyle: TextStyle(
          fontFamily: 'Cairo',
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.8),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: TextStyle(fontFamily: 'Cairo', color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        labelStyle: TextStyle(
          fontFamily: 'Cairo',
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.8),
        ),
      ),
      dropdownColor: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(fontFamily: 'Cairo')),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
