import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yemen_stor/features/notification/presentation/providers/notification_listener_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yemen_stor/core/theme/app_theme.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_stor/core/providers/theme_provider.dart';
import 'package:yemen_stor/core/providers/search_history_provider.dart';
import 'package:yemen_stor/features/menu/presentation/cubit/menu_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<MenuCubit>(
          create: (context) => MenuCubit(),
        ),
      ],
      child: ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const YemenStoreApp(),
      ),
    ),
  );
}

class YemenStoreApp extends ConsumerWidget {
  const YemenStoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize notification listener
    ref.watch(globalNotificationListenerProvider);

    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'Yemen Store',
      debugShowCheckedModeBanner: false,

      // --- إعدادات GoRouter ---
      routerConfig: AppRoutes.router,

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
      themeMode: themeMode,
    );
  }
}
