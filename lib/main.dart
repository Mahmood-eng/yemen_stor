import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yemen_store/core/theme/app_theme.dart';
import 'package:yemen_store/core/routes/app_routes.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YemenStoreApp());
}

class YemenStoreApp extends StatelessWidget {
  const YemenStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yemen Store',
      debugShowCheckedModeBanner: false,

      // --- إعدادات اللغة العربية وواجهة RTL ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'YE'), // العربية - اليمن
      ],
      locale: const Locale('ar', 'YE'),

      // --- ربط الثيمات الذكية ---
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme, 
      themeMode: ThemeMode.system, 

      // --- نظام التنقل (Routes) ---
      initialRoute: AppRoutes.initialRoute, 
      routes: AppRoutes.routes,
    );
  }
}