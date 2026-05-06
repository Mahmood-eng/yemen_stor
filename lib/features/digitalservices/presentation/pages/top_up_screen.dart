import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopUpScreen extends StatefulWidget {
  static const String id = 'top_up_screen';
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedProvider = 'غير معروف';
  String _serviceType = 'رصيد';
  bool _hasDebt = false;

  static final Map<String, List<Map<String, String>>> _allPackagesData = {
    'Yemen Mobile': [
      {
        'title': 'باقة مزايا فورجي الشهرية',
        'price': '4000 YR',
        'gb': '10 GB',
        'min': '500 دقيقة',
        'sms': '500 رسالة',
      },
      {
        'title': 'باقة هدايا نت 20 جيجا',
        'price': '3000 YR',
        'gb': '20 GB',
        'min': '0',
        'sms': '0',
      },
      {
        'title': 'باقة كلام الشهرية',
        'price': '1500 YR',
        'gb': '1 GB',
        'min': '400 دقيقة',
        'sms': '400 رسالة',
      },
    ],
    'YOU': [
      {
        'title': 'باقة ميكس الأسبوعية',
        'price': '1200 YR',
        'gb': '2 GB',
        'min': '100 دقيقة',
        'sms': '100 رسالة',
      },
      {
        'title': 'باقة سوبر نت الشهرية',
        'price': '5000 YR',
        'gb': '15 GB',
        'min': '0',
        'sms': '0',
      },
    ],
    'Sabafon': [
      {
        'title': 'باقة ليالي فورجي',
        'price': '2500 YR',
        'gb': '8 GB (ليلي)',
        'min': '0',
        'sms': '0',
      },
      {
        'title': 'باقة التواصل الاجتماعية',
        'price': '1000 YR',
        'gb': 'تواصل اجتماعي مفتوح',
        'min': '50 دقيقة',
        'sms': '50 رسالة',
      },
    ],
    'Y': [
      {
        'title': 'باقة واي فورجي',
        'price': '3000 YR',
        'gb': '7 GB',
        'min': '0',
        'sms': '0',
      },
    ],
  };

  void _detectProvider(String value) {
    setState(() {
      if (value.isEmpty) {
        _selectedProvider = 'غير معروف';
        _hasDebt = false;
      } else if (value.startsWith('77') || value.startsWith('78')) {
        _selectedProvider = 'Yemen Mobile';
        _hasDebt = true;
      } else if (value.startsWith('73')) {
        _selectedProvider = 'YOU';
        _hasDebt = false;
      } else if (value.startsWith('71')) {
        _selectedProvider = 'Sabafon';
        _hasDebt = false;
      } else if (value.startsWith('70')) {
        _selectedProvider = 'Y';
        _hasDebt = false;
      } else {
        _selectedProvider = 'شبكة أخرى';
        _hasDebt = false;
      }
    });
  }

  String _getProviderLogoPath() {
    switch (_selectedProvider) {
      case 'Yemen Mobile':
        return 'assets/images/yemenmobile.jpg';
      case 'YOU':
        return 'assets/images/you.png';
      case 'Sabafon':
        return 'assets/images/sabafon.jpg';
      case 'Y':
        return 'assets/images/Y.jpg';
      default:
        return '';
    }
  }

  Color _getProviderColor(ThemeData theme) {
    switch (_selectedProvider) {
      case 'Yemen Mobile':
        return Colors.red;
      case 'YOU':
        return Colors.amber.shade700;
      case 'Sabafon':
        return Colors.red.shade900;
      case 'Y':
        return Colors.blue;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final providerColor = _getProviderColor(theme);
    final logoPath = _getProviderLogoPath();
    final providerPackages = _allPackagesData[_selectedProvider] ?? [];
    final isUnknown =
        _selectedProvider == 'غير معروف' || _selectedProvider == 'شبكة أخرى';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'شحن رصيد',
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
            onPressed: () => context.pop(),
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceHeader(theme, providerColor),
              const SizedBox(height: 16),
              _buildProviderHeader(theme, logoPath, providerColor, isUnknown),
              if (_hasDebt) ...[
                const SizedBox(height: 12),
                _buildDebtWarning(theme),
              ],
              const SizedBox(height: 18),
              _buildServiceToggle(theme),
              const SizedBox(height: 16),
              _buildAmountInput(theme),
              const SizedBox(height: 14),
              _buildQuickAmounts(theme),
              const SizedBox(height: 22),
              Text(
                'الباقات المتاحة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (isUnknown)
                _buildNoProviderSection(theme)
              else if (providerPackages.isEmpty)
                _buildNoPackagesSection(theme)
              else
                Column(
                  children: providerPackages
                      .map(
                        (package) => _professionalPackageCard(
                          theme,
                          providerColor,
                          package,
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 18),
              _buildConfirmButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceHeader(ThemeData theme, Color providerColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: providerColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'رصيدك الحالي:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            '0.00 YR',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: providerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderHeader(
    ThemeData theme,
    String logoPath,
    Color providerColor,
    bool isUnknown,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnknown ? Colors.grey[200] : providerColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          if (isUnknown)
            Icon(Icons.help_outline_rounded, color: Colors.grey[700], size: 24)
          else if (logoPath.isNotEmpty)
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(logoPath, fit: BoxFit.contain),
              ),
            )
          else
            Icon(Icons.cell_tower, color: Colors.white, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedProvider,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isUnknown ? Colors.black87 : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أدخل رقم الهاتف لاكتشاف الشبكة تلقائياً',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isUnknown ? Colors.grey[700] : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (!isUnknown)
            const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
        ],
      ),
    );
  }

  Widget _buildDebtWarning(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'يبدو أن هذا الخط قد يحتوي على ديون. تأكد من رصيدك قبل الشحن.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceToggle(ThemeData theme) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [_toggleItem('رصيد', theme), _toggleItem('باقة', theme)],
      ),
    );
  }

  Widget _toggleItem(String label, ThemeData theme) {
    final isSelected = _serviceType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _serviceType = label),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.colorScheme.primary : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(ThemeData theme) {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      onChanged: _detectProvider,
      decoration: InputDecoration(
        hintText: 'أدخل رقم الهاتف',
        filled: true,
        fillColor: theme.colorScheme.surface,
        prefixIcon: Icon(Icons.phone_android, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildQuickAmounts(ThemeData theme) {
    const amounts = ['500', '1000', '2500', '5000'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: amounts.map((amount) {
        return ActionChip(
          label: Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'Cairo',
            ),
          ),
          onPressed: () {},
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: theme.dividerColor),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoProviderSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'لم يتم التعرف على شبكة الهاتف بعد. حاول إدخال رقم يبدأ بمفتاح الشبكة.',
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildNoPackagesSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'لا توجد باقات مدخلة لهذه الشبكة حتى الآن.',
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
      ),
    );
  }

  Widget _professionalPackageCard(
    ThemeData theme,
    Color providerColor,
    Map<String, String> package,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          right: BorderSide(color: providerColor.withOpacity(0.5), width: 4),
        ),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          package['title'] ?? '',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          package['price'] ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: providerColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Icon(Icons.star_rounded, color: providerColor, size: 24),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                if ((package['gb'] ?? '0') != '0')
                  _packageDetailRow(
                    theme,
                    Icons.data_usage_rounded,
                    'الإنترنت:',
                    package['gb'] ?? '',
                  ),
                if ((package['min'] ?? '0') != '0')
                  _packageDetailRow(
                    theme,
                    Icons.call_rounded,
                    'الدقائق:',
                    package['min'] ?? '',
                  ),
                if ((package['sms'] ?? '0') != '0')
                  _packageDetailRow(
                    theme,
                    Icons.sms_rounded,
                    'الرسائل:',
                    package['sms'] ?? '',
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: providerColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'اختيار الباقة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageDetailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Text(
          'تأكيد العملية',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
