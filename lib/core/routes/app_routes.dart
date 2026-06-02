import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yemen_stor/features/home/presentation/pages/favorites_screen.dart';
import 'package:yemen_stor/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:yemen_stor/features/onboarding/presentation/onboarding_screen.dart';
import 'package:yemen_stor/features/setting/presentation/pages/settings_screen.dart';
import 'package:yemen_stor/features/auth/presentation/pages/login_screen.dart';
import 'package:yemen_stor/features/auth/presentation/pages/signup_screen.dart';
import 'package:yemen_stor/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:yemen_stor/features/home/presentation/pages/home_screen.dart';
import 'package:yemen_stor/features/home/presentation/pages/recommendations_screen.dart';
import 'package:yemen_stor/features/orders/presentation/pages/orders_screen.dart';
import 'package:yemen_stor/features/orders/presentation/pages/order_tracking_screen.dart';
import 'package:yemen_stor/features/orders/presentation/pages/cart_screen.dart';
import 'package:yemen_stor/features/orders/presentation/pages/order_success_screen.dart';
import 'package:yemen_stor/features/profile/presentation/pages/profile_screen.dart';
import 'package:yemen_stor/features/wallet/presentation/pages/recharge_wallet_screen.dart';
import 'package:yemen_stor/features/digitalservices/presentation/pages/ai_subscription_screen.dart';
import 'package:yemen_stor/features/digitalservices/presentation/pages/digital_services_screen.dart';
import 'package:yemen_stor/features/digitalservices/presentation/pages/top_up_screen.dart';
import 'package:yemen_stor/features/digitalservices/presentation/pages/transaction_history_screen.dart';
import 'package:yemen_stor/features/digitalservices/presentation/pages/wifi_networks_screen.dart';
import 'package:yemen_stor/features/digitalservices/presentation/pages/rent_payment_screen.dart';
import 'package:yemen_stor/features/merchant/presentation/pages/merchant_add_product_screen.dart';
import 'package:yemen_stor/features/merchant/presentation/pages/merchant_dashboard_screen.dart';
import 'package:yemen_stor/features/merchant/presentation/pages/merchant_orders_screen.dart';
import 'package:yemen_stor/features/merchant/presentation/pages/merchant_products_screen.dart';
import 'package:yemen_stor/features/merchant/presentation/pages/merchant_registration_screen.dart';
import 'package:yemen_stor/features/merchant/presentation/pages/merchant_edit_shop_screen.dart';
import 'package:yemen_stor/features/menu/presentation/pages/add_private_network_screen.dart';
import 'package:yemen_stor/features/menu/presentation/pages/manage_cards_screen.dart';
import 'package:yemen_stor/features/arta_market/presentation/pages/arta_market_screen.dart';
import 'package:yemen_stor/features/arta_market/presentation/pages/arta_favorites_screen.dart';
import 'package:yemen_stor/features/markets/presentation/pages/markets_screen.dart';
import 'package:yemen_stor/features/markets/presentation/pages/subcategories_screen.dart';
import 'package:yemen_stor/features/shops/presentation/pages/shops_list_screen.dart';
import 'package:yemen_stor/features/shops/presentation/pages/shop_details_screen.dart';
import 'package:yemen_stor/features/shops/presentation/pages/product_details_screen.dart';
import 'package:yemen_stor/features/ai_assistant/presentation/pages/ai_chat_screen.dart';
import 'package:yemen_stor/features/notification/presentation/pages/notifications_screen.dart';
import 'package:yemen_stor/features/digitalservices/presentation/pages/workers_list_screen.dart';
import 'package:yemen_stor/features/digitalservices/presentation/pages/worker_registration_screen.dart';
import 'package:yemen_stor/features/digitalservices/presentation/pages/wifi_network_details_screen.dart';
import 'package:yemen_stor/features/digitalservices/presentation/pages/worker_profile_screen.dart';
import 'package:yemen_stor/features/digitalservices/presentation/pages/worker_edit_profile_screen.dart';
import 'package:yemen_stor/features/digitalservices/domain/entities/worker_entity.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String recommendations = '/recommendations';
  static const String cart = '/cart';
  static const String orderSuccess = '/order-success';
  static const String orders = '/orders';
  static const String orderTracking = '/order-tracking'; // المسار الأساسي
  static const String services = '/services';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String wallet = '/wallet';
  static const String favorites = '/favorites';
  static const String orderTrackingWithId = '/orders/tracking/:orderId';
  static const String orderTrackingNamed = 'orderTracking';
  static const String digitalServices = '/digital-services';
  static const String aiSubscription = '/digital-services/ai-subscription';
  static const String topUp = '/digital-services/top-up';
  static const String wifiNetworks = '/digital-services/wifi-networks';
  static const String merchantRegistration = '/merchant/registration';
  static const String merchantDashboard = '/merchant/dashboard';
  static const String merchantProducts = '/merchant/products';
  static const String merchantOrders = '/merchant/orders';
  static const String merchantAddProduct = '/merchant/add-product';
  static const String merchantEditShop = '/merchant/edit-shop';
  static const String addPrivateNetwork =
      '/manage-networks/add-private-network';
  static const String manageCards = '/manage-networks/manage-cards';
  static const String transactionHistory = '/digital-services/transactions';
  static const String notifications = '/notifications';
  static const String aiChat = '/ai-chat';
  static const String markets = '/markets';
  static const String marketsArta = '/markets/arta';
  static const String artaFavorites = '/markets/arta/favorites';
  static const String subcategories = '/markets/subcategories';
  static const String shopsList = '/markets/shops';
  static const String shopDetails = '/markets/shop-details';
  static const String productDetails = '/markets/product-details';
  static const String workersList = '/digital-services/workers';
  static const String workerRegistration = '/digital-services/workers/register';
  static const String workerProfile = '/digital-services/workers/profile';
  static const String workerEditProfile = '/digital-services/workers/edit-profile';
  static const String wifiNetworkDetails = '/digital-services/wifi-networks/details';
  static const String rentPayment = '/digital-services/rent-payment';

  static final router = GoRouter(
    initialLocation: FirebaseAuth.instance.currentUser != null
        ? home
        : onboarding,
    debugLogDiagnostics: true, // مفيد جداً لتتبع الأخطاء في الـ Console
    routes: [
      // 1. مسارات مستقلة (Full Screen - بدون شريط سفلي)
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: signup,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: wallet,
        builder: (context, state) => const RechargeWalletScreen(),
      ),
      GoRoute(
        path: favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: rentPayment,
        builder: (context, state) => const RentPaymentScreen(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(path: aiChat, builder: (context, state) => const ChatPage()),
      GoRoute(path: cart, builder: (context, state) => const CartScreen()),
      GoRoute(
        path: orderSuccess,
        builder: (context, state) => const OrderSuccessScreen(),
      ),
      GoRoute(
        path: markets,
        builder: (context, state) => const MarketsScreen(),
      ),
      GoRoute(
        path: marketsArta,
        builder: (context, state) => const ArtaMarketScreen(),
      ),
      GoRoute(
        path: artaFavorites,
        builder: (context, state) => const ArtaFavoritesScreen(),
      ),
      GoRoute(
        path: subcategories,
        builder: (context, state) {
          final extra = state.extra as Map? ?? {};
          return SubcategoriesScreen(
            marketId: extra['marketId']?.toString() ?? '',
            marketName: extra['marketName']?.toString() ?? '',
            categoryId: extra['categoryId']?.toString() ?? '',
            subcategoryName: extra['subcategoryName']?.toString() ?? '',
            iconName: extra['iconName']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: shopsList,
        builder: (context, state) {
          final extra = state.extra as Map? ?? {};
          return ShopsListScreen(
            marketId: extra['marketId']?.toString() ?? '',
            marketName: extra['marketName']?.toString() ?? '',
            categoryId: extra['categoryId']?.toString() ?? '',
            subcategoryName: extra['subcategoryName']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: shopDetails,
        builder: (context, state) {
          final extra = state.extra as Map? ?? {};
          final shop = extra['shop'] as Map? ?? {};
          return ShopDetailsScreen(shop: Map<String, dynamic>.from(shop));
        },
      ),
      GoRoute(
        path: productDetails,
        builder: (context, state) {
          final extra = state.extra as Map? ?? {};
          final product = extra['product'] as Map? ?? {};
          return ProductDetailsScreen(product: Map<String, dynamic>.from(product));
        },
      ),
      GoRoute(
        path: aiSubscription,
        builder: (context, state) => const AiSubscriptionScreen(),
      ),
      GoRoute(path: topUp, builder: (context, state) => const TopUpScreen()),
      GoRoute(
        path: wifiNetworks,
        builder: (context, state) => const WifiNetworksScreen(),
      ),
      GoRoute(
        path: wifiNetworkDetails,
        builder: (context, state) {
          final network = state.extra as Map? ?? {};
          return WifiNetworkDetailsScreen(network: Map<String, dynamic>.from(network));
        },
      ),
      GoRoute(
        path: merchantRegistration,
        builder: (context, state) => const MerchantRegistrationScreen(),
      ),
      GoRoute(
        path: merchantDashboard,
        builder: (context, state) => const MerchantDashboardScreen(),
      ),
      GoRoute(
        path: merchantProducts,
        builder: (context, state) => const MerchantProductsScreen(),
      ),
      GoRoute(
        path: merchantOrders,
        builder: (context, state) => const MerchantOrdersScreen(),
      ),
      GoRoute(
        path: merchantAddProduct,
        builder: (context, state) => const MerchantAddProductScreen(),
      ),
      GoRoute(
        path: merchantEditShop,
        builder: (context, state) => const MerchantEditShopScreen(),
      ),
      GoRoute(
        path: addPrivateNetwork,
        builder: (context, state) => const AddPrivateNetworkScreen(),
      ),
      GoRoute(
        path: manageCards,
        builder: (context, state) => const ManageCardsScreen(),
      ),
      GoRoute(
        path: transactionHistory,
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: workersList,
        builder: (context, state) {
          final category = state.extra as String? ?? 'الكل';
          return WorkersListScreen(category: category);
        },
      ),
      GoRoute(
        path: workerRegistration,
        builder: (context, state) => const WorkerRegistrationScreen(),
      ),
      GoRoute(
        path: workerProfile,
        builder: (context, state) {
          final worker = state.extra as WorkerEntity;
          return WorkerProfileScreen(worker: worker);
        },
      ),
      GoRoute(
        path: workerEditProfile,
        builder: (context, state) {
          final worker = state.extra as WorkerEntity;
          return WorkerEditProfileScreen(worker: worker);
        },
      ),
      GoRoute(
        path: orderTracking,
        builder: (context, state) {
          final extra = state.extra as Map? ?? {};
          final orderId = extra['orderId'] as String? ?? '';
          return OrderTrackingScreen(orderId: orderId);
        },
      ),

      // 2. هيكل التطبيق الرئيسي مع الشريط السفلي
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: HomeBottomNav(
              navigationShell: navigationShell,
            ),
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
                    path:
                        'tracking/:orderId', // سيصبح المسار: /orders/tracking/123
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
