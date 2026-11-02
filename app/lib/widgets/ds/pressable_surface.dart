import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

/// The base of every panel: a flat face with a 2px border and a solid "edge"
/// underneath that gives it chunky depth. When tapped the face sinks onto the
/// edge. [ChunkyButton] and [DsCard] build on it.
class PressableSurface extends StatefulWidget {
  const PressableSurface({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.edgeColor = AppColors.border,
    this.borderColor,
    this.radius = AppRadius.card,
    this.depth = 4,
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  final Widget child;
  final Color color;

  /// The solid slab under the face (usually a darker shade of [color]).
  final Color edgeColor;

  /// Defaults to [edgeColor].
  final Color? borderColor;
  final double radius;
  final double depth;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  State<PressableSurface> createState() => _PressableSurfaceState();
}

class _PressableSurfaceState extends State<PressableSurface> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final down = interactive && _pressed;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: interactive ? (_) => _set(true) : null,
      onTapUp: interactive ? (_) => _set(false) : null,
      onTapCancel: interactive ? () => _set(false) : null,
      onTap: interactive
          ? () {
              HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: Padding(
        // Reserve room for the edge so layout doesn't move on press.
        padding: EdgeInsets.only(bottom: widget.depth),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          transform: Matrix4.translationValues(0, down ? widget.depth : 0, 0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: widget.borderColor ?? widget.edgeColor, width: 2),
            boxShadow: [BoxShadow(color: widget.edgeColor, offset: Offset(0, down ? 0 : widget.depth))],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
