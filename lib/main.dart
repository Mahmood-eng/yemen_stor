import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yemen_stor/core/theme/app_theme.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/firebase_options.dart';
import 'package:yemen_stor/core/providers/theme_provider.dart';
import 'package:yemen_stor/features/menu/presentation/cubit/menu_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<MenuCubit>(
          create: (context) => MenuCubit(),
        ),
      ],
      child: const ProviderScope(child: YemenStoreApp()),
    ),
  );
}

class YemenStoreApp extends ConsumerWidget {
  const YemenStoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
