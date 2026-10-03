import 'package:flutter/material.dart';

// ── AarogyaLogoDynamic ────────────────────────────────────────────────────────
// Static gold mandala logo widget using the real image asset.
// Used in Login, Register, and any other screen that needs the brand logo.
// The [animate] flag adds a soft golden glow pulse effect when true.

class AarogyaLogoDynamic extends StatefulWidget {
  final double size;
  final bool animate;

  const AarogyaLogoDynamic({
    super.key,
    this.size = 120,
    this.animate = true,
  });

  @override
  State<AarogyaLogoDynamic> createState() => _AarogyaLogoDynamicState();
}

class _AarogyaLogoDynamicState extends State<AarogyaLogoDynamic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _pulse = Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AarogyaLogoDynamic oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Respond to animate flag changes without rebuilding the whole widget
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing outer gold glow — only visible when animate is true
              if (widget.animate)
                Transform.scale(
                  scale: _pulse.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD400).withValues(alpha: 0.22),
                          blurRadius: widget.size * 0.35,
                          spreadRadius: widget.size * 0.04,
                        ),
                        BoxShadow(
                          color: const Color(0xFFFF8C00).withValues(alpha: 0.12),
                          blurRadius: widget.size * 0.55,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),

              // The actual mandala image — transparent background
              Image.asset(
                'assets/images/app_logo.jpg',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      },
    );
  }
}
