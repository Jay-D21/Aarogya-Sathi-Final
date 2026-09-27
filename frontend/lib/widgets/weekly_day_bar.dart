import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

/// Weekly day bar showing M T W T F S S with completion indicators.
/// Inspired by Google Health & Google Fit activity/sleep day-by-day trackers.
/// 7-day horizontal step progress bar. Each day circle is filled
/// proportionally to the daily step goal and highlighted in primary
/// colour for the current day with a dot indicator beneath it.
class WeeklyDayBar extends StatelessWidget {
  final List<bool> completedDays; // 7 days: Mon..Sun
  final int todayIndex; // 0..6 (0=Mon, 6=Sun)
  final Color activeColor;

  const WeeklyDayBar({
    super.key,
    required this.completedDays,
    this.todayIndex = 6,
    this.activeColor = AppTheme.primaryTeal,
  });

  static const List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isToday = i == todayIndex;
        final isCompleted = i < completedDays.length && completedDays[i];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _dayLabels[i],
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday
                    ? primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainer,
                border: isCompleted
                    ? null
                    : Border.all(
                        color: isToday ? primary : colorScheme.outlineVariant,
                        width: 1.5,
                      ),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: colorScheme.onPrimaryContainer,
                      )
                    : (isToday
                        ? Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primary,
                            ),
                          )
                        : null),
              ),
            ),
          ],
        );
      }),
    );
  }
}
