import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/theme/app_colors.dart';
import '../../core/professional_constants.dart';
import '../providers/workers_providers.dart';
import '../../domain/entities/worker_entity.dart';
import '../../../../core/widgets/smart_search_delegate.dart';

class WorkersListScreen extends ConsumerWidget {
  final String category;
  const WorkersListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final workersAsync = ref.watch(workersByCityProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    // ── مراقبة بروفايل المهني الحالي للزر الذكي ──
    final currentWorkerAsync = ref.watch(currentWorkerProfileProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          title: Text(
            'المهنيون المتاحون',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: theme.appBarTheme.foregroundColor,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: theme.colorScheme.primary),
            onPressed: () => context.pop(),
          ),
          actions: [
            // ── زر لوحة التحكم الذكي ──
            currentWorkerAsync.when(
              data: (worker) {
                if (worker == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.workerEditProfile, extra: worker),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                    ),
                    icon: Icon(Icons.manage_accounts_rounded,
                        size: 18, color: theme.colorScheme.primary),
                    label: Text(
                      'لوحتي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            IconButton(
              icon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
              onPressed: () async {
                final result = await showSearch(
                  context: context,
                  delegate: SmartSearchDelegate(
                    ref: ref,
                    searchHint: "ابحث عن مهندس، سباك، نجار...",
                  ),
                );
                if (result != null && result.isNotEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('جاري البحث عن: $result', style: const TextStyle(fontFamily: 'Cairo'))),
                    );
                  }
                }
              },
            ),
          ],
        ),

        // ── الشريط الأفقي لتصفية المدن ──
        body: Column(
          children: [
            _CityFilterBar(
              selectedCity: selectedCity,
              onCitySelected: (city) {
                ref.read(selectedCityProvider.notifier).state = city;
              },
              theme: theme,
            ),

            // ── قائمة المهنيين ──
            Expanded(
              child: workersAsync.when(
                data: (workers) {
                  // فلترة بالتصنيف الممرر من الشاشة السابقة
                  final filtered = workers.where((w) {
                    if (category == 'الكل') return true;
                    return w.category.contains(category) ||
                        w.profession.contains(category);
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState(context, theme, selectedCity);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return WorkerCard(worker: filtered[index]);
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'حدث خطأ: $e',
                    style: TextStyle(
                        color: theme.colorScheme.error,
                        fontFamily: 'Cairo'),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── زر التسجيل كمهني ──
        floatingActionButton: currentWorkerAsync.when(
          data: (worker) {
            // إخفاء الزر إذا كان مسجلاً مسبقاً
            if (worker != null) return null;
            return FloatingActionButton.extended(
              heroTag: 'worker_register',
              onPressed: () => context.push(AppRoutes.workerRegistration),
              backgroundColor: theme.colorScheme.primary,
              icon: Icon(Icons.person_add_rounded,
                  color: theme.colorScheme.onPrimary),
              label: Text(
                'سجّل كمهني',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            );
          },
          loading: () => null,
          error: (_, __) => FloatingActionButton.extended(
            heroTag: 'worker_register',
            onPressed: () => context.push(AppRoutes.workerRegistration),
            backgroundColor: theme.colorScheme.primary,
            icon: Icon(Icons.person_add_rounded,
                color: theme.colorScheme.onPrimary),
            label: Text(
              'سجّل كمهني',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, String city) {
    final bool hasCityFilter = city != 'كل المدن';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasCityFilter
                  ? Icons.location_off_outlined
                  : Icons.engineering_outlined,
              size: 52,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasCityFilter
                ? 'لا يوجد مهنيون في $city حالياً'
                : 'لا يوجد مهنيون في هذه الفئة حالياً',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'كن أول من يسجل!',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🏙️  شريط تصفية المدن الأفقي
// ─────────────────────────────────────────────────────────────
class _CityFilterBar extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onCitySelected;
  final ThemeData theme;

  const _CityFilterBar({
    required this.selectedCity,
    required this.onCitySelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cities = ['كل المدن', ...ProfessionalConstants.yemeniCities];

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final city = cities[i];
          final isSelected = city == selectedCity;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: () => onCitySelected(city),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  city,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🪪  Worker Card (Component مستقل قابل لإعادة الاستخدام)
// ─────────────────────────────────────────────────────────────
class WorkerCard extends StatelessWidget {
  final WorkerEntity worker;
  const WorkerCard({super.key, required this.worker});

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      await launchUrl(uri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح تطبيق الاتصال', style: TextStyle(fontFamily: 'Cairo'))),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/967$clean');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح تطبيق واتساب', style: TextStyle(fontFamily: 'Cairo'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.workerProfile, extra: worker),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── معلومات العامل ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── صورة + نقطة الحالة المضيئة ──
                  Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: worker.imageUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  worker.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person,
                                    color: theme.colorScheme.primary,
                                    size: 36,
                                  ),
                                ),
                              )
                            : Icon(Icons.person,
                                color: theme.colorScheme.primary, size: 36),
                      ),
                      // نقطة الحالة المضيئة
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: _StatusDot(isAvailable: worker.isAvailable),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // ── المعلومات ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الاسم + شارة التوثيق
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                worker.name,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (worker.isVerified) ...[
                              const SizedBox(width: 5),
                              const Icon(Icons.verified,
                                  color: AppColors.iconBlue, size: 17),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),

                        // التخصص الدقيق
                        Text(
                          worker.profession,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),

                        // شارة القسم الرئيسي
                        if (worker.category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              worker.category,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 9,
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 5),

                        // المدينة + سنوات الخبرة
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45)),
                            const SizedBox(width: 2),
                            Text(
                              worker.city,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.work_history_outlined,
                                size: 13,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45)),
                            const SizedBox(width: 2),
                            Text(
                              '${worker.experienceYears} سنوات',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // النجوم
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < worker.rating.floor()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 14,
                                color: Colors.amber,
                              );
                            }),
                            const SizedBox(width: 4),
                            Text(
                              worker.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── شارة الجاهزية ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: worker.isAvailable
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.error.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      worker.isAvailable ? 'متاح' : 'مشغول',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: worker.isAvailable
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ──
            Divider(
                height: 1,
                color: theme.dividerColor.withValues(alpha: 0.5)),

            // ── أزرار التفاعل السريع ──
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _launchPhone(context, worker.phone),
                    icon: Icon(Icons.call_rounded,
                        size: 17, color: theme.colorScheme.primary),
                    label: Text(
                      'اتصال',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                VerticalDivider(
                    width: 1,
                    color: theme.dividerColor.withValues(alpha: 0.5)),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _launchWhatsApp(context, worker.phone),
                    icon: const Icon(Icons.chat_rounded,
                        size: 17, color: Color(0xFF25D366)),
                    label: const Text(
                      'واتساب',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Color(0xFF25D366),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🟢  نقطة الحالة المضيئة (Animated Pulse)
// ─────────────────────────────────────────────────────────────
class _StatusDot extends StatefulWidget {
  final bool isAvailable;
  const _StatusDot({required this.isAvailable});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isAvailable) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isAvailable ? AppColors.success : AppColors.iconGrey;
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Transform.scale(
        scale: widget.isAvailable ? _scale.value : 1.0,
        child: Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: widget.isAvailable
                ? [
                    BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.5),
                        blurRadius: 6)
                  ]
                : [],
          ),
        ),
      ),
    );
  }
}
