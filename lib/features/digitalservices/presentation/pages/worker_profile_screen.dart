import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/professional_constants.dart';
import '../../domain/entities/worker_entity.dart';

class WorkerProfileScreen extends StatefulWidget {
  final WorkerEntity worker;
  const WorkerProfileScreen({super.key, required this.worker});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  double _userRating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/967$clean');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _submitReview() async {
    if (_userRating == 0 || _commentController.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(widget.worker.id)
          .collection('reviews')
          .add({
        'userId': user?.uid ?? 'anonymous',
        'userName': user?.displayName ?? 'مستخدم',
        'rating': _userRating,
        'comment': _commentController.text.trim(),
        'replyText': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Update average rating on the worker doc
      _commentController.clear();
      setState(() {
        _userRating = 0;
        _submitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة تقييمك بنجاح!', style: TextStyle(fontFamily: 'Cairo'))),
        );
      }
    } catch (e) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final w = widget.worker;
    final isScientific = ProfessionalConstants.isScientificOrConsultant(w.category);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // ── AppBar / Hero Header ──
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: theme.colorScheme.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.call_rounded, color: Colors.white),
                  onPressed: () => _launchPhone(w.phone),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_rounded, color: Color(0xFF25D366)),
                  onPressed: () => _launchWhatsApp(w.phone),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: w.imageUrl.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        w.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 44,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.person, color: Colors.white, size: 44),
                            ),
                            if (w.isVerified)
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified, color: Colors.blue, size: 20),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              w.name,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          w.profession,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                            Text(
                              w.city,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                            Text(
                              w.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats ──
                    _buildStatRow(theme, isDark, w),
                    const SizedBox(height: 20),

                    // ── النبذة ──
                    if (w.bio.isNotEmpty) ...[
                      _sectionTitle(theme, 'نبذة عن المهني', Icons.info_outline_rounded),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: _cardDecoration(theme, isDark),
                        child: Text(
                          w.bio,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            height: 1.7,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── معرض الأعمال ──
                    if (w.portfolioLinks.isNotEmpty) ...[
                      _sectionTitle(theme, 'معرض الأعمال', Icons.photo_library_outlined),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: w.portfolioLinks.length,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () => _launchUrl(w.portfolioLinks[i]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                w.portfolioLinks[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  child: Icon(Icons.image_outlined,
                                      color: theme.colorScheme.primary, size: 36),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── روابط المشاريع (للكوادر العلمية) ──
                    if (isScientific && w.projectLinks.isNotEmpty) ...[
                      _sectionTitle(theme, 'روابط المشاريع', Icons.link_rounded),
                      const SizedBox(height: 8),
                      ...w.projectLinks.map((link) => _buildLinkTile(theme, isDark, link)),
                      const SizedBox(height: 20),
                    ],

                    // ── الشهادات (للكوادر العلمية) ──
                    if (isScientific && w.certificates.isNotEmpty) ...[
                      _sectionTitle(theme, 'الشهادات الأكاديمية', Icons.workspace_premium_outlined),
                      const SizedBox(height: 8),
                      ...w.certificates.map(
                        (cert) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: _cardDecoration(theme, isDark),
                          child: Row(
                            children: [
                              Icon(Icons.school_rounded,
                                  color: theme.colorScheme.primary, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  cert,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── CV Link ──
                    if (isScientific && w.cvUrl != null && w.cvUrl!.isNotEmpty) ...[
                      _sectionTitle(theme, 'السيرة الذاتية', Icons.description_outlined),
                      const SizedBox(height: 8),
                      _buildLinkTile(theme, isDark, w.cvUrl!, label: 'عرض السيرة الذاتية (CV)'),
                      const SizedBox(height: 20),
                    ],

                    // ── التقييمات والتعليقات ──
                    _sectionTitle(theme, 'التقييمات والتعليقات', Icons.rate_review_outlined),
                    const SizedBox(height: 12),
                    _ReviewsSection(workerId: widget.worker.id, theme: theme, isDark: isDark),
                    const SizedBox(height: 24),

                    // ── إضافة تقييم ──
                    _sectionTitle(theme, 'أضف تقييمك', Icons.edit_note_rounded),
                    const SizedBox(height: 12),
                    _buildAddReviewForm(theme, isDark),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(ThemeData theme, bool isDark, WorkerEntity w) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: _cardDecoration(theme, isDark),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(theme, '${w.experienceYears}', 'سنوات خبرة', Icons.work_history_rounded),
          _verticalDivider(theme),
          _stat(theme, w.rating.toStringAsFixed(1), 'التقييم', Icons.star_rounded,
              color: Colors.amber),
          _verticalDivider(theme),
          _stat(
            theme,
            w.isAvailable ? 'متاح' : 'مشغول',
            'الحالة',
            Icons.circle,
            color: w.isAvailable ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _stat(ThemeData theme, String value, String label, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? theme.colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider(ThemeData theme) {
    return Container(width: 1, height: 40, color: theme.dividerColor);
  }

  Widget _buildLinkTile(ThemeData theme, bool isDark, String url, {String? label}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: _cardDecoration(theme, isDark),
          child: Row(
            children: [
              Icon(Icons.open_in_new_rounded, color: theme.colorScheme.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label ?? url,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddReviewForm(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(theme, isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقييمك:',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => _userRating = i + 1.0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    i < _userRating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'اكتب تعليقك هنا...',
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
              onPressed: _submitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'إرسال التقييم',
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
    );
  }

  Widget _sectionTitle(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration(ThemeData theme, bool isDark) {
    return BoxDecoration(
      color: isDark ? theme.cardColor : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
    );
  }
}

// ─────────────────────────────────────────
// Reviews Section (StreamBuilder from Firestore)
// ─────────────────────────────────────────
class _ReviewsSection extends StatelessWidget {
  final String workerId;
  final ThemeData theme;
  final bool isDark;
  const _ReviewsSection({required this.workerId, required this.theme, required this.isDark});

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
                'لا توجد تقييمات بعد. كن أول من يقيّم!',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        }
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _ReviewCard(
              docId: doc.id,
              workerId: workerId,
              data: data,
              theme: theme,
              isDark: isDark,
            );
          }).toList(),
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String docId;
  final String workerId;
  final Map<String, dynamic> data;
  final ThemeData theme;
  final bool isDark;
  const _ReviewCard({
    required this.docId,
    required this.workerId,
    required this.data,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس التعليق
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person, color: theme.colorScheme.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
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
              fontSize: 13,
              height: 1.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),

          // رد المهني (مُزاح)
          if (replyText != null && replyText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رد المهني:',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    replyText,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
