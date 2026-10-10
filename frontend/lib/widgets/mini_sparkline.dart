import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Tiny inline sparkline chart for metric cards.
/// Renders the last N data points as a smooth line with optional gradient fill.
/// Inspired by Google Health heart rate / weight trend mini-charts.
class MiniSparkline extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final Color? fillColor;
  final double height;
  final double strokeWidth;

  const MiniSparkline({
    super.key,
    required this.data,
    this.lineColor = AppTheme.primaryTeal,
    this.fillColor,
    this.height = 32,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return SizedBox(height: height);
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _SparklinePainter(
        data: data,
        lineColor: lineColor,
        fillColor: fillColor ?? lineColor.withValues(alpha: 0.1),
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final double strokeWidth;

  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minVal = data.reduce(min);
    final maxVal = data.reduce(max);
    final range = maxVal - minVal;
    // Avoid division by zero for flat data
    final effectiveRange = range == 0 ? 1.0 : range;

    final points = <Offset>[];
    final padding = 2.0;
    final drawWidth = size.width - padding * 2;
    final drawHeight = size.height - padding * 2;

    for (int i = 0; i < data.length; i++) {
      final x = padding + (i / (data.length - 1)) * drawWidth;
      final normalizedY = (data[i] - minVal) / effectiveRange;
      final y = padding + drawHeight - (normalizedY * drawHeight);
      points.add(Offset(x, y));
    }

    // Draw gradient fill
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      // Smooth cubic Bezier between points
      final prev = points[i - 1];
      final curr = points[i];
      final cpX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw end dot
    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(points.last, 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.data != data || old.lineColor != lineColor;
}
