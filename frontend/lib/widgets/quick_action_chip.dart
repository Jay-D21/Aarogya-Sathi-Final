import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pill-shaped quick action chip button (e.g. '+ Log', 'AI Chat', 'Scan Prescriptions')
/// Styled after Google Health / Fit action chips.
/// Horizontally scrollable Material 3 ActionChip used in HomeScreen
/// to surface common tasks: Log BP, Log Sugar, Log Weight, View Report.
/// Tapping navigates directly to the relevant logging bottom sheet.
class QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool isPrimary;

  const QuickActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isPrimary
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: isPrimary
                    ? colorScheme.onPrimaryContainer
                    : (color ?? colorScheme.primary),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
