import 'package:flutter/material.dart';
// استيراد الشاشات - تأكد من مطابقة المسارات لمجلدات مشروعك
import 'package:yemen_store/features/auth/presentation/pages/login_page.dart';
import 'package:yemen_store/features/auth/presentation/pages/signup_screen.dart';
import 'package:yemen_store/features/home/presentation/pages/favorites_screen.dart';
import 'package:yemen_store/features/onboarding/presentation/onboarding_screen.dart';
import 'package:yemen_store/features/home/presentation/pages/home_screen.dart';
import 'package:yemen_store/features/markets/presentation/pages/markets_screen.dart';
import 'package:yemen_store/features/orders/presentation/pages/cart_screen.dart';
import 'package:yemen_store/features/orders/presentation/pages/order_tracking_screen.dart';
import 'package:yemen_store/features/orders/presentation/pages/orders_screen.dart';
import 'package:yemen_store/features/profile/presentation/pages/profile_screen.dart';
import 'package:yemen_store/features/wallet/presentation/pages/recharge_wallet_screen.dart';

class AppRoutes {
  // تعريف المسار الابتدائي للتطبيق
  static const String initialRoute = OnboardingScreen.id;

  static Map<String, WidgetBuilder> get routes {
    return {
      // شاشات التعريف والتدشين
      OnboardingScreen.id: (context) => const OnboardingScreen(),

      // شاشات المصادقة (Auth)
      LoginScreen.id: (context) => const LoginScreen(),
      SignUpScreen.id: (context) => const SignUpScreen(),

      // الشاشات الرئيسية
      HomeScreen.id: (context) => const HomeScreen(),
      MarketsScreen.id: (context) => const MarketsScreen(),
      FavoritesScreen.id: (context) => const FavoritesScreen(),
      ProfileScreen.id: (context) => const ProfileScreen(),
      RechargeWalletScreen.id: (context) => const RechargeWalletScreen(),
      OrdersScreen.id: (context) => const OrdersScreen(),
      CartScreen.id: (context) => const CartScreen(),
  
    };
  }
}
