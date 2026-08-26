import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Google Fit–style arc ring showing health score, steps, calories, and heart rate.
/// Animated arc ring displaying the user's composite daily health score
/// (0–100). Score is computed from step goal, sleep quality, vital
/// readings, and AQI exposure. Animates on first render using a Tween.
class HealthScoreRing extends StatelessWidget {
  final double score;   // 0–100
  final int steps;
  final int calories;
  final int? heartRate;

  const HealthScoreRing({
    super.key,
    required this.score,
    required this.steps,
    required this.calories,
    this.heartRate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = colorScheme.primary;
    final trackColor = colorScheme.surfaceContainerHigh;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    final kcalColor = isDark ? const Color(0xFFFFB77C) : const Color(0xFFE66000);
    final bpmColor = isDark ? const Color(0xFFFF859D) : const Color(0xFFD9385A);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: score),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, animScore, child) {
        final progress = (animScore / 100).clamp(0.0, 1.0);
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ring
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: progress,
                    activeColor: activeColor,
                    trackColor: trackColor,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          score > 0 ? animScore.toInt().toString() : '--',
                          style: GoogleFonts.outfit(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: score > 0 ? activeColor : onSurfaceVariant,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Daily Score',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          score > 0 ? 'Goal: 100 pts' : 'Sync to start',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Inner tonal sub-metrics bar
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(
                      icon: Icons.directions_walk_rounded,
                      color: activeColor,
                      value: _fmt(steps),
                      label: 'Steps',
                      textPri: onSurface,
                      textSec: onSurfaceVariant,
                    ),
                    _VDivider(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    _Stat(
                      icon: Icons.local_fire_department_rounded,
                      color: kcalColor,
                      value: _fmt(calories),
                      label: 'Active Kcal',
                      textPri: onSurface,
                      textSec: onSurfaceVariant,
                    ),
                    _VDivider(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    _Stat(
                      icon: Icons.favorite_rounded,
                      color: bpmColor,
                      value: heartRate != null && heartRate! > 0
                          ? '$heartRate'
                          : '--',
                      label: 'BPM',
                      textPri: onSurface,
                      textSec: onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(int v) {
    if (v >= 10000) {
      return '${(v / 1000).toStringAsFixed(1)}k';
    }
    return NumberFormat.decimalPattern().format(v);
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value, label;
  final Color textPri, textSec;
  const _Stat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.textPri,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: textSec,
          ),
        ),
      ],
    );
  }
}

class _VDivider extends StatelessWidget {
  final Color color;
  const _VDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: color,
    );
  }
}

// ── Ring Painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerR = size.width / 2 - 12;
    final rect = Rect.fromCircle(center: center, radius: outerR);

    // Track ring
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, trackPaint);

    // Progress arc
    if (progress > 0) {
      final activePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..color = activeColor;

      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, activePaint);

      // Glowing tip
      final tipAngle = -math.pi / 2 + 2 * math.pi * progress;
      final tipX = center.dx + outerR * math.cos(tipAngle);
      final tipY = center.dy + outerR * math.sin(tipAngle);
      final glowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(tipX, tipY), 8, glowPaint);

      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(tipX, tipY), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.activeColor != activeColor ||
      old.trackColor != trackColor;
}
