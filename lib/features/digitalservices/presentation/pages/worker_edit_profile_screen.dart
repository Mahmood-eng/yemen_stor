import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/professional_constants.dart';
import '../../domain/entities/worker_entity.dart';

class WorkerEditProfileScreen extends StatefulWidget {
  final WorkerEntity worker;
  const WorkerEditProfileScreen({super.key, required this.worker});

  @override
  State<WorkerEditProfileScreen> createState() => _WorkerEditProfileScreenState();
}

class _WorkerEditProfileScreenState extends State<WorkerEditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _professionController;
  late String _selectedCity;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _cvUrlController;
  late bool _isAvailable;

  final List<TextEditingController> _portfolioControllers = [];
  final List<TextEditingController> _projectControllers = [];
  final List<TextEditingController> _certificateControllers = [];

  bool _saving = false;

  /// يحدد إذا كان المهني من الكوادر العلمية أو المستشارين (لعرض الحقول الخاصة)
  bool get _isScientific =>
      ProfessionalConstants.isScientificOrConsultant(widget.worker.category);


  @override
  void initState() {
    super.initState();
    final w = widget.worker;
    _nameController = TextEditingController(text: w.name);
    _professionController = TextEditingController(text: w.profession);
    // استخدام المدينة الحالية إذا كانت في القائمة، وإلا أول مدينة
    _selectedCity = ProfessionalConstants.yemeniCities.contains(w.city)
        ? w.city
        : ProfessionalConstants.yemeniCities.first;
    _addressController = TextEditingController(text: w.address);
    _bioController = TextEditingController(text: w.bio);
    _phoneController = TextEditingController(text: w.phone);
    _cvUrlController = TextEditingController(text: w.cvUrl ?? '');
    _isAvailable = w.isAvailable;

    for (final link in w.portfolioLinks) {
      _portfolioControllers.add(TextEditingController(text: link));
    }
    for (final link in w.projectLinks) {
      _projectControllers.add(TextEditingController(text: link));
    }
    for (final cert in w.certificates) {
      _certificateControllers.add(TextEditingController(text: cert));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _cvUrlController.dispose();
    for (final c in _portfolioControllers) c.dispose();
    for (final c in _projectControllers) c.dispose();
    for (final c in _certificateControllers) c.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(widget.worker.id)
          .update({
        'name': _nameController.text.trim(),
        'profession': _professionController.text.trim(),
        'city': _selectedCity,
        'address': _addressController.text.trim(),
        'bio': _bioController.text.trim(),
        'phone': _phoneController.text.trim(),
        'isAvailable': _isAvailable,
        'status': _isAvailable ? 'متاح' : 'مشغول',
        'portfolioLinks': _portfolioControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
        if (_isScientific) ...{
          'projectLinks': _projectControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
          'certificates': _certificateControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
          'cvUrl': _cvUrlController.text.trim(),
        },
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الملف الشخصي بنجاح ✓', style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e', style: const TextStyle(fontFamily: 'Cairo'))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'إدارة الملف الشخصي',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            TextButton(
              onPressed: _saving ? null : _saveProfile,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'حفظ',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── البيانات العامة ──
              _sectionHeader(theme, 'البيانات الأساسية', Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _buildCard(
                theme,
                isDark,
                children: [
                  _buildTextField(theme, 'الاسم الكامل', _nameController, Icons.person_outline),
                  _buildTextField(theme, 'التخصص / المهنة', _professionController, Icons.work_outline),
                  // ── Dropdown المدينة الموحد ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المدينة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedCity,
                          isExpanded: true,
                          onChanged: (v) => setState(() => _selectedCity = v!),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          dropdownColor: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          items: ProfessionalConstants.yemeniCities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(
                                city,
                                style: const TextStyle(
                                    fontFamily: 'Cairo', fontSize: 13),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  _buildTextField(theme, 'العنوان التفصيلي', _addressController, Icons.home_outlined),
                  _buildTextField(theme, 'رقم الهاتف', _phoneController, Icons.phone_outlined,
                      inputType: TextInputType.phone),
                  _buildTextField(theme, 'نبذة تعريفية', _bioController, Icons.info_outline,
                      maxLines: 3),
                ],
              ),
              const SizedBox(height: 16),

              // ── مفتاح الإتاحة ──
              _buildCard(
                theme,
                isDark,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.toggle_on_rounded,
                            color: _isAvailable ? Colors.green : Colors.grey, size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'حالة التوفر',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _isAvailable
                                    ? 'أنت متاح حالياً للاستفسارات'
                                    : 'أنت مشغول حالياً',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: _isAvailable ? Colors.green : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isAvailable,
                          onChanged: (val) => setState(() => _isAvailable = val),
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── معرض الأعمال (للجميع) ──
              _sectionHeader(theme, 'معرض الأعمال', Icons.photo_library_outlined),
              const SizedBox(height: 12),
              _buildCard(
                theme,
                isDark,
                children: [
                  ..._portfolioControllers.asMap().entries.map((entry) {
                    final i = entry.key;
                    return _buildRemovableField(
                      theme,
                      'رابط الصورة ${i + 1}',
                      entry.value,
                      Icons.image_outlined,
                      () => setState(() {
                        _portfolioControllers[i].dispose();
                        _portfolioControllers.removeAt(i);
                      }),
                    );
                  }),
                  _buildAddButton(
                    theme,
                    'إضافة صورة / رابط',
                    () => setState(() => _portfolioControllers.add(TextEditingController())),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── حقول الكوادر العلمية ──
              if (_isScientific) ...[
                _sectionHeader(theme, 'روابط المشاريع الخارجية', Icons.code_rounded),
                const SizedBox(height: 12),
                _buildCard(
                  theme,
                  isDark,
                  children: [
                    ..._projectControllers.asMap().entries.map((entry) {
                      final i = entry.key;
                      return _buildRemovableField(
                        theme,
                        'رابط مشروع (GitHub/Behance...)',
                        entry.value,
                        Icons.link_rounded,
                        () => setState(() {
                          _projectControllers[i].dispose();
                          _projectControllers.removeAt(i);
                        }),
                      );
                    }),
                    _buildAddButton(
                      theme,
                      'إضافة رابط مشروع',
                      () => setState(() => _projectControllers.add(TextEditingController())),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _sectionHeader(theme, 'الشهادات الأكاديمية', Icons.workspace_premium_outlined),
                const SizedBox(height: 12),
                _buildCard(
                  theme,
                  isDark,
                  children: [
                    ..._certificateControllers.asMap().entries.map((entry) {
                      final i = entry.key;
                      return _buildRemovableField(
                        theme,
                        'الشهادة ${i + 1}',
                        entry.value,
                        Icons.school_outlined,
                        () => setState(() {
                          _certificateControllers[i].dispose();
                          _certificateControllers.removeAt(i);
                        }),
                      );
                    }),
                    _buildAddButton(
                      theme,
                      'إضافة شهادة',
                      () => setState(() => _certificateControllers.add(TextEditingController())),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _sectionHeader(theme, 'رابط السيرة الذاتية (CV)', Icons.description_outlined),
                const SizedBox(height: 12),
                _buildCard(
                  theme,
                  isDark,
                  children: [
                    _buildTextField(theme, 'رابط ملف CV', _cvUrlController, Icons.insert_drive_file_outlined),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // ── تعليقات العملاء (للمهني) ──
              _sectionHeader(theme, 'تعليقات العملاء', Icons.rate_review_outlined),
              const SizedBox(height: 12),
              _WorkerReviewsForPro(
                workerId: widget.worker.id,
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: theme.colorScheme.primary, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(ThemeData theme, bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: inputType,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 18),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRemovableField(
    ThemeData theme,
    String label,
    TextEditingController controller,
    IconData icon,
    VoidCallback onRemove,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: label,
                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 17),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(ThemeData theme, String label, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.primary, size: 20),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Reviews Section for Professional (with reply & report)
// ─────────────────────────────────────────
class _WorkerReviewsForPro extends StatelessWidget {
  final String workerId;
  final ThemeData theme;
  final bool isDark;
  const _WorkerReviewsForPro({required this.workerId, required this.theme, required this.isDark});

  void _showReplySheet(BuildContext context, String docId) {
    final replyController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'الرد على التعليق',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: replyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'اكتب ردك هنا...',
                    hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () async {
                      final text = replyController.text.trim();
                      if (text.isEmpty) return;
                      await FirebaseFirestore.instance
                          .collection('workers')
                          .doc(workerId)
                          .collection('reviews')
                          .doc(docId)
                          .update({'replyText': text});
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'إرسال الرد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, String docId) {
    final reasonController = TextEditingController();
    final proofController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.flag_rounded, color: Colors.red.shade700),
                const SizedBox(width: 8),
                const Text('إبلاغ عن تعليق', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'يمكنك الإبلاغ عن التعليقات الكيدية مع إرفاق دليل.',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'سبب البلاغ...',
                      hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: proofController,
                    decoration: InputDecoration(
                      hintText: 'رابط صورة الدليل (اختياري)',
                      hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      prefixIcon: Icon(Icons.image_outlined, color: theme.colorScheme.primary, size: 18),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (reasonController.text.trim().isEmpty) return;
                  final user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance.collection('reports').add({
                    'type': 'worker_review',
                    'workerId': workerId,
                    'reviewId': docId,
                    'reporterId': user?.uid ?? 'anonymous',
                    'reason': reasonController.text.trim(),
                    'proofUrl': proofController.text.trim(),
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إرسال البلاغ بنجاح', style: TextStyle(fontFamily: 'Cairo')),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'إرسال البلاغ',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .doc(workerId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                'لا توجد تعليقات بعد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          );
        }
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final rating = (data['rating'] ?? 0).toDouble();
            final comment = data['comment'] ?? '';
            final userName = data['userName'] ?? 'مستخدم';
            final replyText = data['replyText'] as String?;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.person, color: theme.colorScheme.primary, size: 17),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      // نجوم التقييم
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 13,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),

                  // رد المهني الموجود
                  if (replyText != null && replyText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                          right: BorderSide(color: theme.colorScheme.primary, width: 3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ردك:',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            replyText,
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // أزرار الرد والإبلاغ
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // زر الإبلاغ
                      InkWell(
                        onTap: () => _showReportDialog(context, doc.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.flag_outlined, size: 15, color: Colors.red.shade400),
                              const SizedBox(width: 4),
                              Text(
                                'إبلاغ',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // زر الرد
                      InkWell(
                        onTap: () => _showReplySheet(context, doc.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.reply_rounded, size: 15, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                'رد',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
