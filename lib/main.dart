// Starts the portfolio application with its configured dependencies and theme.
import 'package:abdelrhman_protfolio/core/di/service_locator.dart';
import 'package:abdelrhman_protfolio/core/config/supabase_config.dart';
import 'package:abdelrhman_protfolio/core/theme/app_theme.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/pages/portfolio_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.hasCredentials) {
    await Supabase.initialize(
      url: SupabaseConfig.projectUrl,
      publishableKey: SupabaseConfig.anonKey,
    );
  }
  configureDependencies();
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Abdelrahman Osama | Android Developer',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark(),
    home: const PortfolioPage(),
  );
}
