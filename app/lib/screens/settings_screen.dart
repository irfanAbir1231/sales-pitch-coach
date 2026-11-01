import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../services/profile_store.dart';
import 'admin_screen.dart';

/// Profile page: the officer's details and progress. Admin is a quiet link at the very bottom.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _edit(BuildContext context, ProfileStore p) async {
    final name = TextEditingController(text: p.name);
    final id = TextEditingController(text: p.employeeId);
    final area = TextEditingController(text: p.area);
    final phone = TextEditingController(text: p.phone);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('প্রোফাইল এডিট', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            _field(name, 'নাম', Icons.person_outline),
            _field(id, 'এমপ্লয়ি আইডি', Icons.badge_outlined),
            _field(area, 'এলাকা / টেরিটরি', Icons.place_outlined),
            _field(phone, 'মোবাইল নম্বর', Icons.phone_outlined, keyboard: TextInputType.phone),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('সেভ করুন')),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      await p.save(name: name.text, employeeId: id.text, area: area.text, phone: phone.text);
    }
  }

  static Widget _field(TextEditingController c, String label, IconData icon, {TextInputType? keyboard}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final p = context.watch<ProfileStore>();
    final attempts = context.watch<HistoryNotifier>().store.attempts;
    final totals = attempts.map((a) => a.result.total).toList();
    final avg = totals.isEmpty ? null : totals.reduce((a, b) => a + b) / totals.length;
    final best = totals.isEmpty ? null : totals.reduce((a, b) => a > b ? a : b);
    final shown = p.name.isEmpty ? 'আপনার নাম' : p.name;

    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রোফাইল'),
        actions: [IconButton(tooltip: 'এডিট', icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context, p))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(colors: [cs.primaryContainer, cs.secondaryContainer]),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: cs.primary,
                  child: Text(
                    p.name.isEmpty ? '?' : p.name.characters.first,
                    style: TextStyle(fontSize: 28, color: cs.onPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shown, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
                      Text('সেলস অফিসার', style: tt.bodyMedium?.copyWith(color: cs.onPrimaryContainer)),
                      if (p.name.isEmpty)
                        TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                          onPressed: () => _edit(context, p),
                          child: const Text('প্রোফাইল সম্পূর্ণ করুন'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('চেষ্টা', '${attempts.length}', cs),
              const SizedBox(width: 8),
              _stat('গড় স্কোর', avg == null ? '–' : avg.toStringAsFixed(1), cs),
              const SizedBox(width: 8),
              _stat('সর্বোচ্চ', best == null ? '–' : best.toStringAsFixed(1), cs),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: cs.surfaceContainerHighest,
            child: Column(
              children: [
                _info(Icons.badge_outlined, 'এমপ্লয়ি আইডি', p.employeeId),
                _info(Icons.place_outlined, 'এলাকা / টেরিটরি', p.area),
                _info(Icons.phone_outlined, 'মোবাইল', p.phone),
              ],
            ),
          ),
          const SizedBox(height: 56),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: cs.onSurfaceVariant, textStyle: const TextStyle(fontSize: 12)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGate())),
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
              label: const Text('অ্যাডমিন'),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _stat(String label, String value, ColorScheme cs) => Expanded(
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: cs.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      );

  static Widget _info(IconData icon, String label, String value) => ListTile(
        leading: Icon(icon),
        title: Text(label, style: const TextStyle(fontSize: 12)),
        subtitle: Text(value.isEmpty ? 'দেওয়া হয়নি' : value, style: const TextStyle(fontSize: 15)),
      );
}
