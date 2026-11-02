import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_repository.dart';
import '../l10n/l10n.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';
import 'home_screen.dart' show attemptTitle;
import 'practice_screen.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attempts = context.watch<HistoryNotifier>().store.attempts;
    final repo = context.read<ProductRepository>();
    final avg = attempts.isEmpty ? 0.0 : attempts.map((a) => a.result.total).reduce((a, b) => a + b) / attempts.length;

    return Scaffold(
      appBar: DsAppBar(title: context.l10n.myScores),
      body: attempts.isEmpty
          ? EmptyState(title: context.l10n.nothingYetTitle, message: context.l10n.nothingYetMessage)
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpace.lg),
              itemCount: attempts.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) return _summary(context, attempts.length, avg);
                final a = attempts[i - 1];
                final t = a.at;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.md),
                  child: DsCard(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
                    onTap: () {
                      final matches = repo.products.where((p) => p.id == a.productId);
                      if (matches.isEmpty) return;
                      final product = matches.first;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (resultContext) => ResultScreen(
                            product: product,
                            pitch: a.pitch,
                            result: a.result,
                            onTryAgain: () => Navigator.pushReplacement(
                              resultContext,
                              MaterialPageRoute(builder: (_) => PracticeScreen(product: product)),
                            ),
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
                              Text(attemptTitle(context, a, repo), style: AppText.headline, maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(
                                localizeDigits('${t.day}/${t.month}/${t.year}  ${t.hour}:${t.minute.toString().padLeft(2, '0')}', context),
                                style: AppText.caption,
                              ),
                            ],
                          ),
                        ),
                        const Icon(AppIcons.next, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _summary(BuildContext context, int count, double avg) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpace.lg),
        child: DsCard(
          tint: AppColors.accentTint,
          edge: AppColors.accent,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.totalAttempts, style: AppText.caption.copyWith(color: AppColors.accentLight)),
                    Text(localizeDigits(context.l10n.attemptsCount(count), context), style: AppText.title),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(context.l10n.avgScore, style: AppText.caption.copyWith(color: AppColors.accentLight)),
                  Text(context.l10n.scoreOutOfTen(localizeDigits(avg.toStringAsFixed(1), context)), style: AppText.title.copyWith(color: scoreColor(avg))),
                ],
              ),
            ],
          ),
        ),
      );
}
