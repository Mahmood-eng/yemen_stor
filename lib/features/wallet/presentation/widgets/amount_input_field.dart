import 'package:flutter/material.dart';


class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCurrency;
  final List<String> currencies;
  final Function(String?) onCurrencyChanged;

  const AmountInputField({
    super.key,
    required this.controller,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("المبلغ المراد شحنه"), 
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20),
          decoration: InputDecoration(
            hintText: "0.00",
            
            suffixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCurrency,
                  dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  onChanged: onCurrencyChanged,
                  items: currencies.map((c) => DropdownMenuItem(
                    value: c, 
                    child: Text(c),
                  )).toList(),
                ),
              ),
            ),
            
          ),
        ),
      ],
    );
  }
}