import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Thick rounded progress bar that animates to [value] (0..1).
class DsProgressBar extends StatelessWidget {
  const DsProgressBar({super.key, required this.value, this.color = AppColors.primary, this.height = 16});

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      value: '${(v * 100).round()}%',
      child: ExcludeSemantics(
        child: Container(
          height: height,
          decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.pill)),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(builder: (context, c) {
            return Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: v),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (context, t, _) => Container(
                  width: c.maxWidth * t,
                  height: height,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: height * 0.2, left: height * 0.4, right: height * 0.4),
                  // Soft highlight strip on the fill.
                  child: Container(
                    height: height * 0.22,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(AppRadius.pill)),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
