import 'package:flutter/material.dart';

/// Material 3 Expressive spring-pressable feedback widget.
/// Scales down on press down and springs back smoothly on release or cancel.
/// Wraps any [child] widget with a spring-physics press animation.
/// On tap-down the child scales to [pressScale] with a spring curve,
/// reverting on tap-up. Provides tactile depth feedback without
/// requiring device haptics.
class SpringPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;
  final bool enabled;

  const SpringPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.96,
    this.duration = const Duration(milliseconds: 130),
    this.curve = Curves.easeInOutCubic,
    this.reverseCurve = Curves.easeOutBack,
    this.enabled = true,
  });

  @override
  State<SpringPressable> createState() => _SpringPressableState();
}

class _SpringPressableState extends State<SpringPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.enabled) {
      _ctrl.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.enabled) {
      _ctrl.reverse();
      widget.onTap?.call();
    }
  }

  void _onTapCancel() {
    if (widget.enabled) {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

/// Material 3 Expressive staggered entrance fade and slide transition.
class StaggeredFadeSlide extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  const StaggeredFadeSlide({
    super.key,
    required this.child,
    this.index = 0,
    this.delay,
    this.duration = const Duration(milliseconds: 420),
    this.offset = const Offset(0, 0.08),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _fade = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: widget.curve),
    );

    final effectiveDelay =
        widget.delay ?? Duration(milliseconds: 50 * widget.index);
    Future.delayed(effectiveDelay, () {
      if (mounted) {
        _ctrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
