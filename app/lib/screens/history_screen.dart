import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/product_repository.dart';
import '../main.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attempts = context.watch<HistoryNotifier>().store.attempts;
    final repo = context.read<ProductRepository>();
    final avg = attempts.isEmpty ? 0.0 : attempts.map((a) => a.result.total).reduce((a, b) => a + b) / attempts.length;

    return Scaffold(
      appBar: AppBar(title: const Text('আমার স্কোর')),
      body: attempts.isEmpty
          ? const Center(child: Text('এখনো কোনো প্র্যাকটিস করা হয়নি।'))
          : Column(
              children: [
                ListTile(
                  title: Text('মোট ${attempts.length} টি চেষ্টা'),
                  trailing: Text('গড় ${avg.toStringAsFixed(1)}/১০', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: attempts.length,
                    itemBuilder: (_, i) {
                      final a = attempts[i];
                      final t = a.at;
                      return ListTile(
                        title: Text(a.productName),
                        subtitle: Text('${t.day}/${t.month}/${t.year}  ${t.hour}:${t.minute.toString().padLeft(2, '0')}'),
                        trailing: Text('${a.result.total.toStringAsFixed(1)}/১০',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        onTap: () {
                          final matches = repo.products.where((p) => p.id == a.productId);
                          if (matches.isEmpty) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ResultScreen(product: matches.first, pitch: a.pitch, result: a.result)),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
