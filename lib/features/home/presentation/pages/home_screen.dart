import 'package:flutter/material.dart';
import 'package:yemen_store/core/theme/app_colors.dart';
import 'package:yemen_store/core/widgets/app_drawer.dart';

import '../widgets/markets_grid.dart';
import '../widgets/home_balance_card.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/home_bottom_nav.dart';
import 'recommendations_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,

      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFF8FAFD),
      drawer: const AppDrawer(),
      appBar: _buildAppBar(context, isDark),
      body: _buildCurrentPage(context, isDark),

      bottomNavigationBar: HomeBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, size: 28),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Image.asset(
        'assets/images/logo.png',
        height: 40,
        errorBuilder: (c, e, s) => Text(
          "يمن ستور",
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 20),
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none_rounded),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart_outlined)),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _buildCurrentPage(BuildContext context, bool isDark) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(context, isDark); // محتوى الرئيسية الحالي
      case 1:
        return const RecommendationsScreen(); // صفحة المقترحات
      case 2:
        return const Center(child: Text("صفحة الطلبات قيد التطوير"));
      case 3:
        return const Center(child: Text("صفحة الخدمات قيد التطوير"));
      default:
        return _buildHomeContent(context, isDark);
    }
  }

  Widget _buildHomeContent(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "ابحث عن منتج أو محل...",
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: const Icon(Icons.qr_code_scanner_outlined),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: () {}, child: const Text("عرض الكل")),
      ],
    );
  }
}
