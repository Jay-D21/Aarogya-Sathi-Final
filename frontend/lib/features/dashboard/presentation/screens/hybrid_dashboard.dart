import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/widgets/activity_ring.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:frontend/features/dashboard/data/environment_repository.dart';
import 'package:google_fonts/google_fonts.dart';

class HybridDashboardScreen extends ConsumerWidget {
  const HybridDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Watch Providers
    final fitnessState = ref.watch(fitnessProvider);
    final stepStream = ref.watch(stepCountStreamProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Bar / App Bar
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good Morning,",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        Text(
                          "Jay", // Dynamic User Name later
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Hero Section: Activity Rings (Google Fit Style)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: stepStream.when(
                  data: (stepCount) {
                    // Update State Logic
                    // Ideally handled in a better place, but for MVP doing it here
                    // to reflect stream updates in the UI state
                    // This is a bit of a side-effect in build, careful.
                    // Better to use ref.listen in real app.
                    Future.microtask(() {
                      ref
                          .read(fitnessProvider.notifier)
                          .updateSteps(stepCount.steps);
                    });

                    return _buildRings(context, fitnessState);
                  },
                  error: (err, stack) =>
                      _buildRings(context, fitnessState), // Fallback/Error
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),

            // 3. Environmental Context Strip (Dynamic)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Consumer(
                  builder: (context, ref, child) {
                    final envAsync = ref.watch(
                      currentEnvironmentProvider((lat: 19.07, lon: 72.87)),
                    ); // Mumbai coords or dynamic

                    return envAsync.when(
                      data: (data) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _parseColor(
                                  data.colorCode,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.wb_sunny,
                                color: _parseColor(data.colorCode),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "AQI is ${data.aqiStatus} (${data.aqi})",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _parseColor(
                                            data.colorCode,
                                          ), // Dynamic Color
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data.alertMessage,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      loading: () =>
                          const Center(child: LinearProgressIndicator()),
                      error: (err, stack) => const SizedBox(),
                    );
                  },
                ),
              ),
            ),

            // 4. Vitals GridProvider
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _MetricCard(
                    title: "Heart Points",
                    value: "${fitnessState.heartPoints}",
                    icon: Icons.favorite,
                    color: Colors.redAccent,
                  ),
                  _MetricCard(
                    title: "Calories",
                    value: "${fitnessState.calories.toStringAsFixed(0)} kcal",
                    icon: Icons.local_fire_department,
                    color: Colors.orangeAccent,
                  ),
                  _MetricCard(
                    title: "Sleep",
                    value: "7h 12m",
                    icon: Icons.bedtime,
                    color: Colors.deepPurpleAccent,
                  ),
                  _MetricCard(
                    title: "Water",
                    value: "1.2 L",
                    icon: Icons.water_drop,
                    color: Colors.blueAccent,
                  ),
                  _MetricCard(
                    title: "Medical Reports",
                    value: "Upload",
                    icon: Icons.upload_file,
                    color: Colors.teal,
                    onTap: () => context.push('/reports/upload'),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 20), // Bottom padding
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/chat');
        },
        label: const Text("Ask AI"),
        icon: const Icon(Icons.chat_bubble_outline),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildRings(BuildContext context, FitnessState state) {
    // Dynamic progress calc (Goal: 10000 steps)
    double stepProgress = (state.steps / 10000).clamp(0.0, 1.0);
    double calProgress = (state.calories / 500).clamp(0.0, 1.0);
    double heartProgress = (state.heartPoints / 100).clamp(0.0, 1.0);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Steps Ring (Outer)
          ActivityRing(
            size: 240,
            thickness: 20,
            progress: stepProgress,
            color: AppTheme.primaryColor,
          ),
          // Calories Ring (Middle)
          ActivityRing(
            size: 180,
            thickness: 20,
            progress: calProgress,
            color: AppTheme.secondaryColor,
          ),
          // Heart Points Ring (Inner)
          ActivityRing(
            size: 120,
            thickness: 20,
            progress: heartProgress,
            color: AppTheme.tertiaryColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_walk,
                  size: 32,
                  color: AppTheme.primaryColor,
                ),
                Text(
                  "${state.steps}",
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text("Steps", style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse("0x$hexColor"));
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
