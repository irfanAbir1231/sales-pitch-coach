import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'pressable_surface.dart';

enum ChunkyVariant { primary, danger, secondary }

/// Solid, flat button. Pass a null [onPressed] to disable it.
class ChunkyButton extends StatelessWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ChunkyVariant.primary,
    this.icon,
    this.expand = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ChunkyVariant variant;
  final IconData? icon;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final (Color face, Color edge, Color fg) = enabled
        ? switch (variant) {
            ChunkyVariant.primary => (AppColors.primary, AppColors.primaryDeep, Colors.white),
            ChunkyVariant.danger => (AppColors.red, AppColors.redLight, Colors.white),
            ChunkyVariant.secondary => (Colors.white, AppColors.border, AppColors.primaryDeep),
          }
        : (AppColors.border, AppColors.disabled, AppColors.textMuted);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: PressableSurface(
        color: face,
        edgeColor: edge,
        radius: AppRadius.button,
        onTap: onPressed,
        padding: EdgeInsets.symmetric(horizontal: AppSpace.xl, vertical: compact ? AppSpace.sm : 14),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, color: fg, size: 20), const SizedBox(width: AppSpace.sm)],
            Flexible(child: Text(label, style: AppText.button.copyWith(color: fg), textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
