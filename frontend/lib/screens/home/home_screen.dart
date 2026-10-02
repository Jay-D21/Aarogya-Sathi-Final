import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fitness_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_goals_provider.dart';
import '../../widgets/health_score_ring.dart';
import '../../widgets/animated_metric_card.dart';
import '../chat/chat_screen.dart';
import '../health/health_dashboard.dart';
import '../../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _headerCtrl;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FitnessProvider>().init();
      context.read<ReminderProvider>().loadToday();
      final auth = context.read<AuthProvider>();
      final currentCity = auth.user?['preferred_city'] as String?;
      LocationService.getCityName().then((city) {
        if (city != null && city.isNotEmpty && mounted) {
          // Always update the preferred city from GPS detection.
          // This ensures stale values like 'babulde' or 'Nashik Division'
          // get replaced with the correct city name.
          final lowerCity = currentCity?.toLowerCase() ?? '';
          if (currentCity == null ||
              currentCity.isEmpty ||
              lowerCity == 'babulde' ||
              lowerCity.contains('division') ||
              lowerCity.contains('district')) {
            auth.updateProfile({'preferred_city': city});
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppTheme.surfaceL1 : AppTheme.surfaceL1Light;

    final pages = [
      _DashboardTab(onChatTap: () => setState(() => _currentIndex = 1)),
      const ChatScreen(),
      const HealthDashboard(),
      _ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(
                color: AppTheme.borderColor(context), width: 0.5),
          ),
          boxShadow: isDark
              ? [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, -4))]
              : [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4))],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          animationDuration: AppTheme.durationMedium,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'AI Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.monitor_heart_outlined),
              selectedIcon: Icon(Icons.monitor_heart_rounded),
              label: 'Health',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DASHBOARD TAB
// ═══════════════════════════════════════════════════════════════════════════

class _DashboardTab extends StatelessWidget {
  final VoidCallback onChatTap;
  const _DashboardTab({required this.onChatTap});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Good morning';
    if (h >= 12 && h < 17) return 'Good afternoon';
    if (h >= 17 && h < 22) return 'Good evening';
    return 'Good night';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fitness = context.watch<FitnessProvider>();
    final reminders = context.watch<ReminderProvider>();
    final goals = context.watch<UserGoalsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);
    final card = AppTheme.cardBg(context);
    final border = AppTheme.borderColor(context);

    final firstName = auth.user?['first_name'] as String? ?? 'Friend';
    final steps = fitness.steps;
    final weightKg = (auth.user?['weight_kg'] as num?)?.toDouble() ?? 70.0;
    final cal = fitness.calories(weightKg: weightKg);
    final waterMl = fitness.waterMl;
    final sleepHours = fitness.sleepHours;
    final heartRate = fitness.heartRate;
    final healthScore = _calcScore(steps, sleepHours, waterMl, heartRate, goals);

    return RefreshIndicator(
      color: AppTheme.primaryTeal,
      backgroundColor: card,
      onRefresh: () async {
        await fitness.syncFromHealthConnect(requestPermissions: false);
        final city = await LocationService.getCityName();
        if (city != null && city.isNotEmpty) {
          auth.updateProfile({'preferred_city': city});
        }
        await reminders.loadToday();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: AppTheme.bgOf(context),
            surfaceTintColor: Colors.transparent,
            titleSpacing: 20,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3),
                      ),
                      Text(
                        firstName,
                        style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textPri,
                            letterSpacing: -0.3),
                      ),
                    ],
                  ),
                ),
                // Sync button
                _IconBtn(
                  icon: Icons.sync_rounded,
                  onTap: () => _handleFitbitSync(context, fitness),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                // Notification bell
                _IconBtn(
                  icon: Icons.notifications_outlined,
                  onTap: () => _showNotifSheet(context),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                // Avatar
                _Avatar(name: firstName, isDark: isDark),
                const SizedBox(width: 4),
              ],
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Health Score Ring ──
                Center(
                  child: HealthScoreRing(
                    score: healthScore,
                    steps: steps,
                    calories: cal,
                    heartRate: heartRate,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Section: Quick Actions ──
                _SectionHeader(title: 'Quick Actions', textSec: textSec),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _QuickAction(
                      gradient: AppTheme.bpGradient,
                      icon: Icons.water_drop_outlined,
                      label: 'Log Water',
                      onTap: () => _showLogWaterDialog(context),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickAction(
                      gradient: AppTheme.chatGradient,
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'AI Chat',
                      onTap: onChatTap,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickAction(
                      gradient: AppTheme.stepsGradient,
                      icon: Icons.directions_walk_rounded,
                      label: 'Steps',
                      onTap: () => _showStepsDialog(context),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickAction(
                      gradient: AppTheme.healthGradient,
                      icon: Icons.sync_rounded,
                      label: 'Sync Fitbit',
                      onTap: () => _handleFitbitSync(context, fitness),
                    )),
                  ],
                ),

              const SizedBox(height: 24),

              // ── Section: Today's Activity ──
              _SectionHeader(
                title: "Today's Activity",
                textSec: textSec,
                action: TextButton.icon(
                  onPressed: () => _showLogSleepSheet(context),
                  icon: const Icon(Icons.bedtime_rounded, size: 14, color: AppTheme.primaryTeal),
                  label: Text('Log Sleep',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: AnimatedMetricCard(
                    gradient: AppTheme.stepsGradient,
                    icon: Icons.directions_walk_rounded,
                    value: _fmt(steps),
                    unit: 'steps',
                    label: 'Goal: ${goals.stepGoal >= 1000 ? "${(goals.stepGoal/1000).toStringAsFixed(0)}k" : "${goals.stepGoal}"}',
                    progress: (steps / goals.stepGoal).clamp(0.0, 1.0),
                    delay: 0,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: AnimatedMetricCard(
                    gradient: AppTheme.sugarGradient,
                    icon: Icons.local_fire_department_rounded,
                    value: _fmt(cal),
                    unit: 'kcal',
                    label: 'Burned today',
                    progress: (cal / 600).clamp(0.0, 1.0),
                    delay: 100,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: AnimatedMetricCard(
                    gradient: AppTheme.healthGradient,
                    icon: Icons.bedtime_rounded,
                    value: sleepHours > 0 ? sleepHours.toStringAsFixed(1) : '--',
                    unit: 'hrs',
                    label: 'Goal: ${goals.sleepGoal}h',
                    progress: (sleepHours / goals.sleepGoal).clamp(0.0, 1.0),
                    delay: 200,
                  )),
                ],
              ),

              const SizedBox(height: 24),

              // ── Section: AQI Banner ──
              _AqiBanner(
                city: (auth.user?['preferred_city'] ?? auth.user?['city']) as String? ?? 'Delhi',
                isDark: isDark,
                card: card,
                border: border,
                textPri: textPri,
                textSec: textSec,
              ),

              const SizedBox(height: 24),

              // ── Section: Reminders ──
              _SectionHeader(title: "Today's Reminders", textSec: textSec,
                action: TextButton(
                  onPressed: () => _showRemindersSheet(context),
                  child: Text('Manage',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              if (reminders.todaySchedule.isEmpty)
                _EmptyCard(
                  icon: Icons.alarm_off_rounded,
                  message: 'No reminders for today',
                  isDark: isDark,
                  card: card,
                  border: border,
                )
              else
                ...reminders.todaySchedule.take(3).map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ReminderTile(reminder: r, isDark: isDark,
                    card: card, border: border,
                    textPri: textPri, textSec: textSec),
                )),

              const SizedBox(height: 24),

              // ── Emergency CTA ──
              _EmergencyCTA(isDark: isDark, card: card, border: border),
            ]),
          ),
        ),
      ],
    ));
  }

  double _calcScore(int steps, double sleep, int water, int? hr, UserGoalsProvider goals) {
    double s = 0; // Start from 0 — score is earned, not given
    // 45 points for steps
    s += (steps / goals.stepGoal * 45).clamp(0, 45);
    // 25 points for sleep within 1h of goal
    if (sleep >= goals.sleepGoal - 1 && sleep <= goals.sleepGoal + 1) {
      s += 25;
    } else if (sleep > 0) {
      s += 10; // Partial for any logging
    }
    // 15 points for water
    s += (water / goals.waterGoal * 15).clamp(0, 15);
    // 15 points for healthy resting heart rate (60-100 bpm) or activity baseline
    if (hr != null && hr > 0) {
      if (hr >= 60 && hr <= 100) {
        s += 15;
      } else {
        s += 8;
      }
    } else if (steps > 500) {
      s += 10;
    }
    return s.clamp(0, 100);
  }

  String _fmt(int v) {
    if (v >= 10000) {
      return '${(v / 1000).toStringAsFixed(1)}k';
    }
    return NumberFormat.decimalPattern().format(v);
  }

  Future<void> _handleFitbitSync(BuildContext context, FitnessProvider fitness) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Connecting to Health Connect & Fitbit...'),
          ],
        ),
        duration: Duration(seconds: 4),
      ),
    );

    final result = await fitness.syncFromHealthConnect(requestPermissions: true);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    switch (result.status) {
      case SyncStatus.success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.message,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        break;

      case SyncStatus.noData:
        _showFitbitHelpDialog(context);
        break;

      case SyncStatus.permissionDenied:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFF59E0B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: const Text(
              'Health Connect permissions required to read Fitbit vitals.',
              style: TextStyle(color: Colors.white),
            ),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
        break;

      case SyncStatus.unavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(result.message),
            duration: const Duration(seconds: 4),
          ),
        );
        break;

      case SyncStatus.permissionRequired:
      case SyncStatus.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(result.message),
            duration: const Duration(seconds: 3),
          ),
        );
        break;
    }
  }

  void _showFitbitHelpDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(ctx),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppTheme.borderColor(ctx)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sync_problem_rounded, color: AppTheme.primaryTeal, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No Fitbit Data Found Yet',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryOf(ctx),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Health Connect is linked, but Fitbit hasn\'t written any recent vitals or steps into Health Connect yet.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondaryOf(ctx),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'How to connect Fitbit:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryOf(ctx),
              ),
            ),
            const SizedBox(height: 10),
            _guideStep(ctx, '1', 'Open the Fitbit App on your phone'),
            _guideStep(ctx, '2', 'Tap your Profile icon (top right) or App Settings'),
            _guideStep(ctx, '3', 'Tap "Health Connect"'),
            _guideStep(ctx, '4', 'Turn ON "Allow all" so Fitbit syncs steps, heart rate & sleep'),
            _guideStep(ctx, '5', 'Return to Aarogya Sathi and tap "Sync Fitbit"'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got It', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guideStep(BuildContext ctx, String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textPrimaryOf(ctx),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogWaterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LogWaterSheet(),
    );
  }

  void _showStepsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) {
        final fitness = c.read<FitnessProvider>();
        final goals = c.read<UserGoalsProvider>();
        final textPri = AppTheme.textPrimaryOf(c);
        final textSec = AppTheme.textSecondaryOf(c);
        final card = AppTheme.cardBg(c);
        return Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.textMuted, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(gradient: AppTheme.stepsGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                child: const Icon(Icons.directions_walk_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Steps Today', style: GoogleFonts.outfit(fontSize: 18,
                  fontWeight: FontWeight.w700, color: textPri)),
            ]),
            const SizedBox(height: 24),
            Text('${fitness.steps}', style: GoogleFonts.outfit(fontSize: 52,
                fontWeight: FontWeight.w800, color: AppTheme.primaryTeal, height: 1)),
            const SizedBox(height: 4),
            Text('of ${goals.stepGoal} goal', style: GoogleFonts.inter(fontSize: 14, color: textSec)),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (fitness.steps / goals.stepGoal).clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: AppTheme.borderColor(c),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryTeal),
              ),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${((fitness.steps / goals.stepGoal) * 100).toInt()}% of daily goal',
                  style: GoogleFonts.inter(fontSize: 12, color: textSec)),
              Text('${fitness.calories()} kcal',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentOrange)),
            ]),
            const SizedBox(height: 16),
            Text('Step counting uses your phone\'s built-in sensor.\nWalk around to see steps update!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMutedOf(c))),
          ]),
        );
      },
    );
  }

  void _showLogSleepSheet(BuildContext context) {
    final hoursCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) {
        final goals = c.read<UserGoalsProvider>();
        final textPri = AppTheme.textPrimaryOf(c);
        final card = AppTheme.cardBg(c);
        int quality = 3;
        return StatefulBuilder(builder: (c2, setSt) {
          return Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
            ),
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(c).viewInsets.bottom + 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.textMuted, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(gradient: AppTheme.healthGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                  child: const Icon(Icons.bedtime_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text('Log Last Night\'s Sleep',
                    style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: textPri)),
              ]),
              const SizedBox(height: 20),
              TextField(
                controller: hoursCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.inter(color: textPri),
                decoration: InputDecoration(
                  labelText: 'Hours slept (goal: ${goals.sleepGoal}h)',
                  prefixIcon: const Icon(Icons.access_time_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Text('Sleep Quality', style: GoogleFonts.inter(fontSize: 13,
                  color: AppTheme.textSecondaryOf(c))),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [1, 2, 3, 4, 5].map((q) {
                  final emojis = {1: '😫', 2: '😕', 3: '😐', 4: '😊', 5: '😄'};
                  return GestureDetector(
                    onTap: () => setSt(() => quality = q),
                    child: Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: quality == q
                            ? AppTheme.accentPurple.withValues(alpha: 0.15)
                            : Colors.transparent,
                        border: Border.all(color: quality == q
                            ? AppTheme.accentPurple
                            : AppTheme.borderColor(c)),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      alignment: Alignment.center,
                      child: Text(emojis[q]!, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                  ),
                  onPressed: () async {
                    final h = double.tryParse(hoursCtrl.text);
                    if (h == null || h <= 0 || h > 24) {
                      ScaffoldMessenger.of(c).showSnackBar(const SnackBar(
                          content: Text('Enter valid hours (e.g. 7.5)'),
                          backgroundColor: AppTheme.accentRed));
                      return;
                    }
                    await c.read<FitnessProvider>().logSleep(h, quality);
                    if (!c.mounted) return;
                    Navigator.pop(c);
                    ScaffoldMessenger.of(c).showSnackBar(SnackBar(
                        content: Text('Sleep logged: ${h}h · Quality $quality/5'),
                        backgroundColor: AppTheme.accentPurple));
                  },
                  child: Text('Save Sleep', style: GoogleFonts.outfit(
                      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ]),
          );
        });
      },
    );
  }

  void _showNotifSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted,
                  borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Notifications', style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryOf(c))),
            const SizedBox(height: 16),
            Text('No new notifications.',
                style: GoogleFonts.inter(color: AppTheme.textSecondaryOf(c))),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showRemindersSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => const _RemindersSheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROFILE TAB
// ═══════════════════════════════════════════════════════════════════════════

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);
    final card = AppTheme.cardBg(context);
    final border = AppTheme.borderColor(context);

    final user = auth.user ?? {};
    final name = '${user['first_name'] ?? 'Guest'} ${user['last_name'] ?? ''}'.trim();
    final email = user['email'] as String? ?? '—';
    final city = user['preferred_city'] as String? ?? 'Not set';
    final isGuest = auth.isGuest;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: AppTheme.bgOf(context),
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          titleSpacing: 20,
          title: Text('Profile',
              style: GoogleFonts.outfit(
                  fontSize: 22, fontWeight: FontWeight.w700, color: textPri)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Profile card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(color: border, width: 1),
                ),
                child: Column(children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: AppTheme.glowTeal(blur: 20, opacity: 0.3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (user['first_name'] as String? ?? 'G')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                      if (isGuest)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Guest',
                              style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(name,
                      style: GoogleFonts.outfit(
                          fontSize: 20, fontWeight: FontWeight.w700,
                          color: textPri)),
                  const SizedBox(height: 2),
                  Text(email,
                      style: GoogleFonts.inter(fontSize: 13, color: textSec)),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.location_on_outlined, size: 14,
                        color: AppTheme.primaryTeal),
                    const SizedBox(width: 4),
                    Text(city,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 16),
                  // Stats row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceL2 : AppTheme.surfaceL2Light,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Stat(
                          value: (auth.user?['bmi'] as num?) != null
                              ? (auth.user!['bmi'] as num).toStringAsFixed(1)
                              : '—',
                          label: 'BMI', textPri: textPri, textSec: textSec),
                        _Divider(isDark: isDark),
                        _Stat(
                          value: (auth.user?['height_cm'] as num?) != null
                              ? '${(auth.user!['height_cm'] as num).toInt()}cm'
                              : '—',
                          label: 'Height', textPri: textPri, textSec: textSec),
                        _Divider(isDark: isDark),
                        _Stat(
                          value: (auth.user?['weight_kg'] as num?) != null
                              ? '${(auth.user!['weight_kg'] as num).toStringAsFixed(1)}kg'
                              : '—',
                          label: 'Weight', textPri: textPri, textSec: textSec),
                      ],
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 20),

              // ── Settings ──
              _SettingsSection(title: 'Preferences', children: [
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  iconColor: AppTheme.accentPurple,
                  title: 'Dark Mode',
                  isDark: isDark,
                  trailing: Switch(
                    value: theme.isDark,
                    onChanged: (_) => context.read<ThemeProvider>().toggle(),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.language_outlined,
                  iconColor: AppTheme.accentBlue,
                  title: 'Language',
                  subtitle: context.watch<AuthProvider>().languageLabel,
                  isDark: isDark,
                  onTap: () => _showLangSheet(context),
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  iconColor: AppTheme.accentYellow,
                  title: 'Health Goals',
                  subtitle: 'Set your daily targets',
                  isDark: isDark,
                  onTap: () => _showGoalsSheet(context),
                ),
              ]),

              const SizedBox(height: 12),

              _SettingsSection(title: 'Medical Records & Privacy', children: [
                _SettingsTile(
                  icon: Icons.folder_shared_outlined,
                  iconColor: AppTheme.primaryTeal,
                  title: 'Medical File Vault',
                  subtitle: 'Prescriptions, lab reports & scans (On-Device)',
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/vault'),
                ),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  iconColor: AppTheme.accentGreen,
                  title: 'Privacy Settings',
                  isDark: isDark,
                  onTap: () => _showPrivacyDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  iconColor: AppTheme.primaryTeal,
                  title: 'Change Password',
                  isDark: isDark,
                  onTap: () => _showChangePassDialog(context),
                ),
              ]),

              const SizedBox(height: 12),

              _SettingsSection(title: 'About', children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppTheme.textSecondary,
                  title: 'About Aarogya Sathi',
                  isDark: isDark,
                  onTap: () => _showAbout(context),
                ),
                _SettingsTile(
                  icon: Icons.article_outlined,
                  iconColor: AppTheme.textSecondary,
                  title: 'Terms & Privacy Policy',
                  isDark: isDark,
                  onTap: () => _showTermsDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.medical_information_outlined,
                  iconColor: AppTheme.accentOrange,
                  title: 'Medical Disclaimer',
                  isDark: isDark,
                  onTap: () => _showDisclaimer(context),
                ),
              ]),

              const SizedBox(height: 20),

              // Sign out
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _confirmSignOut(context, auth),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppTheme.accentRed.withValues(alpha: 0.5),
                        width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded,
                          size: 18, color: AppTheme.accentRed),
                      const SizedBox(width: 8),
                      Text(
                        isGuest ? 'Sign In / Create Account' : 'Sign Out',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentRed),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text('Aarogya Sathi v1.0.0 · ICMR-Guided',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMutedOf(context))),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  void _confirmSignOut(BuildContext ctx, AuthProvider auth) {
    if (auth.isGuest) {
      Navigator.pushReplacementNamed(ctx, '/login');
      return;
    }
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Sign out?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (ctx.mounted) {
                Navigator.pushReplacementNamed(ctx, '/login');
              }
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showLangSheet(BuildContext ctx) {
    final auth = ctx.read<AuthProvider>();
    var currentLang = auth.language;

    final langOptions = [
      {'code': 'en', 'label': 'English'},
      {'code': 'hi', 'label': 'हिंदी (Hindi)'},
      {'code': 'mr', 'label': 'मराठी (Marathi)'},
    ];

    if (!ctx.mounted) return;

    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Language',
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryOf(c))),
              const SizedBox(height: 16),
              ...langOptions.map((opt) {
                final isSelected = (opt['code'] == currentLang);
                return ListTile(
                  title: Text(opt['label']!,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimaryOf(c),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondaryOf(c),
                  ),
                  onTap: () async {
                    final newLang = opt['code']!;
                    setSheetState(() => currentLang = newLang);
                    await auth.setLanguage(newLang);
                    if (c.mounted) Navigator.pop(c);
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('Language set to ${opt['label']}'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppTheme.primaryTeal,
                        ),
                      );
                    }
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePassDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Change Password',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: const Text('Password change feature coming soon.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'))
        ],
      ),
    );
  }

  void _showAbout(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('About Aarogya Sathi',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text(
          'Aarogya Sathi is an AI-powered personal health companion built for India.\n\n'
          'Designed under ICMR Ethical Guidelines for AI in Healthcare (2023) and compliant with the DPDP Act.\n\n'
          'Version 1.0.0',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'))
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Privacy & DPDP Compliance',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppTheme.accentGreen)),
        content: SingleChildScrollView(
          child: Text(
            '• Local-First: Your personal health records and vitals are stored on your device.\n\n'
            '• DPDP Act (2023) Compliant: Personal identifiers are never sold or shared with commercial ad networks.\n\n'
            '• Health Connect: Wearable sensor telemetry is used only to personalize your health insights during your active session.\n\n'
            '• Data Control: You can clear your local chat history and vital logs at any time.',
            style: GoogleFonts.inter(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got It'))
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Terms & Privacy Policy',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Text(
            'By using Aarogya Sathi, you agree that:\n\n'
            '1. Informational Companion: The AI assistant offers preventive wellness guidance, NOT clinical diagnosis or prescriptions.\n\n'
            '2. Emergency Care: In case of acute symptoms or life-threatening distress, contact National Emergency 112 / 108 immediately.\n\n'
            '3. Data Protection: In compliance with Indian digital health guidelines, your telemetry is processed securely without tracking identifiers.',
            style: GoogleFonts.inter(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'))
        ],
      ),
    );
  }

  void _showDisclaimer(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Medical Disclaimer',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700, color: AppTheme.accentOrange)),
        content: Text(
          'This app is for informational purposes only and does not provide medical diagnosis, '
          'prescription, or treatment advice.\n\n'
          'Always consult a qualified healthcare professional for medical decisions.\n\n'
          'In case of emergency, call 108 immediately.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('I Understand'))
        ],
      ),
    );
  }

  void _showGoalsSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => const _GoalsSheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color textSec;
  final Widget? action;
  const _SectionHeader({required this.title, required this.textSec, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryOf(context))),
        const Spacer(),
        action ?? const SizedBox.shrink(),
      ],
    );
  }
}

class _QuickAction extends StatefulWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({
    required this.gradient,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100),
        lowerBound: 0, upperBound: 1);
    _scale = Tween<double>(begin: 1, end: 0.93).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(widget.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(widget.label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryOf(context))),
        ]),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _IconBtn({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceL1 : AppTheme.surfaceL1Light,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor(context)),
        ),
        child: Icon(icon, size: 20,
            color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final bool isDark;
  const _Avatar({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
      ),
      alignment: Alignment.center,
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'G',
          style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
    );
  }
}

class _AqiBanner extends StatefulWidget {
  final String city;
  final bool isDark;
  final Color card, border, textPri, textSec;
  const _AqiBanner({
    required this.city,
    required this.isDark,
    required this.card,
    required this.border,
    required this.textPri,
    required this.textSec,
  });

  @override
  State<_AqiBanner> createState() => _AqiBannerState();
}

class _AqiBannerState extends State<_AqiBanner> {
  int? _aqi;
  double? _pm25;
  double? _pm10;
  String _label = '';
  Color _color = AppTheme.accentGreen;
  bool _loading = true;
  String _fetchedFor = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_AqiBanner old) {
    super.didUpdateWidget(old);
    if (old.city != widget.city) _load();
  }

  /// Calculates the official Central Pollution Control Board (CPCB) Indian National AQI (NAQI)
  /// from PM2.5 and PM10 concentrations (µg/m³).
  int _calcIndianAqi(double pm25, double pm10) {
    double aqiPm25;
    if (pm25 <= 30) {
      aqiPm25 = (pm25 / 30) * 50;
    } else if (pm25 <= 60) {
      aqiPm25 = 50 + ((pm25 - 30) / 30) * 50;
    } else if (pm25 <= 90) {
      aqiPm25 = 100 + ((pm25 - 60) / 30) * 100;
    } else if (pm25 <= 120) {
      aqiPm25 = 200 + ((pm25 - 90) / 30) * 100;
    } else if (pm25 <= 250) {
      aqiPm25 = 300 + ((pm25 - 120) / 130) * 100;
    } else {
      aqiPm25 = 400 + ((pm25 - 250) / 130) * 100;
    }

    double aqiPm10;
    if (pm10 <= 50) {
      aqiPm10 = (pm10 / 50) * 50;
    } else if (pm10 <= 100) {
      aqiPm10 = 50 + ((pm10 - 50) / 50) * 50;
    } else if (pm10 <= 250) {
      aqiPm10 = 100 + ((pm10 - 100) / 150) * 100;
    } else if (pm10 <= 350) {
      aqiPm10 = 200 + ((pm10 - 250) / 100) * 100;
    } else if (pm10 <= 430) {
      aqiPm10 = 300 + ((pm10 - 350) / 80) * 100;
    } else {
      aqiPm10 = 400 + ((pm10 - 430) / 70) * 100;
    }

    final maxVal = aqiPm25 > aqiPm10 ? aqiPm25 : aqiPm10;
    return maxVal.round().clamp(1, 500);
  }

  /// Indian CPCB NAQI Categories & Colors
  (String, Color) _classify(int aqi) {
    if (aqi <= 50)  return ('Good',           const Color(0xFF10B981));
    if (aqi <= 100) return ('Satisfactory',   const Color(0xFF22C55E));
    if (aqi <= 200) return ('Moderate',       const Color(0xFFEAB308));
    if (aqi <= 300) return ('Poor',           const Color(0xFFF97316));
    if (aqi <= 400) return ('Very Poor',      const Color(0xFFEF4444));
    return           ('Severe',              const Color(0xFF991B1B));
  }

  /// Indian CPCB NAQI Health Recommendations
  String _advice(int aqi) {
    if (aqi <= 50)  return 'Clean air • Ideal for all outdoor activities';
    if (aqi <= 100) return 'Satisfactory air quality • Safe for outdoor activity';
    if (aqi <= 200) return 'Acceptable • Sensitive groups take precautions';
    if (aqi <= 300) return 'Poor air • Avoid prolonged outdoor exertion';
    if (aqi <= 400) return 'Very poor air • Wear an N95 mask outdoors';
    return 'Severe air • Stay indoors with windows shut';
  }

  Future<void> _load({bool force = false}) async {
    final city = widget.city;
    if (!force && city == _fetchedFor && _aqi != null) return;
    _fetchedFor = city;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'aqi_cache_$city';
    final cacheTimeKey = 'aqi_time_$city';
    final cachedAt = prefs.getInt(cacheTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (!force && (now - cachedAt < 1800000)) {
      final cached = prefs.getInt(cacheKey);
      if (cached != null && mounted && city == widget.city) {
        final (lbl, col) = _classify(cached);
        setState(() {
          _aqi = cached;
          _label = lbl;
          _color = col;
          _loading = false;
        });
        return;
      }
    }

    if (mounted) setState(() => _loading = true);

    int? resolvedAqi;
    double? resolvedPm25;
    double? resolvedPm10;

    // 1. First try resolving using high-precision GPS coordinates
    try {
      final pos = await LocationService.getCurrentPosition();
      double? lat = pos?.latitude;
      double? lon = pos?.longitude;

      // If no GPS or city is custom-selected, geocode the city name
      if (lat == null || lon == null || (city.isNotEmpty && city.toLowerCase() != 'shirpur' && city.toLowerCase() != 'babulde')) {
        try {
          final locs = await locationFromAddress(city).timeout(const Duration(seconds: 4));
          if (locs.isNotEmpty) {
            lat = locs.first.latitude;
            lon = locs.first.longitude;
          }
        } catch (_) {}
      }

      // Default fallback coordinates: Shirpur (21.35, 74.88)
      lat ??= 21.35;
      lon ??= 74.88;

      // Priority 1: Open-Meteo High-Resolution Air Quality (100% free, coordinate-level accuracy)
      try {
        final omResp = await http.get(
          Uri.parse('https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=us_aqi,european_aqi,pm10,pm2_5'),
        ).timeout(const Duration(seconds: 5));
        if (omResp.statusCode == 200) {
          final data = jsonDecode(omResp.body);
          final cur = data['current'];
          if (cur != null) {
            final pm25Val = (cur['pm2_5'] as num?)?.toDouble();
            final pm10Val = (cur['pm10'] as num?)?.toDouble();
            if (pm25Val != null && pm10Val != null) {
              resolvedPm25 = pm25Val;
              resolvedPm10 = pm10Val;
              resolvedAqi = _calcIndianAqi(pm25Val, pm10Val);
              debugPrint('[AQI] Resolved Open-Meteo NAQI: $resolvedAqi (PM2.5: $pm25Val, PM10: $pm10Val)');
            } else if (cur['us_aqi'] != null) {
              resolvedAqi = (cur['us_aqi'] as num).toInt();
            }
          }
        }
      } catch (e) {
        debugPrint('[AQI] Open-Meteo error: $e');
      }

      // Priority 2: Fallback to Backend AQI
      if (resolvedAqi == null) {
        try {
          final backendResp = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/api/aqi?lat=$lat&lon=$lon'),
          ).timeout(const Duration(seconds: 5));
          if (backendResp.statusCode == 200) {
            final data = jsonDecode(backendResp.body);
            if (data['success'] == true && data['data'] != null) {
              final aqi = (data['data']['aqi'] as num?)?.toInt();
              if (aqi != null && aqi > 0) resolvedAqi = aqi;
            }
          }
        } catch (_) {}
      }
    } catch (_) {}

    // Priority 3: Try WAQI city feed
    if (resolvedAqi == null) {
      try {
        final encoded = Uri.encodeComponent(city);
        final resp = await http.get(
          Uri.parse('https://api.waqi.info/feed/$encoded/?token=demo'),
        ).timeout(const Duration(seconds: 4));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          if (data['status'] == 'ok') {
            final aqi = (data['data']?['aqi'] as num?)?.toInt();
            if (aqi != null) resolvedAqi = aqi;
          }
        }
      } catch (_) {}
    }

    if (resolvedAqi != null) {
      await prefs.setInt(cacheKey, resolvedAqi);
      await prefs.setInt(cacheTimeKey, now);
      if (mounted) {
        final (lbl, col) = _classify(resolvedAqi);
        setState(() {
          _aqi = resolvedAqi;
          _pm25 = resolvedPm25;
          _pm10 = resolvedPm10;
          _label = lbl;
          _color = col;
          _loading = false;
        });
        return;
      }
    }

    // Baseline fallback if all network requests fail
    if (mounted) {
      final cached = prefs.getInt(cacheKey);
      final fallback = cached ?? 25; // Clean air baseline (25 Good)
      final (lbl, col) = _classify(fallback);
      setState(() {
        _aqi = fallback;
        _label = lbl;
        _color = col;
        _loading = false;
      });
    }
  }

  void _showAqiDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AqiDetailSheet(
        city: widget.city,
        aqi: _aqi,
        label: _label,
        color: _color,
        pm25: _pm25,
        pm10: _pm10,
        advice: _aqi != null ? _advice(_aqi!) : 'AQI data unavailable',
        onCityChanged: (newCity) {
          context.read<AuthProvider>().updateProfile({'preferred_city': newCity});
          _load(force: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aqiStr = _loading ? '...' : (_aqi?.toString() ?? '--');
    final adviceStr = _loading
        ? 'Fetching AQI data...'
        : _aqi == null
            ? 'AQI data unavailable'
            : _advice(_aqi!);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () => _showAqiDetailSheet(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: widget.border),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_color.withValues(alpha: 0.7), _color]),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const Icon(Icons.air_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text('AQI · ${widget.city}',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.textPri),
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (_label.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_label,
                          style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _color)),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, size: 16, color: widget.textSec),
                ]),
                const SizedBox(height: 2),
                Text(adviceStr, style: GoogleFonts.inter(fontSize: 12, color: widget.textSec)),
              ],
            )),
            const SizedBox(width: 8),
            _loading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryTeal))
                : Text(aqiStr,
                    style: GoogleFonts.outfit(
                        fontSize: 26, fontWeight: FontWeight.w800, color: _color)),
          ]),
        ),
      ),
    );
  }
}

class _AqiDetailSheet extends StatefulWidget {
  final String city;
  final int? aqi;
  final String label;
  final Color color;
  final double? pm25;
  final double? pm10;
  final String advice;
  final ValueChanged<String> onCityChanged;

  const _AqiDetailSheet({
    required this.city,
    required this.aqi,
    required this.label,
    required this.color,
    required this.pm25,
    required this.pm10,
    required this.advice,
    required this.onCityChanged,
  });

  @override
  State<_AqiDetailSheet> createState() => _AqiDetailSheetState();
}

class _AqiDetailSheetState extends State<_AqiDetailSheet> {
  final TextEditingController _cityCtrl = TextEditingController();
  bool _detecting = false;

  final List<String> _popularCities = const [
    'Shirpur',
    'Dhule',
    'Nashik',
    'Pune',
    'Mumbai',
    'Indore',
    'Delhi',
  ];

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _detectGps() async {
    setState(() => _detecting = true);
    final detected = await LocationService.getCityName();
    if (mounted) {
      setState(() => _detecting = false);
      if (detected != null && detected.isNotEmpty) {
        final clean = detected.toLowerCase() == 'babulde' ? 'Shirpur' : detected;
        widget.onCityChanged(clean);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = AppTheme.cardBg(context);
    final border = AppTheme.borderColor(context);
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: border),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Air Quality & Pollution',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textPri,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.primaryTeal),
                          const SizedBox(width: 4),
                          Text(
                            widget.city,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: textSec,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.color.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.aqi != null ? '${widget.aqi}' : '--',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: widget.color,
                          height: 1,
                        ),
                      ),
                      Text(
                        widget.label.isNotEmpty ? widget.label : 'AQI',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Advice box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.color.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: widget.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.advice,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textPri,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Pollutant stats
            Row(
              children: [
                Expanded(
                  child: _PollutantTile(
                    title: 'PM2.5',
                    value: widget.pm25 != null ? '${widget.pm25!.toStringAsFixed(1)} µg/m³' : 'Good (Low)',
                    sub: 'Fine particulates',
                    border: border,
                    card: card,
                    textPri: textPri,
                    textSec: textSec,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PollutantTile(
                    title: 'PM10',
                    value: widget.pm10 != null ? '${widget.pm10!.toStringAsFixed(1)} µg/m³' : 'Good (Low)',
                    sub: 'Coarse dust particles',
                    border: border,
                    card: card,
                    textPri: textPri,
                    textSec: textSec,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Switch Location:',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPri,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: _detecting
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location_rounded, size: 16, color: AppTheme.primaryTeal),
                  label: const Text('Detect GPS'),
                  onPressed: _detecting ? null : _detectGps,
                ),
                ..._popularCities.map((c) => FilterChip(
                      selected: widget.city.toLowerCase() == c.toLowerCase(),
                      label: Text(c),
                      onSelected: (_) {
                        widget.onCityChanged(c);
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityCtrl,
                    decoration: InputDecoration(
                      hintText: 'Enter other city (e.g. Pune)',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: textSec),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final text = _cityCtrl.text.trim();
                    if (text.isNotEmpty) {
                      widget.onCityChanged(text);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Set'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PollutantTile extends StatelessWidget {
  final String title, value, sub;
  final Color border, card, textPri, textSec;
  const _PollutantTile({
    required this.title,
    required this.value,
    required this.sub,
    required this.border,
    required this.card,
    required this.textPri,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal)),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.inter(fontSize: 10, color: textSec)),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Map<String, dynamic> reminder;
  final bool isDark;
  final Color card, border, textPri, textSec;
  const _ReminderTile({
    required this.reminder,
    required this.isDark,
    required this.card,
    required this.border,
    required this.textPri,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = reminder['reminder_time'] as String? ?? '--:--';
    final title = reminder['title'] as String? ?? 'Reminder';
    final type = (reminder['reminder_type'] as String? ?? 'medicine').replaceAll('_', ' ');
    final taken = reminder['taken'] as bool? ?? false;

    final typeIcons = <String, IconData>{
      'medicine': Icons.medication_rounded,
      'water': Icons.water_drop_rounded,
      'exercise': Icons.fitness_center_rounded,
      'sleep': Icons.bedtime_rounded,
      'custom': Icons.alarm_rounded,
    };
    final icon = typeIcons[reminder['reminder_type'] as String? ?? 'custom'] ?? Icons.alarm_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppTheme.accentYellow.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, size: 18, color: AppTheme.accentYellow),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.outfit(
                fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
            Text('$timeStr · $type', style: GoogleFonts.inter(fontSize: 11, color: textSec)),
          ],
        )),
        GestureDetector(
          onTap: () => context.read<ReminderProvider>().markTaken(
            reminder['id'] as String, taken: !taken),
          child: Icon(
            taken ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: taken ? AppTheme.accentGreen : AppTheme.textMuted,
            size: 22,
          ),
        ),
      ]),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isDark;
  final Color card, border;
  const _EmptyCard({
    required this.icon,
    required this.message,
    required this.isDark,
    required this.card,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border),
      ),
      child: Center(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: AppTheme.textMutedOf(context)),
          const SizedBox(width: 8),
          Text(message,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textMutedOf(context))),
        ]),
      ),
    );
  }
}

class _EmergencyCTA extends StatelessWidget {
  final bool isDark;
  final Color card, border;
  const _EmergencyCTA({required this.isDark, required this.card, required this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentRed.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppTheme.accentRed.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: const Icon(Icons.local_hospital_rounded,
              color: AppTheme.accentRed, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medical Emergency?',
                style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppTheme.accentRed)),
            Text('Call 108 for ambulance',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppTheme.textSecondaryOf(context))),
          ],
        )),
        // FIXED: wrapped in GestureDetector to actually dial
        GestureDetector(
          onTap: () async {
            final uri = Uri(scheme: 'tel', path: '108');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentRed,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text('Call 108',
                style: GoogleFonts.outfit(
                    fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final card = AppTheme.cardBg(context);
    final border = AppTheme.borderColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMutedOf(context),
                  letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: border),
          ),
          child: Column(children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(height: 1, color: border, indent: 56),
            ],
          ]),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPri = AppTheme.textPrimaryOf(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(title,
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w500, color: textPri)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondaryOf(context)))
          : null,
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.textSecondaryOf(context)),
      onTap: trailing == null ? onTap : null,
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color textPri, textSec;
  const _Stat({required this.value, required this.label,
    required this.textPri, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: textSec)),
    ]);
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 32,
      color: isDark ? AppTheme.glassBorderLight : AppTheme.glassBorderLightModeSubtle,
    );
  }
}

// ── Log BP quick sheet ───────────────────────────────────────────────────────

class _LogWaterSheet extends StatefulWidget {
  const _LogWaterSheet();

  @override
  State<_LogWaterSheet> createState() => _LogWaterSheetState();
}

class _LogWaterSheetState extends State<_LogWaterSheet> {
  bool _loading = false;

  Future<void> _log(BuildContext ctx, int ml) async {
    setState(() => _loading = true);
    await ctx.read<FitnessProvider>().logWater(ml);
    if (!ctx.mounted) return;
    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppTheme.textPrimaryOf(context);
    final card = AppTheme.cardBg(context);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textMuted, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(gradient: AppTheme.bpGradient, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: const Icon(Icons.water_drop_outlined, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text('Log Water Intake', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: textPri)),
        ]),
        const SizedBox(height: 24),
        if (_loading)
          const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _WaterBtn(ml: 150, label: 'Cup', icon: Icons.local_cafe_outlined, onTap: () => _log(context, 150)),
              _WaterBtn(ml: 250, label: 'Glass', icon: Icons.local_drink_outlined, onTap: () => _log(context, 250)),
              _WaterBtn(ml: 500, label: 'Bottle', icon: Icons.local_drink, onTap: () => _log(context, 500)),
            ],
          ),
      ]),
    );
  }
}

class _WaterBtn extends StatelessWidget {
  final int ml;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _WaterBtn({required this.ml, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.bpGradient.colors.first.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.bpGradient.colors.first.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppTheme.bpGradient.colors.first),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimaryOf(context))),
            Text('${ml}ml', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondaryOf(context))),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REMINDERS FULL SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _RemindersSheet extends StatefulWidget {
  const _RemindersSheet();
  @override
  State<_RemindersSheet> createState() => _RemindersSheetState();
}

class _RemindersSheetState extends State<_RemindersSheet> {
  bool _showForm = false;
  final _titleCtrl = TextEditingController();
  String _type = 'medicine';
  TimeOfDay _time = TimeOfDay.now();
  final Set<int> _days = {}; // empty = all days
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a title')));
      return;
    }
    setState(() => _saving = true);
    await context.read<ReminderProvider>().createReminder(
      title: _titleCtrl.text.trim(),
      type: _type,
      time: _time,
      activeDays: _days.toList()..sort(),
    );
    _titleCtrl.clear();
    setState(() { _saving = false; _showForm = false; });
  }

  @override
  Widget build(BuildContext context) {
    final rem = context.watch<ReminderProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);
    final card = AppTheme.cardBg(context);
    final border = AppTheme.borderColor(context);

    final typeOptions = [
      ('medicine', Icons.medication_rounded, 'Medicine'),
      ('water',    Icons.water_drop_rounded, 'Water'),
      ('exercise', Icons.fitness_center_rounded, 'Exercise'),
      ('sleep',    Icons.bedtime_rounded, 'Sleep'),
      ('custom',   Icons.alarm_rounded, 'Custom'),
    ];
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: BoxDecoration(
          color: AppTheme.bgOf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        ),
        child: Column(children: [
          // Handle
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.textMuted,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              Row(children: [
                Text('Reminders', style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.w700, color: textPri)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _showForm = !_showForm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: _showForm ? null : AppTheme.primaryGradient,
                      color: _showForm ? AppTheme.borderColor(context) : null,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_showForm ? Icons.close_rounded : Icons.add_rounded,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(_showForm ? 'Cancel' : 'Add',
                          style: GoogleFonts.outfit(fontSize: 13,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                    ]),
                  ),
                ),
              ]),
            ]),
          ),

          Expanded(
            child: ListView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                // ── Add form ──
                if (_showForm) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: border),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('New Reminder', style: GoogleFonts.outfit(
                          fontSize: 14, fontWeight: FontWeight.w700, color: textPri)),
                      const SizedBox(height: 12),

                      // Title
                      TextField(
                        controller: _titleCtrl,
                        style: GoogleFonts.inter(color: textPri),
                        decoration: const InputDecoration(
                          labelText: 'Title (e.g. Morning Metformin)',
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Type selector
                      Text('Type', style: GoogleFonts.inter(fontSize: 12,
                          color: textSec, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: typeOptions.map((opt) {
                            final (val, icon, label) = opt;
                            final sel = _type == val;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _type = val),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: sel ? AppTheme.primaryTeal.withValues(alpha: 0.15) : Colors.transparent,
                                    border: Border.all(color: sel ? AppTheme.primaryTeal : border),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  ),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(icon, size: 15,
                                        color: sel ? AppTheme.primaryTeal : textSec),
                                    const SizedBox(width: 6),
                                    Text(label, style: GoogleFonts.inter(fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: sel ? AppTheme.primaryTeal : textSec)),
                                  ]),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Time picker
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                              context: context, initialTime: _time);
                          if (picked != null) setState(() => _time = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.bgOf(context),
                            border: Border.all(color: border),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Row(children: [
                            Icon(Icons.access_time_rounded, size: 18,
                                color: AppTheme.primaryTeal),
                            const SizedBox(width: 10),
                            Text(_time.format(context),
                                style: GoogleFonts.outfit(fontSize: 16,
                                    fontWeight: FontWeight.w600, color: textPri)),
                            const Spacer(),
                            Text('Tap to change',
                                style: GoogleFonts.inter(fontSize: 11, color: textSec)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Days
                      Text('Active days (empty = every day)',
                          style: GoogleFonts.inter(fontSize: 12, color: textSec, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (i) {
                          final day = i + 1;
                          final sel = _days.contains(day);
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (sel) { _days.remove(day); } else { _days.add(day); }
                            }),
                            child: Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                color: sel ? AppTheme.primaryTeal : Colors.transparent,
                                border: Border.all(color: sel ? AppTheme.primaryTeal : border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(dayLabels[i],
                                  style: GoogleFonts.outfit(fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: sel ? Colors.white : textSec)),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity, height: 44,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                          ),
                          child: _saving
                              ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text('Save Reminder', style: GoogleFonts.outfit(
                                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Reminder list with swipe-to-delete ──
                if (rem.reminders.isEmpty && !_showForm)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(children: [
                        Icon(Icons.alarm_off_rounded, size: 48,
                            color: AppTheme.textMutedOf(context)),
                        const SizedBox(height: 12),
                        Text('No reminders yet.',
                            style: GoogleFonts.outfit(fontSize: 16,
                                fontWeight: FontWeight.w600, color: textPri)),
                        const SizedBox(height: 4),
                        Text('Tap + Add to create your first reminder.',
                            style: GoogleFonts.inter(fontSize: 13, color: textSec)),
                      ]),
                    ),
                  )
                else
                  ...rem.reminders.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
                      key: Key(r['id'] as String),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: const Icon(Icons.delete_rounded,
                            color: AppTheme.accentRed, size: 22),
                      ),
                      onDismissed: (_) => context
                          .read<ReminderProvider>()
                          .deleteReminder(r['id'] as String),
                      child: _ReminderTile(
                        reminder: r,
                        isDark: isDark, card: card, border: border,
                        textPri: textPri, textSec: textSec,
                      ),
                    ),
                  )),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GOALS SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _GoalsSheet extends StatefulWidget {
  const _GoalsSheet();
  @override
  State<_GoalsSheet> createState() => _GoalsSheetState();
}

class _GoalsSheetState extends State<_GoalsSheet> {
  late int _steps;
  late int _water;
  late double _sleep;

  @override
  void initState() {
    super.initState();
    final g = context.read<UserGoalsProvider>();
    _steps = g.stepGoal;
    _water = g.waterGoal;
    _sleep = g.sleepGoal;
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);
    final card = AppTheme.cardBg(context);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.textMuted,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text('Daily Goals', style: GoogleFonts.outfit(
            fontSize: 20, fontWeight: FontWeight.w700, color: textPri)),
        const SizedBox(height: 4),
        Text('Customize your health targets', style: GoogleFonts.inter(
            fontSize: 13, color: textSec)),
        const SizedBox(height: 24),

        // Steps
        _GoalSlider(
          icon: Icons.directions_walk_rounded,
          color: AppTheme.primaryTeal,
          label: 'Step Goal',
          value: _steps.toDouble(),
          min: 2000, max: 30000, divisions: 56,
          display: '${(_steps / 1000).toStringAsFixed(1)}k steps',
          onChanged: (v) => setState(() => _steps = v.toInt()),
          textPri: textPri, textSec: textSec,
        ),
        const SizedBox(height: 16),

        // Water
        _GoalSlider(
          icon: Icons.water_drop_rounded,
          color: AppTheme.accentBlue,
          label: 'Water Goal',
          value: _water.toDouble(),
          min: 500, max: 5000, divisions: 18,
          display: '${(_water / 1000).toStringAsFixed(1)}L',
          onChanged: (v) => setState(() => _water = v.toInt()),
          textPri: textPri, textSec: textSec,
        ),
        const SizedBox(height: 16),

        // Sleep
        _GoalSlider(
          icon: Icons.bedtime_rounded,
          color: AppTheme.accentPurple,
          label: 'Sleep Goal',
          value: _sleep,
          min: 4, max: 12, divisions: 16,
          display: '${_sleep.toStringAsFixed(1)} hours',
          onChanged: (v) => setState(() => _sleep = v),
          textPri: textPri, textSec: textSec,
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            ),
            onPressed: () async {
              final g = context.read<UserGoalsProvider>();
              await g.setStepGoal(_steps);
              await g.setWaterGoal(_water);
              await g.setSleepGoal(_sleep);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goals saved!'),
                      backgroundColor: AppTheme.primaryTeal));
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Text('Save Goals', style: GoogleFonts.outfit(
                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _GoalSlider extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double value, min, max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;
  final Color textPri, textSec;

  const _GoalSlider({
    required this.icon, required this.color, required this.label,
    required this.value, required this.min, required this.max,
    required this.divisions, required this.display, required this.onChanged,
    required this.textPri, required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w600, color: textPri)),
        const Spacer(),
        Text(display, style: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: color,
          thumbColor: color,
          inactiveTrackColor: color.withValues(alpha: 0.2),
          overlayColor: color.withValues(alpha: 0.1),
        ),
        child: Slider(
          value: value,
          min: min, max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ),
    ]);
  }
}
