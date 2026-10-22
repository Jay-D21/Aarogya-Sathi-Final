import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/widgets/expressive_motion.dart';
import 'mini_sparkline.dart';

/// Google Health-style premium metric card — displays a health metric with
/// large number, label, plain status text, and optional sparkline trend chart.
///
/// Two sizes:
/// - `PremiumMetricCard.large()` — Hero card (takes full width)
/// - Default — Compact card for 2-column grid layout
class PremiumMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String? statusLabel;
  final Color? statusColor;
  final IconData icon;
  final Color? iconColor;
  final List<double>? trendData;
  final VoidCallback? onTap;
  final bool isLarge;
  final bool showAddIcon;

  const PremiumMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.statusLabel,
    this.statusColor,
    required this.icon,
    this.iconColor,
    this.trendData,
    this.onTap,
    this.isLarge = false,
    this.showAddIcon = false,
  });

  factory PremiumMetricCard.large({
    Key? key,
    required String label,
    required String value,
    String? unit,
    String? statusLabel,
    Color? statusColor,
    required IconData icon,
    Color? iconColor,
    List<double>? trendData,
    VoidCallback? onTap,
    bool showAddIcon = false,
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
      showAddIcon: showAddIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardBg = colorScheme.surfaceContainerLow;
    final primaryColor = colorScheme.primary;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final effectiveIconColor = iconColor ?? primaryColor;

    final isInactive = statusLabel == 'Tap to log' ||
        statusLabel == 'Tap to sync' ||
        statusLabel == 'Not logged' ||
        value == '--' ||
        value == '--/--';
    final effectiveStatusColor = isInactive ? onSurfaceVariant : primaryColor;

    return SpringPressable(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 20 : 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: tonal circular icon + label + unified trailing arrow
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: effectiveIconColor.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: Icon(icon, size: 20, color: effectiveIconColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 18,
                  color: onSurfaceVariant,
                ),
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
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                    letterSpacing: -0.5,
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
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Plain text status (no pill box)
            if (statusLabel != null)
              Text(
                statusLabel!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: effectiveStatusColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            // Sparkline trend
            if (trendData != null && trendData!.length >= 2) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: isLarge ? 44 : 28,
                child: MiniSparkline(
                  data: trendData!,
                  lineColor: primaryColor,
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
