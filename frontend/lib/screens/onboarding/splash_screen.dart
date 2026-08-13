import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

// ── Splash Screen ─────────────────────────────────────────────────────────────
// Opening animation sequence:
//   Phase 1 (0–800ms): Gold mandala appears small (icon-sized, ~80px), centered.
//                       Mimics the launcher icon so the transition feels seamless.
//   Phase 2 (400–1400ms): Mandala scales up from icon-size to full (240px),
//                          with a slow glowing pulse — feels like it "wakes up".
//   Phase 3 (900–1800ms): App name, subtitle, and loading bar fade+slide in.
//   Phase 4 (3000ms): Navigate to home/login.

/// Animated splash screen shown on cold app launch. Checks for
/// a persisted auth token and routes to HomeScreen or LoginScreen
/// accordingly after the brand animation completes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Phase 1: logo appears (fade in from transparent)
  late AnimationController _fadeInCtrl;
  late Animation<double> _logoFadeIn;

  // Phase 2: logo scales from icon-size to full-size (the key transition)
  late AnimationController _scaleCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _glowPulse;

  // Phase 3: text content slides in
  late AnimationController _contentCtrl;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _barFade;

  @override
  void initState() {
    super.initState();

    // Phase 1 — logo fades in quickly (mimics system splash fading out)
    _fadeInCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _logoFadeIn = CurvedAnimation(parent: _fadeInCtrl, curve: Curves.easeOut);

    // Phase 2 — logo scales from 0.30 (icon-size) to 1.0 (full), with elastic feel
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _logoScale = Tween<double>(begin: 0.30, end: 1.0).animate(
        CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut));

    // Glow pulse repeats after scale is done — mandala "breathes"
    _glowPulse = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));

    // Phase 3 — text fades in after logo has expanded
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _textFade = CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentCtrl,
                curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)));
    _barFade = CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut));

    // ── Sequence ──────────────────────────────────────────────────────────────
    // t=0ms:   Phase 1 starts (logo appears)
    // t=200ms: Phase 2 starts (logo scales up from icon to full)
    // t=900ms: Phase 3 starts (text+bar slide in)
    // t=3000ms: Navigate
    _fadeInCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _scaleCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _contentCtrl.forward();
    });
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
    _fadeInCtrl.dispose();
    _scaleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always dark background for splash — required by the design system
    const bg = Color(0xFF080D1A);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Ambient background glow — top-right warm gold ──────────────────
          Positioned(
            top: -120,
            right: -100,
            child: FadeTransition(
              opacity: _textFade,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFFFFB300).withValues(alpha: 0.14),
                    const Color(0xFF00D9C0).withValues(alpha: 0.05),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),
          // ── Ambient background glow — bottom-left amber-purple ────────────
          Positioned(
            bottom: -80,
            left: -80,
            child: FadeTransition(
              opacity: _textFade,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFFFF8F00).withValues(alpha: 0.10),
                    AppTheme.accentPurple.withValues(alpha: 0.07),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),

          // ── Main content ────────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo with icon-to-splash scale transition ──────────────
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_fadeInCtrl, _scaleCtrl]),
                  builder: (_, _) {
                    return FadeTransition(
                      opacity: _logoFadeIn,
                      child: Transform.scale(
                        // Scale from 0.30 (icon) → 1.0 (full splash logo)
                        // The elasticOut curve gives a satisfying "snap" feel
                        scale: _logoScale.value,
                        child: _AppSplashLogo(
                          pulse: _glowPulse.value,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // ── App name ──────────────────────────────────────────────────
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [
                          Color(0xFF8AB4F8), // periwinkle
                          Color(0xFF00BFA5), // teal accent
                          Color(0xFF66F7E2), // luminous mint
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
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        Text(
                          'आरोग्य साथी',
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 13,
                            // Gold for the Sanskrit name — Ayurvedic identity
                            color:
                                const Color(0xFFFFB300).withValues(alpha: 0.85),
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

                const SizedBox(height: 52),

                // ── Loading bar ───────────────────────────────────────────
                FadeTransition(
                  opacity: _barFade,
                  child: const _AppLoadingBar(),
                ),
              ],
            ),
          ),

          // ── Bottom footer ─────────────────────────────────────────────────
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _barFade,
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
        ],
      ),
    );
  }
}

// ── Gold Mandala Splash Logo ──────────────────────────────────────────────────
// Uses the real generated image asset. Has a soft glow animation ring around it.
class _AppSplashLogo extends StatelessWidget {
  final double pulse;

  const _AppSplashLogo({this.pulse = 1.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring that pulses — matches the gold neon in the image
          Transform.scale(
            scale: pulse,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00BFA5).withValues(alpha: 0.22),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.16),
                    blurRadius: 70,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // The actual gold mandala image — transparent background
          Image.asset(
            'assets/images/app_logo.png',
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

// ── Gold Loading Bar ──────────────────────────────────────────────────────────
// A simple animated sweep bar in the gold palette — replaces the MandalaLoadingBar.
class _AppLoadingBar extends StatefulWidget {
  const _AppLoadingBar();

  @override
  State<_AppLoadingBar> createState() => _AppLoadingBarState();
}

class _AppLoadingBarState extends State<_AppLoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _sweep = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sweep,
      builder: (_, _) => SizedBox(
        width: 120,
        height: 3,
        child: CustomPaint(painter: _AppBarPainter(_sweep.value)),
      ),
    );
  }
}

class _AppBarPainter extends CustomPainter {
  final double progress;
  _AppBarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Track
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(2)),
      Paint()..color = const Color(0xFF00BFA5).withValues(alpha: 0.15),
    );

    // Sweep — gold gradient bar
    final sweepW = size.width * 0.45;
    final start = (size.width + sweepW) * progress - sweepW;
    final rect = Rect.fromLTWH(start, 0, sweepW, size.height);

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF4285F4).withValues(alpha: 0.9),
          const Color(0xFF00BFA5),
          const Color(0xFF00C853).withValues(alpha: 0.9),
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
  }

  @override
  bool shouldRepaint(covariant _AppBarPainter old) => old.progress != progress;
}
