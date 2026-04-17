
import 'package:flutter/material.dart';
import 'package:yemen_store/features/markets/data/models/market_model.dart';
import '../widgets/market_expansion_card.dart';

class MarketsScreen extends StatelessWidget {
  static const String id = 'markets_screen';
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("كل الأسواق والأقسام")),
      body: Column(
        children: [
          _buildSearchHeader(isDark),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: mockMarkets.length,
              itemBuilder: (context, index) {
                return MarketExpansionCard(
                  market: mockMarkets[index],
                  isDark: isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: const TextField(
        decoration: InputDecoration(
          hintText: "إبحث عن سوق او قسم...",
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}