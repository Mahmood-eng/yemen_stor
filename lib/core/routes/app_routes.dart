import "package:go_router/go_router.dart";
// import "package:flutter/material.dart";

import "package:yemen_store/features/onboarding/presentation/onboarding_screen.dart";
import "package:yemen_store/features/auth/presentation/pages/login_page.dart";
import "package:yemen_store/features/auth/presentation/pages/signup_screen.dart";
import "package:yemen_store/features/home/presentation/pages/home_screen.dart";
import "package:yemen_store/features/home/presentation/pages/favorites_screen.dart";
import "package:yemen_store/features/home/presentation/pages/recommendations_screen.dart";
import "package:yemen_store/features/markets/presentation/pages/markets_screen.dart";
import "package:yemen_store/features/profile/presentation/pages/profile_screen.dart";
import "package:yemen_store/features/wallet/presentation/pages/recharge_wallet_screen.dart";


class AppRoutes {

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String favorites = '/favorites';
  static const String recommendations = '/recommendations';
  static const String markets = '/markets';
  static const String profile = '/profile';
  static const String wallet = '/wallet';

  static final router = GoRouter(
    initialLocation: onboarding,
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: recommendations,
        builder: (context, state) => const RecommendationsScreen(),
      ),
      GoRoute(
        path: markets,
        builder: (context, state) => const MarketsScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: wallet,
        builder: (context, state) => const RechargeWalletScreen(),
      ),
    ],
  );
}
