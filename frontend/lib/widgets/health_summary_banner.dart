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

  const HealthSummaryBanner({
    super.key,
    this.totalVitals = 5,
    this.inRangeVitals = 5,
    this.statusText = 'In range',
    this.statusColor = AppTheme.accentGreen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.surfaceL1 : AppTheme.surfaceL1Light;
    final borderCol = isDark ? AppTheme.glassBorderLight : AppTheme.glassBorderLightModeSubtle;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: borderCol, width: 1),
          boxShadow: isDark ? null : AppTheme.cardShadowLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 20,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Health status',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppTheme.textMutedOf(context),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vitals',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMutedOf(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$inRangeVitals of $totalVitals',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimaryOf(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                StatusBadge(
                  label: statusText,
                  color: statusColor,
                  fontSize: 12,
                ),
                const Spacer(),
                // Vital mini-status dot indicators
                Row(
                  children: List.generate(totalVitals, (index) {
                    final isGood = index < inRangeVitals;
                    return Container(
                      margin: const EdgeInsets.only(left: 6),
                      width: 10,
                      height: 10,
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
            ),
          ],
        ),
      ),
    );
  }
}
