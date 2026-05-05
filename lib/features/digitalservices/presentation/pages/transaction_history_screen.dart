import 'package:flutter/material.dart';

class Transaction {
  final String title;
  final String category;
  final String id;
  final String amount;
  final String date;
  final String status;
  final IconData icon;
  final Color color;

  const Transaction({
    required this.title,
    required this.category,
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    required this.icon,
    required this.color,
  });
}

class TransactionHistoryScreen extends StatefulWidget {
  static const String id = 'transaction_history_screen';
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Transaction> _transactions = const [
    Transaction(
      title: 'كرت سوبر نت 500',
      category: 'واي فاي',
      id: 'WF-9922',
      amount: '500 ر.ي-',
      date: '18 مارس 2026',
      status: 'ناجحة',
      icon: Icons.wifi,
      color: Colors.blue,
    ),
    Transaction(
      title: 'باقة مزايا شهرية',
      category: 'باقات',
      id: 'PK-1020',
      amount: '2,500 ر.ي-',
      date: '17 مارس 2026',
      status: 'ناجحة',
      icon: Icons.cloud_done,
      color: Colors.lightBlue,
    ),
    Transaction(
      title: 'سداد فاتورة مياه',
      category: 'فواتير',
      id: 'INV-882',
      amount: '1,200 ر.ي-',
      date: '15 مارس 2026',
      status: 'معلقة',
      icon: Icons.water_drop,
      color: Colors.cyan,
    ),
    Transaction(
      title: 'تحويل إلى محمد علي',
      category: 'تحويل',
      id: 'TR-550',
      amount: '10,000 ر.ي-',
      date: '14 مارس 2026',
      status: 'ناجحة',
      icon: Icons.send_rounded,
      color: Colors.teal,
    ),
    Transaction(
      title: 'كرت يمن فاي 1000',
      category: 'واي فاي',
      id: 'WF-4411',
      amount: '1,000 ر.ي-',
      date: '12 مارس 2026',
      status: 'ناجحة',
      icon: Icons.wifi,
      color: Colors.blue,
    ),
    Transaction(
      title: 'سداد كهرباء - عداد رقمي',
      category: 'فواتير',
      id: 'INV-900',
      amount: '4,000 ر.ي-',
      date: '10 مارس 2026',
      status: 'مرفوضة',
      icon: Icons.bolt,
      color: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'سجل العمليات',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(
                child: Text(
                  'الكل',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                ),
              ),
              Tab(
                child: Text(
                  'كروت واي فاي',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                ),
              ),
              Tab(
                child: Text(
                  'رصيد باقات',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                ),
              ),
              Tab(
                child: Text(
                  'فواتير',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                ),
              ),
              Tab(
                child: Text(
                  'تحويلات',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFilteredList('الكل', theme),
            _buildFilteredList('واي فاي', theme),
            _buildFilteredList('باقات', theme),
            _buildFilteredList('فواتير', theme),
            _buildFilteredList('تحويل', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredList(String category, ThemeData theme) {
    final filtered = category == 'الكل'
        ? _transactions
        : _transactions.where((t) => t.category == category).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 70,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 10),
            Text(
              'لا توجد عمليات في قسم $category',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) =>
          _buildTransactionCard(filtered[index], theme),
    );
  }

  Widget _buildTransactionCard(Transaction item, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            item.amount,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: item.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ID: ${item.id}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            item.date,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          _buildStatusBadge(item.status, theme),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSmallAction(Icons.copy, 'نسخ', Colors.blue, theme),
                  _buildSmallAction(Icons.share, 'مشاركة', Colors.grey, theme),
                  _buildSmallAction(
                    Icons.refresh,
                    'إعادة',
                    Colors.green,
                    theme,
                  ),
                  _buildSmallAction(
                    Icons.info_outline,
                    'تفاصيل',
                    theme.colorScheme.primary,
                    theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    final statusColor = status == 'ناجحة'
        ? Colors.green
        : status == 'معلقة'
        ? Colors.orange
        : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: theme.textTheme.bodySmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSmallAction(
    IconData icon,
    String label,
    Color color,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 14, color: color),
        label: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
