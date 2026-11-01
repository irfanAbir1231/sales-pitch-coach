import 'package:flutter/material.dart';

import 'admin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('সেটিংস')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: cs.surfaceContainerHighest,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cs.primaryContainer,
                child: Icon(Icons.admin_panel_settings_outlined, color: cs.onPrimaryContainer),
              ),
              title: const Text('অ্যাডমিন'),
              subtitle: const Text('AI প্রোভাইডার ও API key (PIN লাগবে)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGate())),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: cs.surfaceContainerHighest,
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Sales Pitch Coach'),
              subtitle: Text('পণ্য পিচ ও আপত্তি সামলানোর প্র্যাকটিস অ্যাপ'),
            ),
          ),
        ],
      ),
    );
  }
}
