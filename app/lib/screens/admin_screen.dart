import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ai/ai_service.dart';
import '../ai/providers.dart';
import '../services/settings_store.dart';

/// Asks for the admin PIN (creating one on first use) before showing settings.
class AdminGate extends StatefulWidget {
  const AdminGate({super.key});

  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  final _pin = TextEditingController();
  bool? _hasPin;
  bool _unlocked = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    context.read<SettingsStore>().hasPin().then((v) => setState(() => _hasPin = v));
  }

  Future<void> _submit() async {
    final store = context.read<SettingsStore>();
    final pin = _pin.text.trim();
    if (_hasPin == false) {
      if (pin.length < 4) {
        setState(() => _error = 'কমপক্ষে ৪ সংখ্যার PIN দিন');
        return;
      }
      await store.setPin(pin);
      setState(() => _unlocked = true);
    } else if (await store.checkPin(pin)) {
      setState(() => _unlocked = true);
    } else {
      setState(() => _error = 'PIN ভুল');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return const AdminScreen();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: _hasPin == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_hasPin! ? 'Admin PIN দিন' : 'নতুন Admin PIN সেট করুন'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(border: const OutlineInputBorder(), errorText: _error),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _submit, child: const Text('ঠিক আছে')),
                ],
              ),
            ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _keys = <String, TextEditingController>{};
  final _models = <String, TextEditingController>{};
  final _testStatus = <String, String>{};
  String _active = 'groq';
  bool _fallback = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = context.read<SettingsStore>();
    for (final p in allProviders) {
      _keys[p.id] = TextEditingController(text: await s.apiKey(p) ?? '');
      _models[p.id] = TextEditingController(text: s.modelFor(p));
    }
    _active = s.activeProviderId;
    _fallback = s.fallbackEnabled;
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final s = context.read<SettingsStore>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      for (final p in allProviders) {
        await s.setApiKey(p, _keys[p.id]!.text);
        await s.setModel(p, _models[p.id]!.text.isEmpty ? p.defaultModel : _models[p.id]!.text);
      }
      await s.setActiveProvider(_active);
      await s.setFallbackEnabled(_fallback);
      // Read back so a silent storage failure is visible instead of "saved".
      final saved = <String>[
        for (final p in allProviders)
          if ((await s.apiKey(p) ?? '').isNotEmpty) p.label,
      ];
      messenger.showSnackBar(SnackBar(
        content: Text(saved.isEmpty ? 'সেভ হয়নি: কোনো API key পাওয়া যায়নি' : 'সেভ হয়েছে (key আছে: ${saved.join(', ')})'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('সেভ ব্যর্থ: $e')));
    }
  }

  Future<void> _test(LlmProvider p) async {
    final key = _keys[p.id]!.text.trim();
    if (key.isEmpty) {
      setState(() => _testStatus[p.id] = 'আগে API key দিন');
      return;
    }
    setState(() => _testStatus[p.id] = 'পরীক্ষা চলছে...');
    try {
      final model = _models[p.id]!.text.trim().isEmpty ? p.defaultModel : _models[p.id]!.text.trim();
      final settings = context.read<SettingsStore>();
      await context.read<AiService>().test(p, key, model);
      // A working key is saved right away so forgetting "Save" can't lose it.
      await settings.setApiKey(p, key);
      await settings.setModel(p, model);
      setState(() => _testStatus[p.id] = 'সংযোগ ঠিক আছে ✓ (key সেভ হয়েছে)');
    } catch (e) {
      final msg = e.toString();
      setState(() => _testStatus[p.id] = 'ব্যর্থ: ${msg.length > 120 ? msg.substring(0, 120) : msg}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - AI Provider')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('সক্রিয় provider', style: TextStyle(fontWeight: FontWeight.bold)),
          RadioGroup<String>(
            groupValue: _active,
            onChanged: (v) => setState(() => _active = v ?? _active),
            child: Column(
              children: [for (final p in allProviders) RadioListTile<String>(title: Text(p.label), value: p.id)],
            ),
          ),
          SwitchListTile(
            title: const Text('ব্যর্থ হলে অন্য provider এ fallback'),
            value: _fallback,
            onChanged: (v) => setState(() => _fallback = v),
          ),
          const Divider(),
          for (final p in allProviders) ...[
            const SizedBox(height: 8),
            Text(p.label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _keys[p.id],
              obscureText: true,
              decoration: const InputDecoration(labelText: 'API key', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _models[p.id],
              decoration: InputDecoration(labelText: 'Model (default: ${p.defaultModel})', border: const OutlineInputBorder()),
            ),
            Row(children: [
              TextButton(onPressed: () => _test(p), child: const Text('Test connection')),
              Expanded(child: Text(_testStatus[p.id] ?? '', style: Theme.of(context).textTheme.bodySmall)),
            ]),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('সেভ করুন'),
          ),
        ],
      ),
    );
  }
}
