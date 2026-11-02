import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../services/locale_store.dart';
import 'ds_card.dart';
import 'mascot.dart';
import 'pressable_surface.dart';

/// Plain app bar.
class DsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DsAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      bottom: const PreferredSize(preferredSize: Size.fromHeight(2), child: Divider()),
    );
  }
}

/// Heading above a group of content, with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.xl, bottom: AppSpace.md),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppText.title)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
                child: Text(actionLabel!, style: AppText.bodyStrong.copyWith(color: AppColors.accentLight)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Round badge showing a 0-10 score in its score color.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score, this.size = 44});

  final double score;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: scoreTint(score), shape: BoxShape.circle),
      child: Text(
        localizeDigits(score.toStringAsFixed(1), context),
        style: AppText.bodyStrong.copyWith(color: scoreColor(score), fontWeight: FontWeight.w800, fontSize: size * 0.34),
      ),
    );
  }
}

/// Selectable pill for filters (category chips etc).
class DsChoicePill extends StatelessWidget {
  const DsChoicePill({super.key, required this.label, required this.selected, required this.onTap, this.expand = false});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Fill the available width and center the label (for segmented pairs).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: PressableSurface(
        color: selected ? AppColors.primaryTint : Colors.white,
        edgeColor: selected ? AppColors.primary : AppColors.border,
        depth: 3,
        radius: AppRadius.pill,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: 9),
        onTap: onTap,
        child: Text(
          label,
          textAlign: expand ? TextAlign.center : null,
          style: AppText.bodyStrong.copyWith(
            color: selected ? AppColors.primaryDeep : AppColors.textMuted,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

/// Mascot + message (+ optional action) for screens with nothing to show.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.mood = MascotMood.thinking,
    this.action,
  });

  final String title;
  final String message;
  final MascotMood mood;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Mascot(mood: mood, size: 120),
            const SizedBox(height: AppSpace.lg),
            Text(title, style: AppText.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.sm),
            Text(message, style: AppText.body.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: AppSpace.xl), action!],
          ],
        ),
      ),
    );
  }
}

/// BN | EN switch for the app language.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocaleStore>();
    Widget seg(String label, String code) {
      final on = store.locale.languageCode == code;
      return GestureDetector(
        onTap: () => store.set(code),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: on ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(label, style: AppText.caption.copyWith(color: on ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w800)),
        ),
      );
    }

    return Semantics(
      label: context.l10n.changeLanguage,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [seg('BN', 'bn'), seg('EN', 'en')]),
      ),
    );
  }
}

/// The avatar guiding the user: Pitchy with a short line in a speech bubble.
class GuideBubble extends StatelessWidget {
  const GuideBubble({super.key, required this.text, this.mood = MascotMood.happy, this.talking = false, this.size = 72});

  final String text;
  final MascotMood mood;
  final bool talking;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Mascot(mood: mood, size: size, talking: talking),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: DsCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
            child: Text(text, style: AppText.bodyStrong),
          ),
        ),
      ],
    );
  }
}
