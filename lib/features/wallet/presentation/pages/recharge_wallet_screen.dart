import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bank_card.dart';
import '../widgets/activation_sheet.dart';
import '../widgets/amount_input_field.dart';

class RechargeWalletScreen extends StatefulWidget {
  static const String id = 'recharge_wallet_screen';
  const RechargeWalletScreen({super.key});

  @override
  State<RechargeWalletScreen> createState() => _RechargeWalletScreenState();
}

class _RechargeWalletScreenState extends State<RechargeWalletScreen> {
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

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => context.pop(),
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

              const Text("الرمز التعريفي / الفريد (Unique ID)"),
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

              ElevatedButton(
                onPressed: _selectedBank == null ? null : () {},
                child: const Text("تأكيد العملية والاستمرار"),
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
        onTap: () => setState(() => _selectedBank = banks[index]['id']),
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
