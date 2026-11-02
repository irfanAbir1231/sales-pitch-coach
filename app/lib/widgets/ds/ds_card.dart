import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'pressable_surface.dart';

/// Flat bordered card. Tappable when [onTap] is set. Use [tint] / [edge] for
/// semantic cards: [tint] is a pale fill token like `AppColors.orangeTint`,
/// [edge] the matching main color for the border.
class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpace.lg),
    this.tint,
    this.edge,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? tint;
  final Color? edge;

  @override
  Widget build(BuildContext context) {
    return PressableSurface(
      color: tint ?? AppColors.surface,
      edgeColor: edge ?? AppColors.border,
      padding: padding,
      onTap: onTap,
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}
