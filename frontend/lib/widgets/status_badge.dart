import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

/// Google Health-style status badge — "In range", "Elevated", "Critical" etc.
/// Pill-shaped with color-coded background tint.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.fontSize = 11,
  });

  /// Factory constructors for common health statuses
  factory StatusBadge.inRange() => const StatusBadge(label: 'In range', color: AppTheme.accentGreen);
  factory StatusBadge.elevated() => const StatusBadge(label: 'Elevated', color: AppTheme.accentYellow);
  factory StatusBadge.high() => const StatusBadge(label: 'High', color: AppTheme.accentOrange);
  factory StatusBadge.critical() => const StatusBadge(label: 'Critical', color: AppTheme.accentRed);
  factory StatusBadge.good() => const StatusBadge(label: 'Good', color: AppTheme.accentGreen);
  factory StatusBadge.moderate() => const StatusBadge(label: 'Moderate', color: AppTheme.accentYellow);
  factory StatusBadge.poor() => const StatusBadge(label: 'Poor', color: AppTheme.accentOrange);
  factory StatusBadge.custom(String label, Color color) => StatusBadge(label: label, color: color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
