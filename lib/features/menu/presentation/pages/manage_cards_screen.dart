import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/features/menu/presentation/widgets/menu_card_panel.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/card_entity.dart';
import '../providers/cards_providers.dart';

class ManageCardsScreen extends ConsumerStatefulWidget {
  const ManageCardsScreen({super.key});

  @override
  ConsumerState<ManageCardsScreen> createState() => _ManageCardsScreenState();
}

class _ManageCardsScreenState extends ConsumerState<ManageCardsScreen> {
  final List<String> _categories = ['أبو 200', 'أبو 500', 'أبو 1000'];
  String _selectedCategory = 'أبو 200';
  String? _latestFileName;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardsAsync = ref.watch(cardStatsStreamProvider);
    final networkInfoAsync = ref.watch(myNetworkInfoStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة الكروت',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.primary,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: SafeArea(
        child: cardsAsync.when(
          loading: () => const Center(child: CustomLoadingIndicator()),
          error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
          data: (cards) {
            // Calculate summary
            int totalSold = cards.fold(0, (sum, item) => sum + item.sold);
            int totalRevenue = cards.fold(
              0,
              (sum, item) => sum + int.parse(item.revenue.replaceAll(RegExp(r'[^0-9]'), '')),
            );
            
            // Smart Calculations
            int currentStockValue = cards.fold(0, (sum, item) {
              // Extract numeric value from category string (e.g. "أبو 200" -> 200)
              int cardPrice = int.tryParse(item.category.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              return sum + (item.remaining * cardPrice);
            });
            
            CardEntity? bestSeller;
            if (cards.isNotEmpty) {
              bestSeller = cards.reduce((curr, next) => curr.sold > next.sold ? curr : next);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Network Info Section
                  networkInfoAsync.when(
                    data: (network) {
                      if (network == null) return const SizedBox();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? colorScheme.surface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(
                                alpha: 0.05,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  child: Icon(
                                    Icons.wifi_tethering,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        network['name'] ?? 'اسم الشبكة',
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      Text(
                                        network['description'] ?? 'وصف الشبكة',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Navigate to edit network info (can be added later)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'سيتم إضافة شاشة تعديل الشبكة قريباً',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                  color: colorScheme.primary,
                                  tooltip: 'تعديل بيانات الشبكة',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${network['city']} - ${network['area']}',
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: network['status'] == 'active'
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    network['status'] == 'active'
                                        ? 'نشط'
                                        : 'قيد المراجعة',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: network['status'] == 'active'
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Quick Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildQuickAction(
                                  context: context,
                                  icon: Icons.share,
                                  label: 'مشاركة',
                                  color: colorScheme.primary,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم نسخ رابط الشبكة')),
                                    );
                                  },
                                ),
                                _buildQuickAction(
                                  context: context,
                                  icon: network['status'] == 'active' ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                  label: network['status'] == 'active' ? 'إيقاف مؤقت' : 'تفعيل',
                                  color: network['status'] == 'active' ? Colors.orange : Colors.green,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('جاري تغيير حالة الشبكة...')),
                                    );
                                  },
                                ),
                                _buildQuickAction(
                                  context: context,
                                  icon: Icons.settings_input_antenna,
                                  label: 'إعدادات متقدمة',
                                  color: colorScheme.secondary,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('سيتم توفير الإعدادات المتقدمة قريباً')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CustomLoadingIndicator()),
                    error: (err, _) => Text('خطأ: $err'),
                  ),

                  
                  // Smart Alerts Section
                  if (cards.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        final lowStockCards = cards.where((c) => c.remaining < 50 && c.remaining > 0).toList();
                        final outOfStockCards = cards.where((c) => c.remaining == 0).toList();
                        
                        return Column(
                          children: [
                            if (outOfStockCards.isNotEmpty)
                              _buildSmartAlert(
                                context,
                                icon: Icons.error_outline,
                                color: Colors.red,
                                message: 'نفذت باقات (${outOfStockCards.map((c) => c.category).join(', ')}). ستتوقف المبيعات لهذه الفئة حتى تقوم برفع كروت جديدة.',
                              ),
                            if (lowStockCards.isNotEmpty)
                              _buildSmartAlert(
                                context,
                                icon: Icons.warning_amber_rounded,
                                color: Colors.orange,
                                message: 'تنبيه ذكي: باقات (${lowStockCards.map((c) => c.category).join(', ')}) أوشكت على النفاذ (الكمية أقل من 50).',
                              ),
                            if (bestSeller != null && bestSeller!.sold > 0)
                              _buildSmartAlert(
                                context,
                                icon: Icons.trending_up,
                                color: Colors.green,
                                message: 'تحليل المبيعات: باقة "${bestSeller!.category}" هي الأكثر طلباً لديك. تأكد من توفرها دائماً.',
                              ),
                          ],
                        );
                      },
                    ),
                  ],

                  MenuCardPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إدارة الكروت ',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.filter_list, color: colorScheme.primary),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          style: textTheme.bodyMedium,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            hintText: 'اختر فئة الكروت',
                            hintStyle: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.65,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          items: _categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'ارفع ملف كروت ميكروتيك لتتمكن من عرض الكروت المتاحة ومتابعة الإحصائيات اليومية.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.78,
                            ),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Form Validation UX Rule: Disable if no file selected
                        ElevatedButton.icon(
                          onPressed: _latestFileName == null
                              ? () async {
                                  // محاكاة اختيار ملف
                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );
                                  setState(() {
                                    _latestFileName =
                                        'mikrotik_cards_${_selectedCategory}.xlsx';
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.attach_file),
                          label: Text(
                            'اختيار ملف',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Form Validation UX Rule: زر الرفع يظهر فقط عند وجود ملف ويكون معطلاً أثناء الرفع
                        if (_latestFileName != null)
                          ElevatedButton.icon(
                            onPressed: _isUploading
                                ? null
                                : () async {
                                    setState(() {
                                      _isUploading = true;
                                    });
                                    // Form Validation UX Rule: Disabled while uploading
                                    // Simulation of real file parsing
                                    await showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('معالجة الكروت'),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 16),
                                            Text('جاري تحليل ملف الإكسل والميكروتيك...'),
                                          ],
                                        ),
                                      ),
                                    );
                                    
                                    await Future.delayed(const Duration(seconds: 2));
                                    if (mounted) Navigator.pop(context); // Close processing dialog
                                    
                                    // Show simulation input dialog for real demo
                                    if (mounted) {
                                      final countController = TextEditingController();
                                      final isAdded = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('تأكيد الرفع'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('تم اكتشاف كروت فئة "$_selectedCategory" بنجاح.'),
                                              const SizedBox(height: 10),
                                              TextField(
                                                controller: countController,
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  labelText: 'أدخل عدد الكروت المكتشفة (للتجربة)',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('إلغاء'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (countController.text.isNotEmpty) {
                                                  Navigator.pop(ctx, true);
                                                }
                                              },
                                              child: const Text('إضافة لقاعدة البيانات'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (isAdded == true && countController.text.isNotEmpty) {
                                        final count = int.tryParse(countController.text) ?? 100;
                                        // Retrieve existing if any to accumulate
                                        final existingCard = cards.where((c) => c.category == _selectedCategory).firstOrNull;
                                        
                                        final newCard = CardEntity(
                                          category: _selectedCategory,
                                          remaining: (existingCard?.remaining ?? 0) + count,
                                          sold: existingCard?.sold ?? 0,
                                          revenue: existingCard?.revenue ?? '0',
                                          total: (existingCard?.total ?? 0) + count,
                                          colorHex: _getCategoryColor(_selectedCategory),
                                        );
                                        await ref.read(addCardCategoryUseCaseProvider).call(newCard);
                                        
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('تم رفع $count كرت بنجاح!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      }
                                    }

                                    setState(() {
                                      _isUploading = false;
                                      _latestFileName = null; // Reset
                                    });
                                  },
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.cloud_upload),
                            label: Text(
                              _isUploading
                                  ? 'جاري الرفع...'
                                  : 'اعتماد ورفع الكروت',
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

                        const SizedBox(height: 14),
                        if (_latestFileName != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ملف جاهز للرفع: $_latestFileName',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: isDark
                                          ? Colors.green.shade300
                                          : Colors.green.shade900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _latestFileName = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  MenuCardPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إحصائيات الكروت الحالية',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (cards.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'لا توجد باقات مرفوعة حالياً. ابدأ برفع ملف كروت.',
                              ),
                            ),
                          )
                        else
                          Table(
                            border: TableBorder.symmetric(
                              inside: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                children: [
                                  _buildTableHeader('الفئة'),
                                  _buildTableHeader('الكروت المتبقية'),
                                  _buildTableHeader('الكروت المباعة اليوم'),
                                  _buildTableHeader('الإيرادات اليومية (ريال)'),
                                ],
                              ),
                              for (final stat in cards)
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? colorScheme.surface
                                        : Colors.white,
                                  ),
                                  children: [
                                    _buildTableCell(Text(stat.category)),
                                    _buildTableCell(
                                      _buildProgressCell(
                                        value: stat.remaining,
                                        total: stat.total,
                                        color: Color(
                                          int.parse(stat.colorHex, radix: 16),
                                        ),
                                      ),
                                    ),
                                    _buildTableCell(Text('${stat.sold}')),
                                    _buildTableCell(Text(stat.revenue)),
                                  ],
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  MenuCardPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملخص المبيعات (اليوم)',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow('إجمالي المبيعات:', '$totalSold كرت'),
                        const SizedBox(height: 10),
                        _buildSummaryRow(
                          'إجمالي الإيرادات اليومية:',
                          '$totalRevenue ريال',
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        _buildSummaryRow(
                          'قيمة المخزون الحالي:',
                          '$currentStockValue ريال',
                          valueColor: Colors.green.shade700,
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: Text(
                            'عرض التقارير الكاملة',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getCategoryColor(String category) {
    if (category.contains('200')) return 'FFFF9800'; // Orange
    if (category.contains('500')) return 'FF4CAF50'; // Green
    if (category.contains('1000')) return 'FF2196F3'; // Blue
    return 'FF9C27B0'; // Purple
  }

  Widget _buildSmartAlert(BuildContext context, {required IconData icon, required Color color, required String message}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? color.withValues(alpha: 0.8) : color.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTableCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Center(child: child),
    );
  }

  Widget _buildProgressCell({
    required int value,
    required int total,
    required Color color,
  }) {
    final widthFactor = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Container(
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            FractionallySizedBox(
              widthFactor: widthFactor,
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  '$value',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
