import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_store/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:yemen_store/features/onboarding/presentation/onboarding_screen.dart';
import 'package:yemen_store/features/auth/presentation/pages/login_screen.dart';
import 'package:yemen_store/features/auth/presentation/pages/signup_screen.dart';
import 'package:yemen_store/features/home/presentation/pages/home_screen.dart';
import 'package:yemen_store/features/home/presentation/pages/recommendations_screen.dart';

// ملاحظة: تأكد من استيراد بقية الشاشات (الطلبات، الخدمات، المقترحات) هنا
// import 'package:yemen_store/features/orders/presentation/pages/orders_screen.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup'; 
  static const String home = '/home';
  static const String recommendations = '/recommendations';
  static const String orders = '/orders';
  static const String services = '/services';

  static final router = GoRouter(
    initialLocation: onboarding,
    routes: [
      // 1. مسارات مستقلة (بدون شريط سفلي)
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

      // 2. مسارات الشريط السفلي (StatefulShellRoute)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // هنا نضع الهيكل الرئيسي الذي يحتوي على الـ body والشريط السفلي
          return Scaffold(
            body: navigationShell, // تعرض الشاشة المختار فرعها حالياً
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
          // الفرع الثالث: الطلبات
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: orders,
                builder: (context, state) => const Scaffold(body: Center(child: Text('الطلبات'))),
              ),
            ],
          ),
          // الفرع الرابع: الخدمات
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: services,
                builder: (context, state) => const Scaffold(body: Center(child: Text('الخدمات'))),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}