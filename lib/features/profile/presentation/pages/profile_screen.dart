import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';

import 'package:yemen_store/core/widgets/custom_button.dart';
import 'package:yemen_store/features/auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static const String id = 'profile_screen';
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;

  bool _isEdited = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;

    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController(text: '');
    _cityController = TextEditingController(text: user?.city ?? '');

    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);
    _addressController.addListener(_checkChanges);
    _cityController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final user = ref.read(authNotifierProvider).user;
    bool changed =
        _nameController.text != (user?.displayName ?? '') ||
        _phoneController.text != (user?.phoneNumber ?? '') ||
        _emailController.text != (user?.email ?? '') ||
        _addressController.text.isNotEmpty ||
        _cityController.text != (user?.city ?? '');
    if (changed != _isEdited) setState(() => _isEdited = changed);
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .updateProfile(
            _nameController.text.trim(),
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
        );
        setState(() => _isEdited = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل في تحديث البيانات: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل في تسجيل الخروج: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("الملف الشخصي"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showSignOutDialog(context),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),

      body: Builder(
        builder: (context) {
          if (authState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authState.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('حدث خطأ: ${authState.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.refresh(authNotifierProvider),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (user == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('لم يتم العثور على مستخدم.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(user, isDark),
                const SizedBox(height: 30),

                _buildProfileField(
                  label: "الاسم الكامل",
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),
                _buildProfileField(
                  label: "رقم الهاتف",
                  controller: _phoneController,
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                ),
                _buildProfileField(
                  label: "البريد الإلكتروني",
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true, // Email cannot be changed
                ),
                _buildProfileField(
                  label: "المدينة",
                  controller: _cityController,
                  icon: Icons.location_city_outlined,
                ),
                _buildProfileField(
                  label: "العنوان التفصيلي",
                  controller: _addressController,
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                ),

                const SizedBox(height: 30),

                if (_isEdited)
                  CustomButton(
                    text: _isLoading ? "جاري التحديث..." : "حفظ التغييرات",
                    onPressed: _isLoading ? null : _updateProfile,
                  ),

                const SizedBox(height: 20),

                // Additional info section
                _buildInfoSection(user, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user, bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: isDark
                  ? Colors.white10
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          user.displayName ?? 'مستخدم',
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 20),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              user.emailVerified ? Icons.verified : Icons.warning,
              color: user.emailVerified ? Colors.green : Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 5),
            Text(
              user.emailVerified ? "حساب موثق" : "حساب غير موثق",
              style: TextStyle(
                color: user.emailVerified ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (user.city != null && user.city!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              user.city!,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              suffixIcon: readOnly ? null : const Icon(Icons.edit, size: 16),
              filled: readOnly,
              fillColor: readOnly
                  ? (isDark ? Colors.white10 : Colors.grey.shade100)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "معلومات الحساب",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildInfoRow("تاريخ الإنشاء", "غير محدد"), // TODO: Add creation date
          _buildInfoRow("آخر تسجيل دخول", "غير محدد"), // TODO: Add last login
          _buildInfoRow("معرف المستخدم", user.id.substring(0, 8) + "..."),
          if (user.emailVerified)
            _buildInfoRow("حالة التحقق", "موثق", isVerified: true)
          else
            _buildInfoRow("حالة التحقق", "غير موثق", isVerified: false),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool? isVerified}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.grey.shade700,
            ),
          ),
          Row(
            children: [
              if (isVerified != null)
                Icon(
                  isVerified ? Icons.check_circle : Icons.warning,
                  color: isVerified ? Colors.green : Colors.orange,
                  size: 16,
                ),
              const SizedBox(width: 5),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تسجيل الخروج"),
        content: const Text("هل أنت متأكد من رغبتك في تسجيل الخروج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("تسجيل الخروج"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
