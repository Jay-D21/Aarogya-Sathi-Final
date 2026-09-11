import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/chat_provider.dart';
import 'package:frontend/providers/health_provider.dart';
import 'package:frontend/providers/fitness_provider.dart';
import 'package:frontend/providers/reminder_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/user_goals_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => HealthProvider()),
          ChangeNotifierProvider(create: (_) => FitnessProvider()),
          ChangeNotifierProvider(create: (_) => ReminderProvider()),
          ChangeNotifierProvider(create: (_) => UserGoalsProvider()),
        ],
        child: const AarogyaSathiApp(),
      ),
    );
  });
}
