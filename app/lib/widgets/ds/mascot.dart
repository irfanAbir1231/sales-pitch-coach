import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum MascotMood { happy, thinking, listening, celebrating, sad }

/// "Pitchy": a green speech-bubble character drawn entirely in code.
class Mascot extends StatefulWidget {
  const Mascot({super.key, this.mood = MascotMood.happy, this.size = 120, this.animate = true, this.talking = false});

  final MascotMood mood;
  final double size;
  final bool animate;

  /// Animates the mouth as if speaking.
  final bool talking;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with TickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
  late final AnimationController _talk = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _bob.repeat(reverse: true);
    if (widget.talking) _talk.repeat();
  }

  @override
  void didUpdateWidget(Mascot old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_bob.isAnimating) _bob.repeat(reverse: true);
    if (!widget.animate && _bob.isAnimating) _bob.stop();
    if (widget.talking && !_talk.isAnimating) _talk.repeat();
    if (!widget.talking && _talk.isAnimating) _talk.stop();
  }

  @override
  void dispose() {
    _bob.dispose();
    _talk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce && _bob.isAnimating) _bob.stop();
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _bob,
        builder: (context, child) {
          final dy = Curves.easeInOut.transform(_bob.value) * widget.size * 0.04;
          return Transform.translate(offset: Offset(0, -dy), child: child);
        },
        child: SizedBox.square(
          dimension: widget.size,
          child: CustomPaint(painter: _MascotPainter(widget.mood, widget.talking ? _talk : null)),
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter(this.mood, this.talk) : super(repaint: talk);
  final MascotMood mood;

  /// Drives the mouth while talking; null when silent.
  final Animation<double>? talk;

  /// Mouth opening 0..1: two sines at different speeds read as natural speech.
  double get _open {
    final t = talk?.value;
    if (t == null) return 0;
    return (0.5 + 0.5 * math.sin(t * math.pi * 2 * 5)).clamp(0.0, 1.0) * (0.55 + 0.45 * math.sin(t * math.pi * 2 * 2).abs());
  }

  static const _ink = Color(0xFF3C3C3C);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.03
      ..color = _ink;

    // Body: rounded bubble with a tail, drawn twice for the solid bottom edge.
    final bodyRect = Rect.fromLTWH(w * 0.1, h * 0.16, w * 0.8, h * 0.66);
    final body = RRect.fromRectAndRadius(bodyRect, Radius.circular(w * 0.3));
    final tail = Path()
      ..moveTo(w * 0.3, h * 0.78)
      ..lineTo(w * 0.2, h * 0.95)
      ..lineTo(w * 0.52, h * 0.8)
      ..close();
    final edgeShift = h * 0.04;
    canvas.save();
    canvas.translate(0, edgeShift);
    fill.color = AppColors.primaryDeep;
    canvas.drawRRect(body, fill);
    canvas.drawPath(tail, fill);
    canvas.restore();
    fill.color = AppColors.primary;
    canvas.drawRRect(body, fill);
    canvas.drawPath(tail, fill);

    // Belly highlight.
    fill.color = Colors.white.withValues(alpha: 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * 0.215, w * 0.44, h * 0.05), Radius.circular(w * 0.025)),
      fill,
    );

    // Sprout on top.
    for (final angle in [-0.6, 0.6]) {
      canvas.save();
      canvas.translate(w * 0.5, h * 0.17);
      canvas.rotate(angle);
      fill.color = angle < 0 ? AppColors.success : AppColors.yellow;
      canvas.drawOval(Rect.fromLTWH(angle < 0 ? -w * 0.14 : 0, -h * 0.1, w * 0.14, h * 0.07), fill);
      canvas.restore();
    }

    // Cheeks.
    fill.color = const Color(0xFFFF9DB0).withValues(alpha: 0.9);
    canvas.drawCircle(Offset(w * 0.24, h * 0.56), w * 0.05, fill);
    canvas.drawCircle(Offset(w * 0.76, h * 0.56), w * 0.05, fill);

    _eyes(canvas, size, fill, stroke);
    _mouth(canvas, size, fill, stroke);
    _extras(canvas, size, fill, stroke);
  }

  void _eyes(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width, h = size.height;
    final centers = [Offset(w * 0.35, h * 0.42), Offset(w * 0.65, h * 0.42)];

    if (mood == MascotMood.celebrating) {
      // Happy closed eyes: upward arcs.
      for (final c in centers) {
        canvas.drawArc(Rect.fromCenter(center: c, width: w * 0.12, height: w * 0.12), math.pi, math.pi, false, stroke);
      }
      return;
    }

    final r = mood == MascotMood.listening ? w * 0.1 : w * 0.085;
    final gaze = mood == MascotMood.thinking ? Offset(w * 0.025, -w * 0.025) : Offset.zero;
    for (final c in centers) {
      fill.color = Colors.white;
      canvas.drawCircle(c, r, fill);
      fill.color = _ink;
      canvas.drawCircle(c + gaze, r * 0.5, fill);
      fill.color = Colors.white;
      canvas.drawCircle(c + gaze + Offset(-r * 0.15, -r * 0.18), r * 0.15, fill);
    }

    // Brows for thinking / sad.
    if (mood == MascotMood.thinking) {
      canvas.drawLine(Offset(w * 0.56, h * 0.31), Offset(w * 0.72, h * 0.3), stroke);
    } else if (mood == MascotMood.sad) {
      canvas.drawLine(Offset(w * 0.27, h * 0.32), Offset(w * 0.4, h * 0.34), stroke);
      canvas.drawLine(Offset(w * 0.73, h * 0.32), Offset(w * 0.6, h * 0.34), stroke);
    }
  }

  void _mouth(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width, h = size.height;
    final c = Offset(w * 0.5, h * 0.58);
    if (talk != null) {
      final open = _open;
      final mouthRect = Rect.fromCenter(center: c.translate(0, w * 0.02), width: w * (0.12 + 0.06 * open), height: w * (0.025 + 0.15 * open));
      fill.color = _ink;
      canvas.drawOval(mouthRect, fill);
      if (open > 0.45) {
        fill.color = const Color(0xFFFF6B81);
        canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, mouthRect.bottom - w * 0.025), width: mouthRect.width * 0.55, height: mouthRect.height * 0.35), fill);
      }
      return;
    }
    switch (mood) {
      case MascotMood.happy:
        canvas.drawArc(Rect.fromCenter(center: c, width: w * 0.2, height: w * 0.14), 0.15, math.pi - 0.3, false, stroke);
      case MascotMood.celebrating:
        final mouth = Path()
          ..moveTo(c.dx - w * 0.11, c.dy - w * 0.02)
          ..quadraticBezierTo(c.dx, c.dy + w * 0.2, c.dx + w * 0.11, c.dy - w * 0.02)
          ..close();
        fill.color = _ink;
        canvas.drawPath(mouth, fill);
        fill.color = const Color(0xFFFF6B81);
        canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + w * 0.07), width: w * 0.1, height: w * 0.05), fill);
      case MascotMood.thinking:
        canvas.drawLine(Offset(c.dx - w * 0.05, c.dy + w * 0.02), Offset(c.dx + w * 0.06, c.dy), stroke);
      case MascotMood.listening:
        stroke.style = PaintingStyle.stroke;
        canvas.drawOval(Rect.fromCenter(center: c.translate(0, w * 0.02), width: w * 0.07, height: w * 0.09), stroke);
      case MascotMood.sad:
        canvas.drawArc(
          Rect.fromCenter(center: c.translate(0, w * 0.07), width: w * 0.16, height: w * 0.1),
          math.pi + 0.3,
          math.pi - 0.6,
          false,
          stroke,
        );
    }
  }

  void _extras(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width, h = size.height;
    switch (mood) {
      case MascotMood.listening:
        // Sound arcs on both sides.
        final p = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = w * 0.025
          ..color = AppColors.accent;
        for (var i = 0; i < 2; i++) {
          final rad = w * (0.06 + i * 0.05);
          canvas.drawArc(Rect.fromCircle(center: Offset(w * 0.05, h * 0.5), radius: rad), -0.9, 1.8, false, p);
          canvas.drawArc(Rect.fromCircle(center: Offset(w * 0.95, h * 0.5), radius: rad), math.pi - 0.9, 1.8, false, p);
        }
      case MascotMood.thinking:
        fill.color = AppColors.border;
        canvas.drawCircle(Offset(w * 0.9, h * 0.12), w * 0.025, fill);
        canvas.drawCircle(Offset(w * 0.95, h * 0.05), w * 0.035, fill);
      case MascotMood.celebrating:
        const colors = [AppColors.yellow, AppColors.accent, AppColors.orange, AppColors.success, AppColors.red];
        const spots = [(0.06, 0.2), (0.94, 0.25), (0.14, 0.05), (0.86, 0.06), (0.03, 0.45), (0.97, 0.5)];
        for (var i = 0; i < spots.length; i++) {
          fill.color = colors[i % colors.length];
          canvas.drawCircle(Offset(w * spots[i].$1, h * spots[i].$2), w * 0.025, fill);
        }
      case MascotMood.happy:
      case MascotMood.sad:
        break;
    }
  }

  @override
  bool shouldRepaint(_MascotPainter old) => old.mood != mood || old.talk != talk;
}
