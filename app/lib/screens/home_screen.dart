import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_repository.dart';
import '../l10n/l10n.dart';
import '../main.dart';
import '../models/product.dart';
import '../services/history_store.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';
import '../widgets/product_image.dart';
import 'practice_screen.dart';
import 'result_screen.dart';

export '../theme/app_theme.dart' show scoreColor;

class HomeScreen extends StatefulWidget {
  /// Switches the bottom-navigation tab (0 home, 1 practice, 2 history, 3 settings).
  final void Function(int) onGoTo;
  const HomeScreen({super.key, required this.onGoTo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Product _challenge;

  @override
  void initState() {
    super.initState();
    final all = context.read<ProductRepository>().products;
    _challenge = all[Random().nextInt(all.length)];
  }

  void _open(Product p, {bool objection = false}) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PracticeScreen(product: p, startInObjection: objection),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final attempts = context.watch<HistoryNotifier>().store.attempts;
    final repo = context.read<ProductRepository>();

    final avg = attempts.isEmpty
        ? null
        : attempts.map((a) => a.result.total).reduce((a, b) => a + b) /
              attempts.length;
    final best = attempts.isEmpty
        ? null
        : attempts.map((a) => a.result.total).reduce(max);
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final thisWeek = attempts.where((a) => a.at.isAfter(weekAgo)).length;

    return Scaffold(
      body: Column(
        children: [
          // Fixed header in the chrome shade: stays put while the content below scrolls.
          Container(
            decoration: const BoxDecoration(
              color: AppColors.chrome,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 2),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.lg,
                  AppSpace.md,
                  AppSpace.lg,
                  AppSpace.md,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icon/logo_256.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Text(
                        l.appName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.display.copyWith(fontSize: 24),
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.lg,
                AppSpace.sm,
                AppSpace.lg,
                AppSpace.xl,
              ),
              children: [
                GuideBubble(text: attempts.isEmpty ? l.tipStart : l.tipAgain),
                const SizedBox(height: AppSpace.lg),
                _challengeCard(),
                const SizedBox(height: AppSpace.lg),
                DsCard(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        _stat(
                          l.avgScore,
                          avg == null
                              ? '–'
                              : localizeDigits(avg.toStringAsFixed(1), context),
                          AppIcons.chart,
                          AppColors.accent,
                        ),
                        const VerticalDivider(),
                        _stat(
                          l.bestScore,
                          best == null
                              ? '–'
                              : localizeDigits(
                                  best.toStringAsFixed(1),
                                  context,
                                ),
                          AppIcons.trophy,
                          AppColors.yellow,
                        ),
                        const VerticalDivider(),
                        _stat(
                          l.thisWeek,
                          localizeDigits('$thisWeek', context),
                          AppIcons.calendar,
                          AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                Row(
                  children: [
                    Expanded(
                      child: _action(
                        l.pitchPractice,
                        AppIcons.mic,
                        AppColors.primary,
                        AppColors.primaryTint,
                        () => widget.onGoTo(1),
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: _action(
                        l.handleObjections,
                        AppIcons.objection,
                        AppColors.orangeLight,
                        AppColors.orangeTint,
                        () => _open(_challenge, objection: true),
                      ),
                    ),
                  ],
                ),
                SectionHeader(
                  title: l.recentAttempts,
                  actionLabel: attempts.isNotEmpty ? l.seeAll : null,
                  onAction: () => widget.onGoTo(2),
                ),
                if (attempts.isEmpty)
                  Text(
                    l.noPracticeYet,
                    style: AppText.body.copyWith(color: AppColors.textMuted),
                  )
                else
                  for (final a in attempts.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.md),
                      child: DsCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.lg,
                          vertical: AppSpace.md,
                        ),
                        onTap: () {
                          final m = repo.products.where(
                            (p) => p.id == a.productId,
                          );
                          if (m.isEmpty) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultScreen(
                                product: m.first,
                                pitch: a.pitch,
                                result: a.result,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            ScoreBadge(score: a.result.total),
                            const SizedBox(width: AppSpace.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    attemptTitle(context, a, repo),
                                    style: AppText.headline,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    localizeDigits(
                                      '${a.at.day}/${a.at.month}/${a.at.year}',
                                      context,
                                    ),
                                    style: AppText.caption,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              AppIcons.next,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _challengeCard() {
    final l = context.l10n;
    // Fixed height so the card never resizes when the product (and name length) changes.
    return DsCard(
      padding: const EdgeInsets.all(AppSpace.lg),
      child: SizedBox(
        height: 120,
        child: Row(
          children: [
            ProductImage(product: _challenge, size: 88, radius: 14),
            const SizedBox(width: AppSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.dailyChallenge, style: AppText.caption),
                  SizedBox(
                    height: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _challenge.localName(context.isEnglish),
                        style: AppText.headline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Flexible(
                        child: ChunkyButton(
                          label: l.start,
                          expand: false,
                          compact: true,
                          onPressed: () => _open(_challenge),
                        ),
                      ),
                      IconButton(
                        tooltip: l.anotherProduct,
                        onPressed: () {
                          final all = context
                              .read<ProductRepository>()
                              .products;
                          setState(
                            () =>
                                _challenge = all[Random().nextInt(all.length)],
                          );
                        },
                        icon: const Icon(AppIcons.shuffle),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            Text(value, style: AppText.title),
            Text(label, style: AppText.caption, textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _action(
    String label,
    IconData icon,
    Color color,
    Color tint,
    VoidCallback onTap,
  ) => DsCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(
      vertical: AppSpace.lg,
      horizontal: AppSpace.md,
    ),
    child: Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(label, style: AppText.bodyStrong, textAlign: TextAlign.center),
      ],
    ),
  );
}

/// Title of a saved attempt in the app language. Attempts store the Bangla
/// product name, so look the product up again.
String attemptTitle(BuildContext context, Attempt a, ProductRepository repo) {
  final en = context.isEnglish;
  final isObjection = a.productName.endsWith('(আপত্তি)');
  final match = repo.products.where((p) => p.id == a.productId);
  final name = match.isEmpty
      ? a.productName.replaceAll(' (আপত্তি)', '')
      : match.first.localName(en);
  return isObjection ? '$name ${context.l10n.objectionSuffix}' : name;
}
