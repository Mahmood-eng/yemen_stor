import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/core/routes/app_routes.dart';

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
      appBar: _buildAppBar(context, isDark),
      body: _buildHomeBody(context, isDark),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return AppBar(
      elevation: 0,
      // اللون يتم جلبه من AppBarTheme في ملف الثيم
      backgroundColor: theme.appBarTheme.backgroundColor,
      centerTitle: true,
      title: Image.asset(
        isDark ? 'assets/images/logo.png' : 'assets/images/logo.png',
        height: 40,
      ),
      leading: IconButton(
        icon: Icon(
          Icons.menu_rounded,
          color: theme.appBarTheme.foregroundColor,
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () {
            context.push(AppRoutes.notifications);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () {
            context.push(AppRoutes.cart);
          },
        ),
      ],
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

          const SizedBox(height: 25),
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
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
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
          onPressed: () {
            
          },
          child: Text(
            "عرض الكل",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
