import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/screens/hybrid_dashboard.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/profile/presentation/screens/health_profile_screen.dart';
import 'features/reports/presentation/screens/upload_report_screen.dart';

void main() {
  runApp(const ProviderScope(child: ArogyaSathiApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HybridDashboardScreen(),
    ),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const HealthProfileScreen(),
    ),
    GoRoute(
      path: '/reports/upload',
      builder: (context, state) => const UploadReportScreen(),
    ),
  ],
);

class ArogyaSathiApp extends ConsumerWidget {
  const ArogyaSathiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Aarogya Sathi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
