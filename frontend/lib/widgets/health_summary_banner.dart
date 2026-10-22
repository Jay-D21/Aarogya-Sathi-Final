import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import 'status_badge.dart';

/// Google Health-style "Health status" banner widget.
/// Shows summary of vital checks (e.g. "5 of 5 Vitals In Range")
/// with mini vital icons and color-coded status.
class HealthSummaryBanner extends StatelessWidget {
  final int totalVitals;
  final int inRangeVitals;
  final String statusText;
  final Color statusColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  const HealthSummaryBanner({
    super.key,
    this.totalVitals = 5,
    this.inRangeVitals = 5,
    this.statusText = 'In range',
    this.statusColor = AppTheme.accentGreen,
    this.onTap,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardBg = colorScheme.surfaceContainerLow;
    final hasData = totalVitals > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (hasData ? statusColor : AppTheme.primaryTeal).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasData ? Icons.verified_user_rounded : Icons.health_and_safety_outlined,
                    size: 16,
                    color: hasData ? statusColor : AppTheme.primaryTeal,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Health Status',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
                const Spacer(),
                if (onTap != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasData ? 'Details' : 'Log reading',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppTheme.primaryTeal,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasData)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vitals In Range',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMutedOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$inRangeVitals of $totalVitals',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimaryOf(context),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  StatusBadge(
                    label: statusText,
                    color: statusColor,
                    fontSize: 11,
                  ),
                  const Spacer(),
                  // Vital mini-status dot indicators
                  Row(
                    children: List.generate(totalVitals, (index) {
                      final isGood = index < inRangeVitals;
                      return Container(
                        margin: const EdgeInsets.only(left: 5),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isGood
                              ? statusColor
                              : AppTheme.textMutedOf(context).withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No vitals logged yet today',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimaryOf(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track Blood Pressure & Sugar for personalized safety',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 14, color: colorScheme.onPrimaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          'Log +',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
