import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import 'package:yemen_store/features/markets/data/models/market_model.dart';
import '../widgets/market_expansion_card.dart';

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
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('خطأ في تحميل البيانات: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('لا توجد أسواق حالياً'));
                }

                final marketDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: marketDocs.length,
                  itemBuilder: (context, index) {
                    final marketData =
                        marketDocs[index].data() as Map<String, dynamic>;
                    final marketId = marketDocs[index].id;

                    return StreamBuilder<QuerySnapshot>(
                      stream: marketDocs[index].reference
                          .collection('categories')
                          .snapshots(),
                      builder: (context, catSnapshot) {
                        final categories = (catSnapshot.data?.docs ?? []).map((
                          doc,
                        ) {
                          return CategoryModel.fromFirestore(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          );
                        }).toList();

                        final market = MarketModel.fromFirestore(
                          marketData,
                          marketId,
                          categories: categories,
                        );

                        return MarketExpansionCard(
                          market: market,
                          isDark: isDark,
                        );
                      },
                    );
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
