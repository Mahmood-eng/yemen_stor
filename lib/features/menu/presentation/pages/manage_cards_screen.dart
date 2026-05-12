import 'package:flutter/material.dart';
import 'package:yemen_store/features/menu/presentation/widgets/menu_card_panel.dart';

class ManageCardsScreen extends StatefulWidget {
  const ManageCardsScreen({super.key});

  @override
  State<ManageCardsScreen> createState() => _ManageCardsScreenState();
}

class _ManageCardsScreenState extends State<ManageCardsScreen> {
  final List<String> _categories = ['أبو 200', 'أبو 500', 'أبو 1000'];
  String _selectedCategory = 'أبو 200';
  String _latestFileName = 'cards_list.xlsx';

  final List<Map<String, dynamic>> _cardStats = [
    {
      'category': 'أبو 200',
      'remaining': 540,
      'sold': 65,
      'revenue': '13,000',
      'total': 800,
      'color': Colors.blue,
    },
    {
      'category': 'أبو 500',
      'remaining': 320,
      'sold': 102,
      'revenue': '24,500',
      'total': 500,
      'color': Colors.orange,
    },
    {
      'category': 'أبو 1000',
      'remaining': 90,
      'sold': 30,
      'revenue': '30,000',
      'total': 120,
      'color': Colors.blue.shade700,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة الكروت',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MenuCardPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إدارة الكروت (ميكروتيك)',
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
                          color: colorScheme.onSurface.withOpacity(0.65),
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
                        color: colorScheme.onSurface.withOpacity(0.78),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _latestFileName = 'mikrotik_cards_2026.xlsx';
                        });
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        'رفع ملف الكروت',
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'آخر ملف مرفوع: $_latestFileName',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w600,
                        ),
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
                    Table(
                      border: TableBorder.symmetric(
                        inside: const BorderSide(color: Colors.transparent),
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
                        for (final stat in _cardStats)
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            children: [
                              _buildTableCell(Text(stat['category'] as String)),
                              _buildTableCell(
                                _buildProgressCell(
                                  value: stat['remaining'] as int,
                                  total: stat['total'] as int,
                                  color: stat['color'] as Color,
                                ),
                              ),
                              _buildTableCell(Text('${stat['sold']}')),
                              _buildTableCell(Text('${stat['revenue']}')),
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
                    _buildSummaryRow('إجمالي المبيعات:', '105 كرت'),
                    const SizedBox(height: 10),
                    _buildSummaryRow('إجمالي الإيرادات:', '38,000 ريال يمني'),
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
        ),
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
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            FractionallySizedBox(
              widthFactor: widthFactor,
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: color.withAlpha((0.8 * 255).round()),
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

  Widget _buildSummaryRow(String label, String value) {
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
          ),
        ),
      ],
    );
  }
}
