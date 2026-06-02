import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/widgets/yemen_store_app_bar.dart';

import '../../../menu/presentation/pages/app_drawer.dart';
import '../widgets/markets_grid.dart';
import '../widgets/home_balance_card.dart';
import '../widgets/home_banner_slider.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // الوصول للثيم الحالي
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      // الخلفية تأخذ لون Scaffold المحدد في الثيم
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      appBar: YemenStoreAppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Image.asset(
          isDark ? 'assets/images/logo.png' : 'assets/images/logo.png',
          height: 40,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              context.push(AppRoutes.cart);
            },
          ),
        ],
      ),
      body: _buildHomeBody(context, isDark),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -10), // رفع الزر لأعلى بمقدار 10 بكسل
        child: FloatingActionButton(
          heroTag: 'home_fab',
          onPressed: () {
            context.push(AppRoutes.aiChat);
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: const Icon(Icons.smart_toy_rounded),
        ),
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context, bool isDark) {
    Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          _buildSearchField(context, isDark),

          const SizedBox(height: 25),
          const HomeBalanceCard(),

          const SizedBox(height: 25),
          _buildSectionHeader(context, "عروض مميزة"),
          const SizedBox(height: 15),
          const HomeBannerSlider(),

          const SizedBox(height: 25),
          _buildSectionHeader(context, "الأسواق"),
          const SizedBox(height: 15),
          const MarketsGrid(),

          const SizedBox(
            height: 25,
          ), // مساحة إضافية لتجنب تغطية الزر العائم للمحتوى
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: theme.shadowColor.withAlpha((0.1 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: "ابحث عن خدمة...",
          hintStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
          ),
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
          suffixIcon: Icon(
            Icons.qr_code_scanner_rounded,
            color: theme.colorScheme.primary,
          ),
          filled: true,
          fillColor:
              theme.inputDecorationTheme.fillColor ??
              theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "عرض الكل",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
