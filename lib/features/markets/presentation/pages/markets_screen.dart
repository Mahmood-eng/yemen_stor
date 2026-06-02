import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/features/markets/data/models/market_model.dart';
import '../widgets/market_expansion_card.dart';
import 'package:yemen_stor/core/widgets/custom_loading_indicator.dart';

class MarketsScreen extends StatelessWidget {
  static const String id = 'markets_screen';
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          " الأسواق ",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => context.push(AppRoutes.cart),
          ),
        ],
      ),

      body: Column(
        children: [
          _buildSearchHeader(isDark),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('app_data/main_config/markets')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CustomLoadingIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('خطأ في تحميل البيانات: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text('لا توجد أسواق حالياً في هذا القسم'),
                        Text(
                          'المسار: app_data/main_config/markets',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final marketDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: marketDocs.length,
                  itemBuilder: (context, index) {
                    final marketData =
                        marketDocs[index].data() as Map<String, dynamic>;
                    final marketId = marketDocs[index].id;

                    final market = MarketModel.fromFirestore(
                      marketData,
                      marketId,
                    );

                    return MarketExpansionCard(market: market, isDark: isDark);
                  },
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
