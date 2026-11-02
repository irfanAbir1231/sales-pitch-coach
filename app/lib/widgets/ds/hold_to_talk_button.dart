import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';
import '../../theme/app_theme.dart';

/// Big push-to-talk button: speech runs while the finger is down and ends the
/// moment it lifts. It feels weighty: the face sinks onto a thick edge with a
/// heavy haptic, springs back with a little overshoot on release, and while
/// listening soft ripples spread out from it. At rest it slowly "breathes".
class HoldToTalkButton extends StatefulWidget {
  const HoldToTalkButton({
    super.key,
    required this.listening,
    required this.onStart,
    required this.onEnd,
    this.enabled = true,
    this.size = 112,
  });

  final bool listening;
  final bool enabled;
  final double size;
  final VoidCallback onStart;

  /// Called on release; [held] is how long the finger stayed down.
  final void Function(Duration held) onEnd;

  @override
  State<HoldToTalkButton> createState() => _HoldToTalkButtonState();
}

class _HoldToTalkButtonState extends State<HoldToTalkButton> with TickerProviderStateMixin {
  static const _depth = 8.0;

  /// Press amount: 0 at rest, 1 fully pressed. Unbounded so the release spring can overshoot.
  late final AnimationController _press = AnimationController.unbounded(vsync: this, value: 0);
  late final AnimationController _ripple = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900));
  late final AnimationController _breath = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
    ..repeat(reverse: true);
  bool _down = false;
  final _clock = Stopwatch();

  @override
  void didUpdateWidget(HoldToTalkButton old) {
    super.didUpdateWidget(old);
    if (widget.listening && !_ripple.isAnimating) _ripple.repeat();
    if (!widget.listening && _ripple.isAnimating) _ripple.stop();
  }

  @override
  void dispose() {
    _press.dispose();
    _ripple.dispose();
    _breath.dispose();
    super.dispose();
  }

  void _pressDown() {
    if (!widget.enabled || _down) return;
    _down = true;
    _clock
      ..reset()
      ..start();
    HapticFeedback.heavyImpact();
    _press.animateTo(1, duration: const Duration(milliseconds: 110), curve: Curves.easeOut);
    setState(() {});
    widget.onStart();
  }

  void _release() {
    if (!_down) return;
    _down = false;
    _clock.stop();
    HapticFeedback.mediumImpact();
    // Spring back with a slight overshoot.
    _press.animateWith(SpringSimulation(const SpringDescription(mass: 1, stiffness: 320, damping: 13), _press.value, 0, 0));
    setState(() {});
    widget.onEnd(_clock.elapsed);
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.listening || _down;
    final face = !widget.enabled ? AppColors.border : (on ? AppColors.red : AppColors.primary);
    final edge = !widget.enabled ? AppColors.disabled : (on ? AppColors.redLight : AppColors.primaryDeep);
    final size = widget.size;
    final area = size * 1.9;

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: context.l10n.holdToTalk,
      excludeSemantics: true,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _pressDown(),
        onPointerUp: (_) => _release(),
        onPointerCancel: (_) => _release(),
        child: SizedBox(
          width: area,
          height: area,
          child: AnimatedBuilder(
            animation: Listenable.merge([_press, _ripple, _breath]),
            builder: (context, _) {
              final p = _press.value;
              final pressed = p.clamp(0.0, 1.0);
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Idle halo that slowly breathes.
                  if (!on && widget.enabled)
                    Container(
                      width: size * (1.12 + 0.1 * _breath.value),
                      height: size * (1.12 + 0.1 * _breath.value),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: face.withValues(alpha: 0.10 + 0.05 * _breath.value)),
                    ),
                  // Ripples spreading out while listening.
                  if (on)
                    for (final shift in const [0.0, 0.33, 0.66])
                      _ring(size, area, (_ripple.value + shift) % 1.0, face),
                  Transform.scale(
                    scale: 1 - 0.07 * p,
                    child: Transform.translate(
                      offset: Offset(0, _depth * pressed),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: face,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: edge, offset: Offset(0, _depth * (1 - pressed)))],
                        ),
                        child: Transform.scale(
                          scale: on ? 1 + 0.06 * math.sin(_ripple.value * math.pi * 2 * 2) : 1,
                          child: Icon(AppIcons.micFill, color: widget.enabled ? Colors.white : AppColors.textMuted, size: size * 0.44),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _ring(double size, double area, double t, Color color) {
    final eased = Curves.easeOut.transform(t);
    final d = size + (area - size) * eased;
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.45 * (1 - eased)), width: 3),
        color: color.withValues(alpha: 0.10 * (1 - eased)),
      ),
    );
  }
}
