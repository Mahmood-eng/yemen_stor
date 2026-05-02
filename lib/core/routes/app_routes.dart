import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/features/home/presentation/pages/favorites_screen.dart';
import 'package:yemen_store/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:yemen_store/features/onboarding/presentation/onboarding_screen.dart';
import 'package:yemen_store/features/auth/presentation/pages/login_screen.dart';
import 'package:yemen_store/features/auth/presentation/pages/signup_screen.dart';
import 'package:yemen_store/features/home/presentation/pages/home_screen.dart';
import 'package:yemen_store/features/home/presentation/pages/recommendations_screen.dart';
import 'package:yemen_store/features/orders/presentation/pages/orders_screen.dart';
import 'package:yemen_store/features/orders/presentation/pages/order_tracking_screen.dart';
import 'package:yemen_store/features/profile/presentation/pages/profile_screen.dart';
import 'package:yemen_store/features/orders/presentation/pages/cart_screen.dart';
import 'package:yemen_store/features/wallet/presentation/pages/recharge_wallet_screen.dart';
import 'package:yemen_store/features/digitalservices/presentation/pages/digital_services_screen.dart';
import 'package:yemen_store/features/notifcation/presentation/pages/notifications_screen.dart';
import 'package:yemen_store/features/home/presentation/pages/product_details_screen.dart';
import 'package:yemen_store/features/home/data/models/product_model.dart';
import 'package:yemen_store/features/profile/presentation/pages/settings_screen.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String recommendations = '/recommendations';
  static const String orders = '/orders';
  static const String orderTracking = '/order-tracking'; // المسار الأساسي
  static const String services = '/services';
  static const String profile = '/profile';
  static const String wallet = '/wallet';
  static const String favorites = '/favorites';
  static const String orderTrackingWithId = '/orders/tracking/:orderId';
  static const String orderTrackingNamed = 'orderTracking';
  static const String digitalServices = '/digital-services';
  static const String notifications = '/notifications';
  static const String cart = '/cart';
  static const String productDetails = '/product-details';
  static const String settings = '/settings';
  static final router = GoRouter(
    initialLocation: onboarding,
    debugLogDiagnostics: true, // مفيد جداً لتتبع الأخطاء في الـ Console
    routes: [
      // 1. مسارات مستقلة (Full Screen - بدون شريط سفلي)
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
          
      ),
      GoRoute(
        path:   wallet, builder: (context, state) => const RechargeWalletScreen(),


      ),
      GoRoute(
        path: favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: productDetails,
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      // 2. هيكل التطبيق الرئيسي مع الشريط السفلي
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: HomeBottomNav(navigationShell: navigationShell),
          );
        },
        branches: [
          // الفرع الأول: الرئيسية
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // الفرع الثاني: المقترحات
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: recommendations,
                builder: (context, state) => const RecommendationsScreen(),
              ),
            ],
          ),
          // الفرع الثالث: الطلبات (ويحتوي على التتبع كمسار فرعي)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: orders,
                builder: (context, state) => const OrdersScreen(),
                routes: [
                  // مسار تتبع الطلب مرتبط برقم الطلب
                  GoRoute(
                    name: orderTracking, // استخدام name يسهل التنقل
                    path: 'tracking/:orderId', // سيصبح المسار: /orders/tracking/123
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId'] ?? '0';
                      return OrderTrackingScreen(orderId: orderId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // الفرع الرابع: الخدمات
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: services,
                builder: (context, state) => const DigitalServicesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}