import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ضروري جداً
import 'package:yemen_store/core/theme/app_colors.dart';

class HomeBottomNav extends StatelessWidget {

  final StatefulNavigationShell navigationShell;

  const HomeBottomNav({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        
        currentIndex: navigationShell.currentIndex,
        
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: true, // تغيير هذا السطر ليقوم بتفريغ الستاك عند التنقل بين الصفحات
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? Colors.white38 : Colors.grey,
        selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'المقترحات'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'الطلبات'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'الخدمات'),
        ],
      ),
    );
  }
}