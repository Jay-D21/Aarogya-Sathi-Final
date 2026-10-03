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
          // ── Deep ambient radial glow (top-right) — golden warmth ───────────
          Positioned(
            top: -120,
            right: -100,
            child: AnimatedBuilder(
              animation: _buildAnim,
              builder: (_, _) => Opacity(
                opacity: (_buildAnim.value * 0.5).clamp(0, 1),
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      const Color(0xFFFFB300).withValues(alpha: 0.14), // warm gold
                      const Color(0xFF00D9C0).withValues(alpha: 0.06), // teal fade
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),
          // ── Deep ambient glow (bottom-left) — amber-purple depth ───────────
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
                      const Color(0xFFFF8F00).withValues(alpha: 0.10), // deep amber
                      AppTheme.accentPurple.withValues(alpha: 0.08),
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
                      // Gold-to-teal gradient on the app name for premium feel
                      shaderCallback: (b) => const LinearGradient(
                        colors: [
                          Color(0xFFFFD700), // gold
                          Color(0xFFFFB300), // warm gold
                          Color(0xFF00D9C0), // teal accent
                        ],
                        stops: [0.0, 0.6, 1.0],
                      ).createShader(b),
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
                              // Gold for the Sanskrit name — premium Ayurvedic identity
                              color: const Color(0xFFFFB300).withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
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

  // Teal — tech/AI layer accent
  static const _teal  = Color(0xFF00D9C0);
  static const _cyan  = Color(0xFF26C6DA);
  // Gold palette — premium Ayurvedic warmth
  static const _gold      = Color(0xFFFFD700); // pure gold
  static const _goldLight = Color(0xFFFFF176); // pale gold highlight
  static const _goldDeep  = Color(0xFFFF8F00); // deep amber-gold
  static const _goldWarm  = Color(0xFFFFB300); // warm marigold

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
    // Main ring — gold-to-teal sweep (premium bimetallic look)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = _gold.withValues(alpha: p * 0.45)
      ..shader = SweepGradient(colors: [
        _gold.withValues(alpha: p * 0.9),
        _goldWarm.withValues(alpha: p * 0.7),
        _teal.withValues(alpha: p * 0.6),
        _cyan.withValues(alpha: p * 0.4),
        _gold.withValues(alpha: p * 0.9),
      ]).createShader(Rect.fromCircle(center: center, radius: r));

    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        -math.pi / 2, 2 * math.pi * p, false, ringPaint);

    // Outer faint gold glow ring
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _gold.withValues(alpha: p * 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center, r + 6, glowPaint);

    if (p < 0.3) return;

    // 8 node dots — alternating gold (cardinal) and teal (diagonal)
    for (int i = 0; i < 8; i++) {
      final angle = (2 * math.pi * i / 8) - math.pi / 2;
      final nodeAlpha = ((p - 0.3) / 0.7).clamp(0.0, 1.0);
      // Cardinal positions (top/bottom/left/right) = gold; diagonals = teal
      final isGoldNode = i % 2 == 0;
      final nodeColor = isGoldNode ? _gold : _teal;

      final nodeX = center.dx + r * math.cos(angle);
      final nodeY = center.dy + r * math.sin(angle);
      final nodeCenter = Offset(nodeX, nodeY);

      // Glowing halo
      canvas.drawCircle(nodeCenter, isGoldNode ? 5.0 : 3.5,
          Paint()
            ..color = nodeColor.withValues(alpha: nodeAlpha * pulse * 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

      // Solid core dot
      canvas.drawCircle(nodeCenter, isGoldNode ? 3.0 : 2.2,
          Paint()..color = nodeColor.withValues(alpha: nodeAlpha));

      // Short circuit stem inward
      final stemInner = Offset(
        center.dx + (r - 14) * math.cos(angle),
        center.dy + (r - 14) * math.sin(angle),
      );
      canvas.drawLine(nodeCenter, stemInner,
          Paint()
            ..color = nodeColor.withValues(alpha: nodeAlpha * 0.45)
            ..strokeWidth = 1.0);
    }
  }


  // ── Layer 2: 8-pointed star (sacred geometry / yantra) ────────────────────
  void _drawSacredStar(Canvas canvas, Offset center, double r, double p) {
    if (p < 0.2) return;
    final alpha = ((p - 0.2) / 0.8).clamp(0.0, 1.0);

    // Two overlapping squares form an 8-pointed star (octagram)
    // Square 1: gold; Square 2: slightly lighter gold with gradient
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

      // Subtle gold fill inside the overlapping star region
      canvas.drawPath(path,
          Paint()
            ..style = PaintingStyle.fill
            ..color = _gold.withValues(alpha: alpha * 0.055));

      // Gold stroke outline — sq==0 is deeper gold, sq==1 is warm gold
      canvas.drawPath(path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1
            ..color = (sq == 0 ? _gold : _goldWarm).withValues(alpha: alpha * 0.55));
    }

    // Inner detail ring — marigold tint
    canvas.drawCircle(center, r * 0.72,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = _goldLight.withValues(alpha: alpha * 0.30));

    // Tiny gold accent dot at each star-point tip
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 8;
      final dotPos = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      canvas.drawCircle(dotPos, 1.4,
          Paint()..color = _goldLight.withValues(alpha: alpha * 0.6));
    }
  }


  // ── Layer 3: DNA-inspired twin sweeping arcs (rotating) ───────────────────
  void _drawDNAHelix(Canvas canvas, Offset center, double r, double p) {
    if (p < 0.35) return;
    final alpha = ((p - 0.35) / 0.65).clamp(0.0, 1.0);
    final spin  = spinProgress * 2 * math.pi;

    // Arc 0 = gold (ancient); Arc 1 = teal (tech) → bimetallic double helix
    final arcColors = [
      [_gold, _goldDeep],
      [_teal, _cyan],
    ];

    for (int h = 0; h < 2; h++) {
      final offset     = h * math.pi;
      final c1 = arcColors[h][0];
      final c2 = arcColors[h][1];

      // Glow pass
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        spin + offset, math.pi, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..shader = SweepGradient(
            startAngle: spin + offset,
            endAngle:   spin + offset + math.pi,
            colors: [
              c1.withValues(alpha: alpha * 0.35 * pulse),
              c2.withValues(alpha: alpha * 0.18 * pulse),
              c1.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );

      // Solid arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        spin + offset, math.pi, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: spin + offset,
            endAngle:   spin + offset + math.pi,
            colors: [
              c1.withValues(alpha: alpha * 0.95),
              c2.withValues(alpha: alpha * 0.55),
              c1.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }

    // DNA ladder rungs — alternating gold and teal
    for (int rung = 0; rung < 4; rung++) {
      final rungAngle = spin + rung * (math.pi / 2);
      final isGoldRung = rung % 2 == 0;
      final rungColor = isGoldRung ? _goldWarm : _teal;
      final rungAlpha = alpha * (isGoldRung ? 0.60 : 0.40);

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
            ..color = rungColor.withValues(alpha: rungAlpha)
            ..strokeWidth = 1.2);

      // Small accent dots at rung endpoints
      canvas.drawCircle(start, 1.8,
          Paint()..color = rungColor.withValues(alpha: rungAlpha * 0.9));
      canvas.drawCircle(end, 1.8,
          Paint()..color = rungColor.withValues(alpha: rungAlpha * 0.9));
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

      // Petal body: tall, narrow oval
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

      // Golden gradient petal fill — deep amber at base, pale gold at tip
      canvas.drawPath(petalPath,
          Paint()
            ..style = PaintingStyle.fill
            ..shader = LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                _goldDeep.withValues(alpha: alpha * 0.28),
                _gold.withValues(alpha: alpha * 0.18),
                _goldLight.withValues(alpha: alpha * 0.08),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(Rect.fromLTWH(-petalW, -petalH, petalW * 2, petalH)));

      // Teal stroke outline for contrast with the golden fill
      canvas.drawPath(petalPath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.9
            ..color = _teal.withValues(alpha: alpha * 0.45));

      // Gold center vein
      canvas.drawLine(
        const Offset(0, 0),
        Offset(petalX * 0.5, -petalH * 0.78),
        Paint()
          ..color = _goldWarm.withValues(alpha: alpha * 0.50)
          ..strokeWidth = 0.6,
      );

      // Tiny gold tip accent dot at petal apex
      canvas.drawCircle(
        Offset(petalX, -petalH),
        1.5,
        Paint()..color = _goldLight.withValues(alpha: alpha * 0.65),
      );

      canvas.restore();
    }
  }


  // ── Layer 5: Center glow disc + Om glyph ──────────────────────────────────
  void _drawCenter(Canvas canvas, Offset center, double r, double p) {
    if (p < 0.6) return;
    final alpha = ((p - 0.6) / 0.4).clamp(0.0, 1.0);

    // Outer gold glow halo — double ring (gold + faint teal)
    canvas.drawCircle(center, r * 1.6,
        Paint()
          ..color = _gold.withValues(alpha: alpha * 0.20 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
    canvas.drawCircle(center, r * 1.2,
        Paint()
          ..color = _teal.withValues(alpha: alpha * 0.12 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // Gradient fill disc — warm gold center → deep amber edge (premium bullion look)
    canvas.drawCircle(center, r,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(
            colors: [
              _goldLight.withValues(alpha: alpha * 0.95), // bright center
              _gold.withValues(alpha: alpha * 0.88),      // true gold
              _goldDeep.withValues(alpha: alpha * 0.92),  // deep amber edge
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: r)));

    // Gold border ring with a thin teal inner accent
    canvas.drawCircle(center, r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = _goldLight.withValues(alpha: alpha * 0.70));
    canvas.drawCircle(center, r - 2.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6
          ..color = _teal.withValues(alpha: alpha * 0.35));

    // ॐ symbol — dark amber color so it contrasts against the bright gold disc
    if (alpha > 0.5) {
      final textAlpha = ((alpha - 0.5) / 0.5).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: 'ॐ',
          style: TextStyle(
            fontSize: r * 1.1,
            fontWeight: FontWeight.w900,
            // Dark amber color for Om text — maximum legibility on gold bg
            color: const Color(0xFF3E1A00).withValues(alpha: textAlpha * 0.88),
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
    // Track — subtle gold
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(2)),
      Paint()..color = const Color(0xFFFFB300).withValues(alpha: 0.18),
    );

    // Sliding glowing segment — gold → teal gradient
    const segW = 32.0;
    final travel = size.width + segW;
    final x = (t * travel) - segW;

    final segRect = Rect.fromLTWH(
        x.clamp(-segW, size.width), 0, segW, size.height);

    // Gold glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(segRect, const Radius.circular(2)),
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    // Solid gold→teal gradient segment
    canvas.drawRRect(
      RRect.fromRectAndRadius(segRect, const Radius.circular(2)),
      Paint()
        ..shader = LinearGradient(colors: const [
          Color(0xFFFFD700), // pure gold
          Color(0xFFFFB300), // warm gold
          Color(0xFF00D9C0), // teal
        ]).createShader(segRect),
    );
  }


  @override
  bool shouldRepaint(_LoadingBarPainter old) => old.t != t;
}
