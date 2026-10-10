import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

/// Google Health-style environment card showing AQI + Weather in one card.
/// Displays AQI value with CPCB color coding, temperature, and humidity.
class EnvironmentCard extends StatelessWidget {
  final int? aqi;
  final String? aqiStatus;
  final String? station;
  final double? temperature;
  final int? humidity;
  final String? advisory;
  final VoidCallback? onTap;

  const EnvironmentCard({
    super.key,
    this.aqi,
    this.aqiStatus,
    this.station,
    this.temperature,
    this.humidity,
    this.advisory,
    this.onTap,
  });

  Color _aqiColor(int aqi) {
    if (aqi <= 50) return AppTheme.accentGreen;
    if (aqi <= 100) return AppTheme.accentYellow;
    if (aqi <= 200) return AppTheme.accentOrange;
    if (aqi <= 300) return AppTheme.accentRed;
    return const Color(0xFF7C2D12);
  }

  String _aqiLabel(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 200) return 'Poor';
    if (aqi <= 300) return 'Very Poor';
    return 'Severe';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.surfaceL1 : AppTheme.surfaceL1Light;
    final borderCol = isDark ? AppTheme.glassBorderLight : AppTheme.glassBorderLightModeSubtle;
    final aqiVal = aqi ?? 0;
    final color = _aqiColor(aqiVal);
    final status = aqiStatus ?? _aqiLabel(aqiVal);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: borderCol, width: 1),
          boxShadow: isDark ? null : AppTheme.cardShadowLight,
        ),
        child: Row(
          children: [
            // AQI badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.air_rounded, size: 18, color: color),
                  const SizedBox(height: 2),
                  Text(
                    '$aqiVal',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'AQI · $status',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      if (station != null) ...[
                        const Spacer(),
                        Flexible(
                          child: Text(
                            station!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.textMutedOf(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (temperature != null) ...[
                        Icon(Icons.thermostat_outlined, size: 14,
                            color: AppTheme.textSecondaryOf(context)),
                        const SizedBox(width: 3),
                        Text(
                          '${temperature!.round()}°C',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryOf(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (humidity != null) ...[
                        Icon(Icons.water_drop_outlined, size: 14,
                            color: AppTheme.textSecondaryOf(context)),
                        const SizedBox(width: 3),
                        Text(
                          '$humidity%',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryOf(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (advisory != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      advisory!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMutedOf(context),
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            if (onTap != null)
              Icon(Icons.chevron_right_rounded, size: 20,
                  color: AppTheme.textMutedOf(context)),
          ],
        ),
      ),
    );
  }
}
