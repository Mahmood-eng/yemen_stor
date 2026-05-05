import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/features/markets/data/models/shop_model.dart';

import '../widgets/shop_card.dart';

class ShopsListScreen extends StatelessWidget {
  final Map<String, dynamic>? category;

  const ShopsListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final categoryName = category?['title'] ?? 'الفئة';
    final marketName = category?['marketName'] ?? 'السوق';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          title: Text(
            categoryName,
            style: theme.appBarTheme.titleTextStyle?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            _buildSearchField(theme, primaryColor),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                itemCount: _shops.length,
                itemBuilder: (context, index) {
                  return ShopCard(
                    shop: _shops[index],
                    categoryName: categoryName,
                    marketName: marketName,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: TextField(
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: "بحث عن محل في مدينة تعز...",
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: theme.hintColor,
          ),
          prefixIcon: Icon(Icons.search, color: primaryColor),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

final List<ShopModel> _shops = [
  const ShopModel(
    "سامي عدنان للأجهزة الذكية",
    "مفتوح الآن",
    "5.0",
    "شارع 26 - أحدث إصدارات iPhone و Samsung",
  ),
  const ShopModel(
    "تيك جلاكسي (Tech Galaxy)",
    "مغلق",
    "4.8",
    "المسبح - متخصصون في إكسسوارات الألعاب",
  ),
  const _Shop(
    "أيفون هب تعز (iPhone Hub)",
    "مفتوح الآن",
    "4.9",
    "شارع جمال - وكيل معتمد لمنتجات Apple",
  ),
  const _Shop(
    "عالم الموبايل (Mobile World)",
    "مفتوح الآن",
    "4.7",
    "حي الروضة - صيانة فورية وبيع مستخدم",
  ),
  const _Shop(
    "الوكالة العربية",
    "مغلق",
    "4.5",
    "التحرير الأعلى - جملة وتجزئة لكافة الأنواع",
  ),
  const _Shop(
    "سماء تعز للاتصالات",
    "مفتوح الآن",
    "4.6",
    "شارع 26 سبتمبر - خدمات الشحن والبرمجة",
  ),
  const _Shop(
    "ركن الذكاء (Smart Corner)",
    "مفتوح الآن",
    "5.0",
    "الحصب - متخصصون في Xiaomi و Huawei",
  ),
  const _Shop(
    "برج الجوال للهواتف الذكية",
    "مغلق",
    "4.4",
    "التحرير الأسفل - أجهزة لوحية ومستلزمات",
  ),
  const _Shop(
    "التقنية الحديثة (New Tech)",
    "مفتوح الآن",
    "4.8",
    "وادي القاضي - تقسيط مريح للجوالات",
  ),
  const _Shop(
    "برو موبايل (Pro Mobile)",
    "مفتوح الآن",
    "4.9",
    "التحرير الأسفل - قطع غيار أصلية",
  ),
];
