import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/core/widgets/custom_button.dart';
import 'package:yemen_store/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.city ?? '');

    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _addressController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final user = context.read<AuthProvider>().currentUser;
    bool changed = _nameController.text != (user?.fullName ?? '') ||
        _phoneController.text != (user?.phone ?? '') ||
        _addressController.text != (user?.city ?? '');
    if (changed != _isEdited) setState(() => _isEdited = changed);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!mounted) return;
      await context.read<AuthProvider>().updateProfileImage(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("الملف الشخصي")),
        body: const Center(child: Text("يرجى تسجيل الدخول")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("الملف الشخصي"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(isDark, user.fullName, user.profileImage),
            const SizedBox(height: 30),
            
            _buildProfileField(label: "الاسم الكامل", controller: _nameController, icon: Icons.person_outline),
            _buildProfileField(label: "رقم الهاتف", controller: _phoneController, icon: Icons.phone_android, keyboardType: TextInputType.phone),
            _buildProfileField(label: "المدينة", controller: _addressController, icon: Icons.location_on_outlined),

            const SizedBox(height: 30),
            
            if (_isEdited)
              CustomButton(
                text: "حفظ التغييرات",
                onPressed: () async {
                  final success = await context.read<AuthProvider>().updateProfile(
                    fullName: _nameController.text.trim(),
                    phone: _phoneController.text.trim(),
                    city: _addressController.text.trim(),
                  );
                  if (success) {
                    setState(() => _isEdited = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
                      );
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, String name, String? imagePath) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: isDark ? Colors.white10 : AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: imagePath != null ? FileImage(File(imagePath)) : null,
                child: imagePath == null ? Icon(Icons.person, size: 60, color: AppColors.primary) : null,
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          name,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20),
        ),
        const Text("عميل مميز", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              suffixIcon: const Icon(Icons.edit, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}