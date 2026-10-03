import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

// ── Splash Screen ─────────────────────────────────────────────────────────────
// Logo concept: Ancient Indian Ayurvedic mandala fused with modern tech.
// Layers (outermost → innermost):
//   1. Outer circuit-board orbit ring with node dots (tech)
//   2. Sacred-geometry octagram with 8 petal lotus outline (ancient)
//   3. Rotating DNA-helix sweeping arc (modern science)
//   4. Inner lotus silhouette (Ayurveda)
//   5. Om (ॐ) glyph at center (ancient wisdom)
// All drawn via CustomPainter — zero image assets required.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _buildCtrl;   // logo construction sweep
  late AnimationController _spinCtrl;    // continuous DNA-helix spin
  late AnimationController _contentCtrl; // text + dots fade-in
  late AnimationController _pulseCtrl;   // center glow pulse

  late Animation<double> _buildAnim;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _dotFade;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Logo builds up over 1.4s
    _buildCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _buildAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _buildCtrl, curve: Curves.easeOutCubic));

    // DNA ring spins continuously
    _spinCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat();

    // Text fades in after logo
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _contentCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _textFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _contentCtrl,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOut)));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentCtrl,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)));
    _dotFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _contentCtrl,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut)));

    // Center pulse loop
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Start sequence
    _buildCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500),
        () { if (mounted) _contentCtrl.forward(); });

    Future.delayed(const Duration(milliseconds: 3000), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    int waited = 0;
    while (auth.isLoading && waited < 2000) {
      await Future.delayed(const Duration(milliseconds: 100));
      waited += 100;
    }
    if (!mounted) return;

    if (auth.isLoggedIn) {
      if (auth.needsOnboarding) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _buildCtrl.dispose();
    _spinCtrl.dispose();
    _contentCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always use dark background for splash — the design requires it
    const bg = Color(0xFF080D1A);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Deep ambient radial glow (top-right) ──────────────────────────
          Positioned(
            top: -120,
            right: -100,
            child: AnimatedBuilder(
              animation: _buildAnim,
              builder: (_, _) => Opacity(
                opacity: (_buildAnim.value * 0.55).clamp(0, 1),
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      const Color(0xFF00D9C0).withValues(alpha: 0.18),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),
          // ── Deep ambient glow (bottom-left) ───────────────────────────────
          Positioned(
            bottom: -80,
            left: -80,
            child: AnimatedBuilder(
              animation: _buildAnim,
              builder: (_, _) => Opacity(
                opacity: (_buildAnim.value * 0.4).clamp(0, 1),
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppTheme.accentPurple.withValues(alpha: 0.15),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── The Logo ─────────────────────────────────────────────
                SizedBox(
                  width: 200,
                  height: 200,
                  child: AnimatedBuilder(
                    animation: Listenable.merge(
                        [_buildAnim, _spinCtrl, _pulseAnim]),
                    builder: (_, _) => CustomPaint(
                      painter: _AyurTechLogoPainter(
                        buildProgress: _buildAnim.value,
                        spinProgress: _spinCtrl.value,
                        pulse: _pulseAnim.value,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ── App name ─────────────────────────────────────────────
                AnimatedBuilder(
                  animation: _contentCtrl,
                  builder: (_, _) => Opacity(
                    opacity: _logoFade.value.clamp(0, 1),
                    child: ShaderMask(
                      shaderCallback: (b) =>
                          AppTheme.primaryGradient.createShader(b),
                      child: Text(
                        'Aarogya Sathi',
                        style: GoogleFonts.outfit(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // ── Sanskrit subtitle ─────────────────────────────────────
                AnimatedBuilder(
                  animation: _contentCtrl,
                  builder: (_, _) => FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          Text(
                            'आरोग्य साथी',
                            style: GoogleFonts.notoSansDevanagari(
                              fontSize: 13,
                              color: const Color(0xFF00D9C0).withValues(alpha: 0.75),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your AI Wellness Companion',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.45),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 52),

                // ── Loading indicator ─────────────────────────────────────
                AnimatedBuilder(
                  animation: _contentCtrl,
                  builder: (_, _) => Opacity(
                    opacity: _dotFade.value.clamp(0, 1),
                    child: const _MandalaLoadingBar(),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom footer ─────────────────────────────────────────────────
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _contentCtrl,
              builder: (_, _) => Opacity(
                opacity: _dotFade.value.clamp(0, 1),
                child: Text(
                  'ICMR-Guided  ·  Privacy-First  ·  Made for India 🇮🇳',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: Colors.white.withValues(alpha: 0.28),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _AyurTechLogoPainter
// Draws a 5-layer mandala-tech logo on a 200×200 canvas:
//   Layer 1: Outer circuit orbit ring + 8 node dots
//   Layer 2: 8-pointed star / octagram (sacred geometry)
//   Layer 3: Sweeping DNA-like twin arcs (rotating)
//   Layer 4: 8-petal lotus silhouette
//   Layer 5: Center circle + Om (ॐ) glyph
// ══════════════════════════════════════════════════════════════════════════════

class _AyurTechLogoPainter extends CustomPainter {
  final double buildProgress; // 0→1 as logo appears
  final double spinProgress;  // 0→1 continuous rotation
  final double pulse;         // 0.85→1.0 glow pulse

  static const _teal  = Color(0xFF00D9C0);
  static const _cyan  = Color(0xFF00BCD4);
  static const _gold  = Color(0xFFFFD54F);

  _AyurTechLogoPainter({
    required this.buildProgress,
    required this.spinProgress,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    // Build progress drives opacity and scale of each layer
    final p = buildProgress.clamp(0.0, 1.0);

    // ── Layer 1: Outer circuit ring ─────────────────────────────────────────
    _drawCircuitRing(canvas, center, 94, p);

    // ── Layer 2: Sacred 8-pointed geometry ─────────────────────────────────
    _drawSacredStar(canvas, center, 74, p);

    // ── Layer 3: Rotating DNA twin-arc helix ────────────────────────────────
    _drawDNAHelix(canvas, center, 60, p);

    // ── Layer 4: Lotus petals ───────────────────────────────────────────────
    _drawLotus(canvas, center, 44, p);

    // ── Layer 5: Center glow + Om glyph ────────────────────────────────────
    _drawCenter(canvas, center, 26, p);
  }

  // ── Layer 1: Circuit orbit ring with 8 node dots ─────────────────────────
  void _drawCircuitRing(Canvas canvas, Offset center, double r, double p) {
    // Main ring (builds up clockwise)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _teal.withValues(alpha: p * 0.45)
      ..shader = SweepGradient(colors: [
        _teal.withValues(alpha: p),
        _cyan.withValues(alpha: p * 0.3),
        _teal.withValues(alpha: p),
      ]).createShader(Rect.fromCircle(center: center, radius: r));

    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        -math.pi / 2, 2 * math.pi * p, false, ringPaint);

    // Outer faint glow ring
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = _teal.withValues(alpha: p * 0.15);
    canvas.drawCircle(center, r + 6, glowPaint);

    if (p < 0.3) return;

    // 8 node dots at equal angles, with small circuit "stems"
    for (int i = 0; i < 8; i++) {
      final angle = (2 * math.pi * i / 8) - math.pi / 2;
      final nodeAlpha = ((p - 0.3) / 0.7).clamp(0.0, 1.0);

      final nodeX = center.dx + r * math.cos(angle);
      final nodeY = center.dy + r * math.sin(angle);
      final nodeCenter = Offset(nodeX, nodeY);

      // Glowing node dot
      final dotPaint = Paint()
        ..color = _teal.withValues(alpha: nodeAlpha * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(nodeCenter, 3.5, dotPaint);

      final dotSolid = Paint()..color = _teal.withValues(alpha: nodeAlpha);
      canvas.drawCircle(nodeCenter, 2.5, dotSolid);

      // Short circuit stem inward
      final stemInner = Offset(
        center.dx + (r - 14) * math.cos(angle),
        center.dy + (r - 14) * math.sin(angle),
      );
      canvas.drawLine(nodeCenter, stemInner,
          Paint()
            ..color = _teal.withValues(alpha: nodeAlpha * 0.5)
            ..strokeWidth = 1.0);
    }
  }

  // ── Layer 2: 8-pointed star (sacred geometry / yantra) ────────────────────
  void _drawSacredStar(Canvas canvas, Offset center, double r, double p) {
    if (p < 0.2) return;
    final alpha = ((p - 0.2) / 0.8).clamp(0.0, 1.0);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _teal.withValues(alpha: alpha * 0.35);

    // Two overlapping squares form an 8-pointed star (octagram)
    for (int sq = 0; sq < 2; sq++) {
      final startAngle = sq * math.pi / 4 - math.pi / 4;
      final path = Path();
      for (int v = 0; v < 4; v++) {
        final angle = startAngle + v * math.pi / 2;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (v == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // Subtle inner hexagon-like detail ring
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = _gold.withValues(alpha: alpha * 0.20);
    canvas.drawCircle(center, r * 0.72, innerPaint);
  }

  // ── Layer 3: DNA-inspired twin sweeping arcs (rotating) ───────────────────
  void _drawDNAHelix(Canvas canvas, Offset center, double r, double p) {
    if (p < 0.35) return;
    final alpha = ((p - 0.35) / 0.65).clamp(0.0, 1.0);
    final spin  = spinProgress * 2 * math.pi;

    // Draw two arcs 180° apart = double-helix effect when rotating
    for (int h = 0; h < 2; h++) {
      final offset = h * math.pi;
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = _teal.withValues(alpha: 0.0)
        ..shader = SweepGradient(
          startAngle: spin + offset,
          endAngle: spin + offset + math.pi,
          colors: [
            _teal.withValues(alpha: alpha * 0.9),
            _cyan.withValues(alpha: alpha * 0.5),
            _teal.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r));

      // Glow pass
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = _teal.withValues(alpha: 0.0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..shader = SweepGradient(
          startAngle: spin + offset,
          endAngle: spin + offset + math.pi,
          colors: [
            _teal.withValues(alpha: alpha * 0.4 * pulse),
            _cyan.withValues(alpha: alpha * 0.2 * pulse),
            _teal.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r));

      canvas.drawArc(Rect.fromCircle(center: center, radius: r),
          spin + offset, math.pi, false, glowPaint);
      canvas.drawArc(Rect.fromCircle(center: center, radius: r),
          spin + offset, math.pi, false, arcPaint);
    }

    // 3 cross-bar "rungs" of the DNA ladder at rotating angles
    for (int rung = 0; rung < 3; rung++) {
      final rungAngle = spin + rung * (2 * math.pi / 3);
      final rungAlpha = alpha * 0.45;
      final start = Offset(
        center.dx + r * math.cos(rungAngle),
        center.dy + r * math.sin(rungAngle),
      );
      final end = Offset(
        center.dx + r * math.cos(rungAngle + math.pi),
        center.dy + r * math.sin(rungAngle + math.pi),
      );
      canvas.drawLine(start, end,
          Paint()
            ..color = _cyan.withValues(alpha: rungAlpha)
            ..strokeWidth = 1.0);
    }
  }

  // ── Layer 4: Lotus flower (8 petals — Ashtadala Padma) ────────────────────
  void _drawLotus(Canvas canvas, Offset center, double r, double p) {
    if (p < 0.5) return;
    final alpha = ((p - 0.5) / 0.5).clamp(0.0, 1.0);

    // 8 petals, each a bezier ellipse rotated around center
    for (int i = 0; i < 8; i++) {
      final angle = (2 * math.pi * i / 8) - math.pi / 2;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      // Petal body: tall, narrow oval shifted outward
      final petalPath = Path();
      final petalX = r * 0.45;
      final petalW = r * 0.30;
      final petalH = r * 0.85;

      petalPath.moveTo(0, 0);
      petalPath.cubicTo(
        -petalW, -petalH * 0.3,
        -petalW * 0.5, -petalH,
        petalX, -petalH,
      );
      petalPath.cubicTo(
        petalX + petalW * 0.5, -petalH,
        petalX + petalW, -petalH * 0.3,
        0, 0,
      );
      petalPath.close();

      // Subtle petal fill
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            _teal.withValues(alpha: alpha * 0.12),
            _teal.withValues(alpha: alpha * 0.06),
          ],
        ).createShader(Rect.fromLTWH(-petalW, -petalH, petalW * 2, petalH));
      canvas.drawPath(petalPath, fillPaint);

      // Petal outline stroke
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = _teal.withValues(alpha: alpha * 0.55);
      canvas.drawPath(petalPath, strokePaint);

      // Petal vein line
      canvas.drawLine(
        const Offset(0, 0),
        Offset(petalX * 0.5, -petalH * 0.75),
        Paint()
          ..color = _teal.withValues(alpha: alpha * 0.3)
          ..strokeWidth = 0.5,
      );

      canvas.restore();
    }
  }

  // ── Layer 5: Center glow disc + Om glyph ──────────────────────────────────
  void _drawCenter(Canvas canvas, Offset center, double r, double p) {
    if (p < 0.6) return;
    final alpha = ((p - 0.6) / 0.4).clamp(0.0, 1.0);

    // Outer glow halo
    final haloPaint = Paint()
      ..color = _teal.withValues(alpha: alpha * 0.25 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, r * 1.4, haloPaint);

    // Gradient fill disc
    final discPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          _teal.withValues(alpha: alpha * 0.95),
          _cyan.withValues(alpha: alpha * 0.6),
          const Color(0xFF006064).withValues(alpha: alpha * 0.9),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, discPaint);

    // Thin border ring
    canvas.drawCircle(center, r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _teal.withValues(alpha: alpha * 0.6));

    // ॐ symbol drawn as a TextPainter (Unicode U+0950)
    if (alpha > 0.5) {
      final textAlpha = ((alpha - 0.5) / 0.5).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: 'ॐ',
          style: TextStyle(
            fontSize: r * 1.1,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: textAlpha * 0.92),
            // System default handles Devanagari Unicode on all Android devices
            height: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_AyurTechLogoPainter old) =>
      old.buildProgress != buildProgress ||
      old.spinProgress != spinProgress ||
      old.pulse != pulse;
}

// ══════════════════════════════════════════════════════════════════════════════
// _MandalaLoadingBar — thin teal progress line replacing the 3 dots
// ══════════════════════════════════════════════════════════════════════════════

class _MandalaLoadingBar extends StatefulWidget {
  const _MandalaLoadingBar();

  @override
  State<_MandalaLoadingBar> createState() => _MandalaLoadingBarState();
}

class _MandalaLoadingBarState extends State<_MandalaLoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        size: const Size(80, 3),
        painter: _LoadingBarPainter(_ctrl.value),
      ),
    );
  }
}

class _LoadingBarPainter extends CustomPainter {
  final double t;
  _LoadingBarPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Track
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(2)),
      Paint()..color = const Color(0xFF00D9C0).withValues(alpha: 0.15),
    );

    // Sliding glowing segment
    const segW = 28.0;
    final travel = size.width + segW;
    final x = (t * travel) - segW;

    final segRect = Rect.fromLTWH(x.clamp(-segW, size.width), 0,
        segW, size.height);

    // Glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(segRect, const Radius.circular(2)),
      Paint()
        ..color = const Color(0xFF00D9C0).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Solid
    canvas.drawRRect(
      RRect.fromRectAndRadius(segRect, const Radius.circular(2)),
      Paint()
        ..shader = const LinearGradient(colors: [
          Color(0xFF00D9C0),
          Color(0xFF00BCD4),
          Color(0xFF00D9C0),
        ]).createShader(segRect),
    );
  }

  @override
  bool shouldRepaint(_LoadingBarPainter old) => old.t != t;
}
