import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopUpScreen extends StatefulWidget {
  static const String id = 'top_up_screen';
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedProvider = 'غير معروف';
  String _serviceType = 'رصيد';
  bool _hasDebt = false;
  int? _selectedPackageIndex;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static final Map<String, Map<String, dynamic>> _providerData = {
    'Yemen Mobile': {
      'color': const Color(0xFFE53935),
      'logo': 'assets/images/yemenmobile.jpg',
      'prefix': ['77', '78'],
    },
    'YOU': {
      'color': const Color(0xFFF9A825),
      'logo': 'assets/images/you.png',
      'prefix': ['73'],
    },
    'Sabafon': {
      'color': const Color(0xFFB71C1C),
      'logo': 'assets/images/sabafon.jpg',
      'prefix': ['71'],
    },
    'Y': {
      'color': const Color(0xFF1565C0),
      'logo': 'assets/images/Y.jpg',
      'prefix': ['70'],
    },
  };

  static final Map<String, List<Map<String, String>>> _allPackages = {
    'Yemen Mobile': [
      {'title': 'باقة مزايا فورجي الشهرية', 'price': '4000', 'gb': '10 GB', 'min': '500 دقيقة', 'sms': '500 رسالة'},
      {'title': 'باقة هدايا نت 20 جيجا', 'price': '3000', 'gb': '20 GB', 'min': '0', 'sms': '0'},
      {'title': 'باقة كلام الشهرية', 'price': '1500', 'gb': '1 GB', 'min': '400 دقيقة', 'sms': '400 رسالة'},
    ],
    'YOU': [
      {'title': 'باقة ميكس الأسبوعية', 'price': '1200', 'gb': '2 GB', 'min': '100 دقيقة', 'sms': '100 رسالة'},
      {'title': 'باقة سوبر نت الشهرية', 'price': '5000', 'gb': '15 GB', 'min': '0', 'sms': '0'},
    ],
    'Sabafon': [
      {'title': 'باقة ليالي فورجي', 'price': '2500', 'gb': '8 GB (ليلي)', 'min': '0', 'sms': '0'},
      {'title': 'باقة التواصل الاجتماعي', 'price': '1000', 'gb': 'تواصل اجتماعي', 'min': '50 دقيقة', 'sms': '50 رسالة'},
    ],
    'Y': [
      {'title': 'باقة واي فورجي', 'price': '3000', 'gb': '7 GB', 'min': '0', 'sms': '0'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _detectProvider(String value) {
    String newProvider = 'غير معروف';
    bool hasDebt = false;
    for (final entry in _providerData.entries) {
      final prefixes = entry.value['prefix'] as List<String>;
      if (prefixes.any((p) => value.startsWith(p))) {
        newProvider = entry.key;
        hasDebt = entry.key == 'Yemen Mobile';
        break;
      }
    }
    if (value.isEmpty) newProvider = 'غير معروف';
    setState(() {
      _selectedProvider = newProvider;
      _hasDebt = hasDebt;
      _selectedPackageIndex = null;
      _animController.forward(from: 0);
    });
  }

  Color _providerColor(ThemeData theme) {
    return (_providerData[_selectedProvider]?['color'] as Color?) ??
        theme.colorScheme.primary;
  }

  bool get _isKnown =>
      _selectedProvider != 'غير معروف' && _selectedProvider != 'شبكة أخرى';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provColor = _providerColor(theme);
    final packages = _allPackages[_selectedProvider] ?? [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // ── Sliver AppBar بألوان الشبكة ──
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: _isKnown ? provColor : theme.colorScheme.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isKnown
                          ? [provColor, provColor.withValues(alpha: 0.6)]
                          : [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 46, right: 20, left: 20, bottom: 16),
                      child: Row(
                        children: [
                          // لوغو المشغّل
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isKnown
                                ? Container(
                                    key: ValueKey(_selectedProvider),
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        _providerData[_selectedProvider]!['logo'] as String,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.cell_tower,
                                          color: provColor,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    key: const ValueKey('unknown'),
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.sim_card_outlined,
                                        color: Colors.white, size: 28),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isKnown ? _selectedProvider : 'شحن رصيد',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _isKnown
                                      ? 'تم التعرف على الشبكة تلقائياً ✓'
                                      : 'أدخل رقم الهاتف للكشف التلقائي',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isKnown)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── المحتوى ──
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── حقل رقم الهاتف ──
                  _buildPhoneField(theme, isDark),
                  const SizedBox(height: 14),

                  // ── تحذير الديون ──
                  if (_hasDebt) ...[
                    _buildDebtWarning(theme),
                    const SizedBox(height: 14),
                  ],

                  // ── Toggle رصيد / باقة ──
                  _buildServiceToggle(theme),
                  const SizedBox(height: 20),

                  // ── مبالغ سريعة ──
                  if (_serviceType == 'رصيد') ...[
                    _sectionLabel(theme, 'مبالغ سريعة', Icons.flash_on_rounded),
                    const SizedBox(height: 10),
                    _buildQuickAmounts(theme, provColor),
                    const SizedBox(height: 20),
                  ],

                  // ── الباقات ──
                  _sectionLabel(theme, 'الباقات المتاحة', Icons.inventory_2_outlined),
                  const SizedBox(height: 10),
                  if (!_isKnown)
                    _buildPlaceholderCard(theme, isDark, 'أدخل رقم الهاتف لعرض الباقات')
                  else if (packages.isEmpty)
                    _buildPlaceholderCard(theme, isDark, 'لا توجد باقات لهذه الشبكة')
                  else
                    ...packages.asMap().entries.map((entry) {
                      return _buildPackageCard(
                        theme,
                        isDark,
                        provColor,
                        entry.value,
                        entry.key,
                      );
                    }),

                  const SizedBox(height: 20),

                  // ── زر التأكيد ──
                  _buildConfirmButton(theme, provColor),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(theme, 'رقم الهاتف', Icons.phone_android_rounded),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 12,
              ),
            ],
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            onChanged: _detectProvider,
            decoration: InputDecoration(
              hintText: 'مثال: 772345678',
              hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
              prefixIcon: Icon(Icons.phone_rounded, color: theme.colorScheme.primary),
              suffix: _isKnown
                  ? Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _providerColor(theme).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedProvider,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _providerColor(theme),
                        ),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDebtWarning(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'قد يحتوي هذا الخط على ديون. تأكد من رصيدك قبل الشحن.',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.red.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceToggle(ThemeData theme) {
    final provColor = _isKnown ? _providerColor(theme) : theme.colorScheme.primary;
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: ['رصيد', 'باقة'].map((label) {
          final selected = _serviceType == label;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _serviceType = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? provColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: selected
                      ? [BoxShadow(color: provColor.withValues(alpha: 0.3), blurRadius: 8)]
                      : [],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: selected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickAmounts(ThemeData theme, Color provColor) {
    const amounts = ['500', '1,000', '2,500', '5,000', '10,000'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amounts.map((amount) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  provColor.withValues(alpha: 0.12),
                  provColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: provColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              '$amount YR',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: provColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPackageCard(
    ThemeData theme,
    bool isDark,
    Color provColor,
    Map<String, String> pkg,
    int index,
  ) {
    final isSelected = _selectedPackageIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPackageIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? provColor : theme.dividerColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? provColor.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: isSelected ? 16 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  // أيقونة الشبكة
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: provColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.wifi_rounded, color: provColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pkg['title'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${pkg['price']} YR / شهر',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: provColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // مؤشر الاختيار
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? provColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? provColor : theme.dividerColor,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ],
              ),
              // تفاصيل الباقة
              if (isSelected) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: provColor.withValues(alpha: 0.2)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if ((pkg['gb'] ?? '0') != '0')
                      _packageStat(provColor, Icons.data_usage_rounded, pkg['gb']!, 'إنترنت'),
                    if ((pkg['min'] ?? '0') != '0')
                      _packageStat(provColor, Icons.call_rounded, pkg['min']!, 'دقائق'),
                    if ((pkg['sms'] ?? '0') != '0')
                      _packageStat(provColor, Icons.sms_rounded, pkg['sms']!, 'رسائل'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _packageStat(Color color, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCard(ThemeData theme, bool isDark, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildConfirmButton(ThemeData theme, Color provColor) {
    final activeColor = _isKnown ? provColor : theme.colorScheme.primary;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: activeColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          shadowColor: activeColor.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'تأكيد العملية',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 17),
        const SizedBox(width: 6),
        Text(
          label,
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
}
