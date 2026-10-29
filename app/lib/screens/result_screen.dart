import 'package:flutter/material.dart';

import '../ai/score_result.dart';
import '../models/product.dart';

class ResultScreen extends StatelessWidget {
  final Product product;
  final String pitch;
  final ScoreResult result;
  /// Set in objection mode; shown instead of the ideal pitch.
  final String? idealAnswer;
  const ResultScreen({super.key, required this.product, required this.pitch, required this.result, this.idealAnswer});

  Color _color(double s) => s >= 8 ? Colors.green : (s >= 5 ? Colors.orange : Colors.red);

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Scaffold(
      appBar: AppBar(title: const Text('আপনার স্কোর')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Text(r.total.toStringAsFixed(1),
                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: _color(r.total))),
                const Text('/ ১০', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _bar('মূল পয়েন্ট', r.keyPointsScore, 4),
          _bar('কারণ/উপাদান', r.reasonScore, 2),
          _bar('গঠন', r.structureScore, 2),
          _bar('ভাষা ও স্পষ্টতা', r.toneScore, 1),
          _bar('ভুল দাবি নেই', r.noFalseClaimsScore, 1),
          const Divider(height: 32),
          if (r.feedback.isNotEmpty) ...[_title('মতামত'), Text(r.feedback), const SizedBox(height: 16)],
          if (r.coveredPoints.isNotEmpty) ...[
            _title('যা ঠিকভাবে বলেছেন'),
            for (final c in r.coveredPoints) _item(Icons.check_circle, Colors.green, c),
            const SizedBox(height: 16),
          ],
          if (r.missedPoints.isNotEmpty) ...[
            _title('যা বাদ পড়েছে'),
            for (final m in r.missedPoints) _item(Icons.cancel, Colors.red, m),
            const SizedBox(height: 16),
          ],
          if (r.falseClaims.isNotEmpty) ...[
            _title('ভুল/নিষিদ্ধ দাবি'),
            for (final f in r.falseClaims) _item(Icons.warning_amber, Colors.orange, f),
            const SizedBox(height: 16),
          ],
          if (r.betterLine.isNotEmpty)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_title('এভাবে বললে আরও ভালো হতো'), Text(r.betterLine)],
                ),
              ),
            ),
          const SizedBox(height: 8),
          ExpansionTile(
            title: Text(idealAnswer == null ? 'আদর্শ পিচ দেখুন' : 'আদর্শ উত্তর দেখুন'),
            children: [Padding(padding: const EdgeInsets.all(12), child: Text(idealAnswer ?? product.idealPitch))],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('আবার চেষ্টা করুন'),
          ),
          const SizedBox(height: 8),
          Center(child: Text('Scored by ${r.providerName}', style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  Widget _item(IconData i, Color c, String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(i, color: c, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(t)),
        ]),
      );

  Widget _bar(String label, double v, double max) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: LinearProgressIndicator(value: max == 0 ? 0 : v / max, minHeight: 8)),
          const SizedBox(width: 8),
          Text('${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)}/${max.toInt()}'),
        ]),
      );
}
