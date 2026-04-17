import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/core/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
 
  final String _origName = "محمود عبدالسلام محمد";
  final String _origPhone = "770500596";
  final String _origEmail = "mahmoodalmaqtari@gmail.com";
  final String _origAddress = "تعز - الدائري - مقابل قلعة القاهرة";

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _origName);
    _phoneController = TextEditingController(text: _origPhone);
    _emailController = TextEditingController(text: _origEmail);
    _addressController = TextEditingController(text: _origAddress);

   
    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);
    _addressController.addListener(_checkChanges);
  }

  void _checkChanges() {
    bool changed = _nameController.text != _origName ||
        _phoneController.text != _origPhone ||
        _emailController.text != _origEmail ||
        _addressController.text != _origAddress;
    if (changed != _isEdited) setState(() => _isEdited = changed);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("الملف الشخصي"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(isDark),
            const SizedBox(height: 30),
            
            _buildProfileField(label: "الاسم الكامل", controller: _nameController, icon: Icons.person_outline),
            _buildProfileField(label: "رقم الهاتف", controller: _phoneController, icon: Icons.phone_android, keyboardType: TextInputType.phone),
            _buildProfileField(label: "البريد الإلكتروني", controller: _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            _buildProfileField(label: "العنوان", controller: _addressController, icon: Icons.location_on_outlined, maxLines: 2),

            const SizedBox(height: 30),
            
            if (_isEdited)
              CustomButton(
                text: "حفظ التغييرات",
                onPressed: () {
                  // هنا نضع الأكشن الخاص بتحديث البيانات في قاعدة البيانات
                  setState(() => _isEdited = false);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: isDark ? Colors.white10 : AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.person, size: 60, color: AppColors.primary),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          _origName,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20),
        ),
        const Text("عميل ذهبي", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
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
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}