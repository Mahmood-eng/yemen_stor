import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
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

  late FocusNode _nameFocus;
  late FocusNode _phoneFocus;
  late FocusNode _addressFocus;
  late FocusNode _cityFocus;

  bool _isEdited = false;
  bool _isLoading = false;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  Map<String, dynamic>? _userDocData;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;

    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController(text: '');
    _cityController = TextEditingController(text: user?.city ?? '');

    _nameFocus = FocusNode();
    _phoneFocus = FocusNode();
    _addressFocus = FocusNode();
    _cityFocus = FocusNode();

    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);
    _addressController.addListener(_checkChanges);
    _cityController.addListener(_checkChanges);

    _listenToUserDocument();
  }

  void _listenToUserDocument() {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _userDocSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
          final data = snapshot.data();
          if (data == null) return;

          _userDocData = data;

          final newName = (data['displayName'] ?? data['name'] ?? '') as String;
          final newPhone = (data['phoneNumber'] ?? '') as String;
          final newCity = (data['city'] ?? '') as String;
          final newAddress = (data['addressDetails'] ?? '') as String;

          if (!_nameFocus.hasFocus && _nameController.text != newName) {
            _nameController.text = newName;
          }
          if (!_phoneFocus.hasFocus && _phoneController.text != newPhone) {
            _phoneController.text = newPhone;
          }
          if (!_cityFocus.hasFocus && _cityController.text != newCity) {
            _cityController.text = newCity;
          }
          if (!_addressFocus.hasFocus &&
              _addressController.text != newAddress) {
            _addressController.text = newAddress;
          }

          if (mounted) setState(() {});
        });
  }

  void _checkChanges() {
    final originalName =
        _userDocData?['displayName'] ?? _userDocData?['name'] ?? '';
    final originalPhone = _userDocData?['phoneNumber'] ?? '';
    final originalCity = _userDocData?['city'] ?? '';
    final originalAddress = _userDocData?['addressDetails'] ?? '';

    final changed =
        _nameController.text != originalName ||
        _phoneController.text != originalPhone ||
        _cityController.text != originalCity ||
        _addressController.text != originalAddress;

    if (changed != _isEdited) {
      setState(() => _isEdited = changed);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'displayName': _nameController.text.trim(),
            'phoneNumber': _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            'city': _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            'addressDetails': _addressController.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

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
                  focusNode: _nameFocus,
                  icon: Icons.person_outline,
                ),
                _buildProfileField(
                  label: "رقم الهاتف",
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                ),
                _buildProfileField(
                  label: "البريد الإلكتروني",
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                ),
                _buildProfileField(
                  label: "المدينة",
                  controller: _cityController,
                  focusNode: _cityFocus,
                  icon: Icons.location_city_outlined,
                ),
                _buildProfileField(
                  label: "العنوان التفصيلي",
                  controller: _addressController,
                  focusNode: _addressFocus,
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
                _buildInfoSection(user, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user, bool isDark) {
    final photoUrl = (_userDocData?['photoUrl'] ?? '') as String;
    final displayPhoto = photoUrl.isNotEmpty
        ? photoUrl
        : fb_auth.FirebaseAuth.instance.currentUser?.photoURL ?? '';

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
              backgroundImage: displayPhoto.isNotEmpty
                  ? NetworkImage(displayPhoto)
                  : null,
              child: displayPhoto.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
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
          _userDocData?['displayName'] ??
              _userDocData?['name'] ??
              user.displayName ??
              'مستخدم',
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          _userDocData?['email'] ?? user.email ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
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
        if ((_userDocData?['city'] ?? user.city ?? '').toString().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              _userDocData?['city'] ?? user.city ?? '',
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
    FocusNode? focusNode,
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
            focusNode: focusNode,
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
          _buildInfoRow("تاريخ الإنشاء", "غير محدد"),
          _buildInfoRow("آخر تسجيل دخول", "غير محدد"),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
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
              if (isVerified != null) const SizedBox(width: 5),
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
    _userDocSub?.cancel();
    _nameController.removeListener(_checkChanges);
    _phoneController.removeListener(_checkChanges);
    _emailController.removeListener(_checkChanges);
    _addressController.removeListener(_checkChanges);
    _cityController.removeListener(_checkChanges);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    super.dispose();
  }
}
