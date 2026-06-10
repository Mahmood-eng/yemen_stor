import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import '../providers/wallet_providers.dart';
import '../widgets/bank_card.dart';
import '../widgets/activation_sheet.dart';
import '../widgets/amount_input_field.dart';

class RechargeWalletScreen extends ConsumerStatefulWidget {
  static const String id = 'recharge_wallet_screen';
  const RechargeWalletScreen({super.key});

  @override
  ConsumerState<RechargeWalletScreen> createState() =>
      _RechargeWalletScreenState();
}

class _RechargeWalletScreenState extends ConsumerState<RechargeWalletScreen> {
  String? _selectedBank;
  String _selectedCurrency = "ر.ي";
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _uniqueCodeController = TextEditingController();

  final List<String> _currencies = ["ر.ي", "ر.س", "\$"];

  final List<Map<String, String>> banks = [
    {
      "name": "بنك الكريمي",
      "id": "kurimi",
      "icon": "assets/images/kurimiicon.png",
    },
    {
      "name": "مصرف القطيبي",
      "id": "qutaibi",
      "icon": "assets/images/qutaibiicon.png",
    },
    {"name": "جوالي", "id": "jawali", "icon": "assets/images/jawaliicon.png"},
    {
      "name": "ون كاش",
      "id": "onecash",
      "icon": "assets/images/onecashicon.jpg",
    },
    {
      "name": "بنك التضامن",
      "id": "tadamon",
      "icon": "assets/images/tadamnicon.png",
    },
    {
      "name": "بنك اليمن والكويت",
      "id": "yemenkuit",
      "icon": "assets/images/yemenKuiticon.png",
    },
  ];

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateForm);
    _uniqueCodeController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _amountController.text.trim().isNotEmpty &&
          _uniqueCodeController.text.trim().isNotEmpty &&
          _selectedBank != null;
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_validateForm);
    _uniqueCodeController.removeListener(_validateForm);
    _amountController.dispose();
    _uniqueCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitWithConfirmation() async {
    if (!_isFormValid) return;

    HapticFeedback.mediumImpact();

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال مبلغ صحيح أكبر من الصفر")),
      );
      return;
    }

    // إظهار نافذة تأكيد
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "تأكيد العملية",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: Text(
            "هل أنت متأكد من رغبتك بشحن مبلغ $amount $_selectedCurrency إلى محفظتك؟",
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "إلغاء",
                style: TextStyle(color: Colors.redAccent, fontFamily: 'Cairo'),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "نعم، اشحن رصيدي",
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      String currencyCode = "YER";
      if (_selectedCurrency == "ر.س") currencyCode = "SAR";
      if (_selectedCurrency == "\$") currencyCode = "USD";

      ref
          .read(depositNotifierProvider.notifier)
          .submitDeposit(
            amount: amount,
            currency: currencyCode,
            bankId: _selectedBank!,
            uniqueCode: _uniqueCodeController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final depositState = ref.watch(depositNotifierProvider);

    ref.listen<DepositState>(depositNotifierProvider, (previous, next) {
      if (next.isSuccess) {
        HapticFeedback.heavyImpact(); // صوت أو اهتزاز نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم إضافة الرصيد إلى محفظتك بنجاح!',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
        ref.read(depositNotifierProvider.notifier).reset();
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    String? selectedBankName = banks.firstWhere(
      (b) => b['id'] == _selectedBank,
      orElse: () => {"name": ""},
    )['name'];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تغذية رصيدي"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // حقل المبلغ المنفصل
              AmountInputField(
                controller: _amountController,
                selectedCurrency: _selectedCurrency,
                currencies: _currencies,
                onCurrencyChanged: (val) =>
                    setState(() => _selectedCurrency = val!),
              ),

              const SizedBox(height: 15),

              const Text("الرمز التعريفي / الفريد"),
              const SizedBox(height: 8),
              TextField(
                controller: _uniqueCodeController,
                decoration: const InputDecoration(
                  hintText: "أدخل المعرف المتفق عليه مع البنك",
                  prefixIcon: Icon(Icons.fingerprint),
                ),
              ),

              if (_selectedBank != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "سيتم التحقق والتحويل عبر: $selectedBankName",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 20),
              const Text("اختر وسيلة الدفع"),
              const SizedBox(height: 15),

              _buildBanksGrid(),

              const SizedBox(height: 30),

              depositState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _isFormValid ? _submitWithConfirmation : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "تأكيد العملية والاستمرار",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanksGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: banks.length,
      itemBuilder: (context, index) => BankCard(
        bank: banks[index],
        isSelected: _selectedBank == banks[index]['id'],
        onTap: () {
          setState(() => _selectedBank = banks[index]['id']);
          _validateForm();
        },
        onActivateTap: () => _showActivationSheet(banks[index]['name']!),
      ),
    );
  }

  void _showActivationSheet(String bankName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ActivationSheet(bankName: bankName),
    );
  }
}
