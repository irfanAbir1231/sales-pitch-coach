import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_repository.dart';
import '../main.dart';
import '../models/product.dart';
import 'home_screen.dart' show scoreColor;
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
      return _query.isEmpty || p.name.contains(_query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('পিচ প্র্যাকটিস')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              hintText: 'পণ্য খুঁজুন',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip(
                  'সব',
                  _category == null,
                  () => setState(() => _category = null),
                ),
                for (final c in repo.categories)
                  _chip(c, _category == c, () => setState(() => _category = c)),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('কোনো পণ্য পাওয়া যায়নি।'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: items.length,
                    itemBuilder: (_, i) =>
                        _card(context, items[i], history.bestFor(items[i].id)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );

  Widget _card(BuildContext context, Product p, double? best) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
        leading: Hero(
          tag: 'product-${p.id}',
          child: ProductImage(product: p, size: 60),
        ),
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          p.mrp.isEmpty ? p.category : '${p.category} · ${p.mrpText}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: best == null
            ? Chip(
                label: const Text('নতুন'),
                visualDensity: VisualDensity.compact,
                backgroundColor: cs.secondaryContainer,
              )
            : Chip(
                label: Text(
                  best.toStringAsFixed(1),
                  style: TextStyle(
                    color: scoreColor(best),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                visualDensity: VisualDensity.compact,
                backgroundColor: scoreColor(best).withValues(alpha: 0.12),
                side: BorderSide.none,
              ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PracticeScreen(product: p)),
        ),
      ),
    );
  }
}
