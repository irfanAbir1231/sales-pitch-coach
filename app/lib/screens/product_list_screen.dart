import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_repository.dart';
import '../main.dart';
import '../models/product.dart';
import 'admin_screen.dart';
import 'history_screen.dart';
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
      appBar: AppBar(
        title: const Text('পিচ প্র্যাকটিস'),
        actions: [
          IconButton(
            tooltip: 'আমার স্কোর',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          IconButton(
            tooltip: 'Admin',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGate())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'পণ্য খুঁজুন',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _chip('সব', _category == null, () => setState(() => _category = null)),
                for (final c in repo.categories) _chip(c, _category == c, () => setState(() => _category = c)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => _tile(context, items[i], history.bestFor(items[i].id)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
      );

  Widget _tile(BuildContext context, Product p, double? best) => ListTile(
        title: Text(p.name),
        subtitle: Text(p.category),
        trailing: best == null
            ? const Icon(Icons.chevron_right)
            : Chip(label: Text('সেরা ${best.toStringAsFixed(1)}/১০')),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeScreen(product: p))),
      );
}
