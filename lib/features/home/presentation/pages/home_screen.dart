import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/features/orders/presentation/providers/cart_provider.dart';
import 'package:yemen_store/core/routes/app_routes.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../widgets/markets_grid.dart';
import '../widgets/home_balance_card.dart';
import '../widgets/home_banner_slider.dart';
import 'package:yemen_store/core/theme/app_colors.dart';

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
        isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
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
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: theme.appBarTheme.foregroundColor,
                  ),
                  onPressed: () {
                    context.push(AppRoutes.cart);
                  },
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHomeBody(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

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
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        textAlign: TextAlign.right,
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('جاري البحث عن: $query')),
            );
          }
        },
        decoration: InputDecoration(
          hintText: "ابحث عن خدمة...",
          hintStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: Colors.grey,
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          suffixIcon: Icon(
            Icons.qr_code_scanner_rounded,
            color: AppColors.primary,
          ),
          filled: true,
          fillColor: const Color(0xFFF3F5F7),
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
            style: TextStyle(
              color: theme.primaryColor,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
