import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart'; //  استدعاء المزود للقيام بعمليات المزامنة 
import 'package:yemen_store/core/theme/app_theme.dart'; //  استدعاء الثيم الفاتح والداكن  
import 'package:yemen_store/core/routes/app_routes.dart'; //  استدعاء المزود للقيام بعمليات المسار 
import 'package:yemen_store/features/auth/data/repositories/local_json_auth_repository.dart'; //  استدعاء المستودع المحلي  
import 'package:yemen_store/features/auth/presentation/providers/auth_provider.dart'; //  استدعاء المزود للقيام بعمليات تسجيل الدخول والخروج 

import 'package:yemen_store/features/home/presentation/providers/favorites_provider.dart'; //  استدعاء المزود للقيام بعمليات المفضلة 
import 'package:yemen_store/features/home/presentation/providers/products_provider.dart';
import 'package:yemen_store/features/orders/presentation/providers/cart_provider.dart';  //  استدعاء المزود للقيام بعمليات السلة والشراء 

import 'package:yemen_store/features/orders/presentation/providers/orders_provider.dart';  //  استدعاء المزود للقيام بعمليات الاوردر والشراء 

import 'package:yemen_store/core/providers/settings_provider.dart';

// ==================================================================
// نقطة الدخول الرئيسية
// لتبديل قاعدة البيانات لاحقاً إلى Supabase:
//   1. أنشئ SupabaseAuthRepository يُنفِّذ AuthRepository
//   2. غيّر السطر: LocalJsonAuthRepository() → SupabaseAuthRepository()
//   3. لا شيء آخر يتغير ✅
// ==================================================================

void main() async { // نقطة الدخول الرئيسية
  WidgetsFlutterBinding.ensureInitialized();

  // إنشاء المستودع (يمكن تبديله بـ SupabaseAuthRepository لاحقاً)
  final authRepository = LocalJsonAuthRepository(); // إنشاء المستودع

  runApp( // تشغيل التطبيق
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository)..checkAuthStatus(), // إنشاء المزود
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()), // مزود الإعدادات
        ChangeNotifierProvider(create: (_) => ProductsProvider()), // مزود المنتجات
        ChangeNotifierProvider(create: (_) => CartProvider()), // إنشاء المزود
        ChangeNotifierProvider(create: (_) => FavoritesProvider()), // إنشاء المزود
        ChangeNotifierProvider(create: (_) => OrdersProvider()), // إنشاء المزود
      ],
      child: const YemenStoreApp(), // تشغيل التطبيق
    ),
  );
}

class YemenStoreApp extends StatelessWidget {
  const YemenStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp.router(
          title: 'Yemen Store',
          debugShowCheckedModeBanner: false,

          // --- إعدادات GoRouter ---
          routerConfig: AppRoutes.router,

          // --- إعدادات اللغة العربية وواجهة RTL ---
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate, // دعم اللغة العربية
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate, // دعم اللغة العربية
          ],
          supportedLocales: const [
            Locale('ar', 'YE'), // دعم اللغة العربية
          ],
          locale: const Locale('ar', 'YE'), // دعم اللغة العربية

          // --- ربط الثيمات الذكية ---
          theme: AppTheme.lightTheme, // الثيم الفاتح
          darkTheme: AppTheme.darkTheme, // الثيم الداكن
          themeMode: settingsProvider.themeMode, // الثيم الافتراضي
        ); // إغلاق MaterialApp
      },
    );
  } // إغلاق build
}