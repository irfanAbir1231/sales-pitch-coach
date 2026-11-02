import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_repository.dart';
import '../main.dart';
import '../l10n/l10n.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';
import '../widgets/product_image.dart';
import 'practice_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ProductRepository>();
    final history = context.watch<HistoryNotifier>().store;
    final items = repo.products.where((p) {
      if (_category != null && p.category != _category) return false;
      return _query.isEmpty || p.name.contains(_query) || p.localName(true).toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: DsAppBar(title: context.l10n.pitchPractice),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.xs),
            child: TextField(
              decoration: InputDecoration(hintText: context.l10n.searchProducts, prefixIcon: const Icon(AppIcons.search)),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          SizedBox(
            height: 66,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.sm),
              children: [
                _pill(context.l10n.all, _category == null, () => setState(() => _category = null)),
                for (final c in repo.categories) _pill(localizedCategory(context, c), _category == c, () => setState(() => _category = c)),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(title: context.l10n.nothingFound, message: context.l10n.tryOtherSearch)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.sm, AppSpace.lg, AppSpace.lg),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _card(context, items[i], history.bestFor(items[i].id)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: AppSpace.sm),
        child: DsChoicePill(label: label, selected: selected, onTap: onTap),
      );

  Widget _card(BuildContext context, Product p, double? best) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: DsCard(
        padding: const EdgeInsets.all(AppSpace.md),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeScreen(product: p))),
        child: Row(
          children: [
            Hero(tag: 'product-${p.id}', child: ProductImage(product: p, size: 64)),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.localName(context.isEnglish), style: AppText.headline, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    p.mrp.isEmpty ? localizedCategory(context, p.category) : '${localizedCategory(context, p.category)} · ${localizeDigits(p.mrpText, context)}',
                    style: AppText.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            best == null
                ? _NewTag(label: context.l10n.newTag)
                : ScoreBadge(score: best),
          ],
        ),
      ),
    );
  }
}

class _NewTag extends StatelessWidget {
  const _NewTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: 2),
      decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: AppText.caption.copyWith(color: AppColors.accentLight, fontWeight: FontWeight.w800)),
    );
  }
}
