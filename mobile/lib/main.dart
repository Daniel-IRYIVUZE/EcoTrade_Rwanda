import 'package:ecotrade_mobile/providers/app_providers.dart';
import 'package:ecotrade_mobile/services/api/api_client.dart';
import 'package:ecotrade_mobile/services/offline/offline_service.dart';
import 'package:ecotrade_mobile/utils/app_routes.dart';
import 'package:ecotrade_mobile/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  await OfflineService.init();
  ApiClient().initialize();

  FlutterNativeSplash.remove();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Ecotrade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C3A),
          primary: const Color(0xFF0F4C3A),
          secondary: const Color(0xFF10B981),
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C3A),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeMode,
      routes: AppRoutes.routes,
      home: const SplashScreen(),
    );
  }
}