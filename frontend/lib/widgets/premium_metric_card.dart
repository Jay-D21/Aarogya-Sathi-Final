import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import 'status_badge.dart';
import 'mini_sparkline.dart';

/// Google Health-style premium metric card — displays a health metric with
/// large number, label, status badge, and optional sparkline trend chart.
///
/// Two sizes:
/// - `PremiumMetricCard.large()` — Hero card (takes full width)
/// - Default — Compact card for 2-column grid layout
class PremiumMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String? statusLabel;
  final Color statusColor;
  final IconData icon;
  final Color iconColor;
  final List<double>? trendData;
  final VoidCallback? onTap;
  final bool isLarge;

  const PremiumMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.statusLabel,
    this.statusColor = AppTheme.accentGreen,
    required this.icon,
    this.iconColor = AppTheme.primaryTeal,
    this.trendData,
    this.onTap,
    this.isLarge = false,
  });

  factory PremiumMetricCard.large({
    Key? key,
    required String label,
    required String value,
    String? unit,
    String? statusLabel,
    Color statusColor = AppTheme.accentGreen,
    required IconData icon,
    Color iconColor = AppTheme.primaryTeal,
    List<double>? trendData,
    VoidCallback? onTap,
  }) {
    return PremiumMetricCard(
      key: key,
      label: label,
      value: value,
      unit: unit,
      statusLabel: statusLabel,
      statusColor: statusColor,
      icon: icon,
      iconColor: iconColor,
      trendData: trendData,
      onTap: onTap,
      isLarge: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.surfaceL1 : AppTheme.surfaceL1Light;
    final borderCol = isDark ? AppTheme.glassBorderLight : AppTheme.glassBorderLightModeSubtle;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 20 : 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: borderCol, width: 1),
          boxShadow: isDark ? null : AppTheme.cardShadowLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + label
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right_rounded, size: 18,
                      color: AppTheme.textMutedOf(context)),
              ],
            ),

            SizedBox(height: isLarge ? 16 : 12),

            // Value row
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: isLarge ? 36 : 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimaryOf(context),
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit!,
                    style: GoogleFonts.inter(
                      fontSize: isLarge ? 16 : 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textMutedOf(context),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Status badge
            if (statusLabel != null)
              StatusBadge(label: statusLabel!, color: statusColor),

            // Sparkline trend
            if (trendData != null && trendData!.length >= 2) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: isLarge ? 48 : 32,
                child: MiniSparkline(
                  data: trendData!,
                  lineColor: iconColor,
                  strokeWidth: isLarge ? 2.5 : 2.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
