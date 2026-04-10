import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rider34/core/di/supabase_config.dart';
import 'package:rider34/core/router/app_router.dart';
import 'package:rider34/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: '.env');

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase — wrapped in try/catch so the app boots up even
  // when the placeholder keys haven't been replaced yet.
  final bool hasSupabaseKeys =
      !SupabaseConfig.supabaseUrl.contains('YOUR_PROJECT_ID') &&
          !SupabaseConfig.supabaseAnonKey.contains('YOUR_ANON_KEY');

  if (hasSupabaseKeys) {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } else {
    debugPrint(
      '⚠️  Supabase not initialised — fill in supabase_config.dart to enable auth & data.',
    );
  }

  runApp(const ProviderScope(child: Rider34App()));
}

class Rider34App extends ConsumerWidget {
  const Rider34App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Rider 34',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
