import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_repository.dart';
import '../main.dart';
import '../models/product.dart';
import '../services/history_store.dart';
import '../widgets/product_image.dart';
import 'practice_screen.dart';
import 'result_screen.dart';

Color scoreColor(double s) => s >= 7
    ? const Color(0xFF2E7D32)
    : (s >= 4 ? const Color(0xFFF9A825) : const Color(0xFFC62828));

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

  /// Consecutive days with at least one attempt, counting back from today (or yesterday).
  static int _streak(List<Attempt> attempts) {
    final days = attempts
        .map((a) => DateTime(a.at.year, a.at.month, a.at.day))
        .toSet();
    var day = DateTime.now();
    day = DateTime(day.year, day.month, day.day);
    if (!days.contains(day)) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (days.contains(day)) {
      n++;
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }

  void _open(Product p, {bool objection = false}) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PracticeScreen(product: p, startInObjection: objection),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final attempts = context.watch<HistoryNotifier>().store.attempts;
    final repo = context.read<ProductRepository>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final avg = attempts.isEmpty
        ? null
        : attempts.map((a) => a.result.total).reduce((a, b) => a + b) /
              attempts.length;
    final best = attempts.isEmpty
        ? null
        : attempts.map((a) => a.result.total).reduce(max);
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final thisWeek = attempts.where((a) => a.at.isAfter(weekAgo)).length;
    final streak = _streak(attempts);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header: stays put while the content below scrolls.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/icon/logo_256.png', width: 38, height: 38),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'পিচ কোচ',
                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: cs.primary),
                      ),
                      const Spacer(),
                      if (streak > 0)
                        Chip(
                          avatar: const Text('🔥'),
                          label: Text('$streak দিন'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _challengeCard(cs, tt),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _stat(
                        'গড় স্কোর',
                        avg == null ? '–' : avg.toStringAsFixed(1),
                        Icons.analytics_outlined,
                        cs,
                      ),
                      const SizedBox(width: 8),
                      _stat(
                        'সর্বোচ্চ',
                        best == null ? '–' : best.toStringAsFixed(1),
                        Icons.emoji_events_outlined,
                        cs,
                      ),
                      const SizedBox(width: 8),
                      _stat(
                        'এই সপ্তাহে',
                        '$thisWeek',
                        Icons.event_available_outlined,
                        cs,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _action(
                          'পিচ প্র্যাকটিস',
                          Icons.mic_none,
                          cs.primaryContainer,
                          cs.onPrimaryContainer,
                          () => widget.onGoTo(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _action(
                          'আপত্তি সামলান',
                          Icons.question_answer_outlined,
                          cs.tertiaryContainer,
                          cs.onTertiaryContainer,
                          () => _open(_challenge, objection: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'সাম্প্রতিক চেষ্টা',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (attempts.isNotEmpty)
                        TextButton(
                          onPressed: () => widget.onGoTo(2),
                          child: const Text('সব দেখুন'),
                        ),
                    ],
                  ),
                  if (attempts.isEmpty)
                    Card(
                      elevation: 0,
                      color: cs.surfaceContainerHighest,
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'এখনো কোনো প্র্যাকটিস করা হয়নি। উপরের চ্যালেঞ্জ দিয়ে শুরু করুন!',
                          ),
                        ),
                      ),
                    )
                  else
                    for (final a in attempts.take(3))
                      Card(
                        elevation: 0,
                        color: cs.surfaceContainerHighest,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: scoreColor(a.result.total)
                                .withValues(alpha: 0.15),
                            child: Text(
                              a.result.total.toStringAsFixed(1),
                              style: TextStyle(
                                color: scoreColor(a.result.total),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          title: Text(
                            a.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${a.at.day}/${a.at.month}/${a.at.year}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
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
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _challengeCard(ColorScheme cs, TextTheme tt) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: [cs.primary, cs.primary.withValues(alpha: 0.75)],
      ),
    ),
    child: Row(
      children: [
        Expanded(child: _challengeText(cs, tt)),
        const SizedBox(width: 12),
        ProductImage(product: _challenge, size: 112, radius: 20),
      ],
    ),
  );

  Widget _challengeText(ColorScheme cs, TextTheme tt) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'আজকের চ্যালেঞ্জ',
        style: tt.labelLarge?.copyWith(
          color: cs.onPrimary.withValues(alpha: 0.85),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        _challenge.name,
        style: tt.titleLarge?.copyWith(
          color: cs.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        _challenge.category,
        style: tt.bodyMedium?.copyWith(
          color: cs.onPrimary.withValues(alpha: 0.85),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          FilledButton.icon(
            onPressed: () => _open(_challenge),
            style: FilledButton.styleFrom(
              backgroundColor: cs.onPrimary,
              foregroundColor: cs.primary,
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('শুরু করুন'),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'অন্য পণ্য',
            color: cs.onPrimary,
            onPressed: () {
              final all = context.read<ProductRepository>().products;
              setState(() => _challenge = all[Random().nextInt(all.length)]);
            },
            icon: const Icon(Icons.shuffle),
          ),
        ],
      ),
    ],
  );

  Widget _stat(String label, String value, IconData icon, ColorScheme cs) =>
      Expanded(
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: cs.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: cs.primary),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _action(
    String label,
    IconData icon,
    Color bg,
    Color fg,
    VoidCallback onTap,
  ) => Material(
    color: bg,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Icon(icon, color: fg, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}
