import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ai/ai_service.dart';
import '../ai/providers.dart';
import '../l10n/l10n.dart';
import '../services/settings_store.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';

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
        setState(() => _error = context.l10n.pinTooShort);
        return;
      }
      await store.setPin(pin);
      setState(() => _unlocked = true);
    } else if (await store.checkPin(pin)) {
      setState(() => _unlocked = true);
    } else {
      setState(() => _error = context.l10n.pinWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return const AdminScreen();
    return Scaffold(
      appBar: DsAppBar(title: context.l10n.adminTitle),
      body: _hasPin == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppSpace.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_hasPin! ? context.l10n.enterPin : context.l10n.setPin, style: AppText.title),
                  const SizedBox(height: AppSpace.lg),
                  TextField(
                    controller: _pin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(errorText: _error),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  ChunkyButton(label: context.l10n.ok, onPressed: _submit),
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
    final l = context.l10n;
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
        content: Text(saved.isEmpty ? l.saveNoKey : l.savedWithKeys(saved.join(', '))),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.saveError('$e'))));
    }
  }

  Future<void> _test(LlmProvider p) async {
    final key = _keys[p.id]!.text.trim();
    if (key.isEmpty) {
      setState(() => _testStatus[p.id] = context.l10n.enterKeyFirst);
      return;
    }
    setState(() => _testStatus[p.id] = context.l10n.testing);
    try {
      final model = _models[p.id]!.text.trim().isEmpty ? p.defaultModel : _models[p.id]!.text.trim();
      final settings = context.read<SettingsStore>();
      await context.read<AiService>().test(p, key, model);
      // A working key is saved right away so forgetting "Save" can't lose it.
      await settings.setApiKey(p, key);
      await settings.setModel(p, model);
      setState(() => _testStatus[p.id] = context.l10n.connectionOk);
    } catch (e) {
      final msg = e.toString();
      setState(() => _testStatus[p.id] = context.l10n.failedMsg(msg.length > 120 ? msg.substring(0, 120) : msg));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: DsAppBar(title: context.l10n.adminProviderTitle),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          Text(context.l10n.activeProvider, style: AppText.title),
          RadioGroup<String>(
            groupValue: _active,
            onChanged: (v) => setState(() => _active = v ?? _active),
            child: Column(
              children: [for (final p in allProviders) RadioListTile<String>(title: Text(p.label), value: p.id)],
            ),
          ),
          SwitchListTile(
            title: Text(context.l10n.fallbackSwitch),
            value: _fallback,
            onChanged: (v) => setState(() => _fallback = v),
          ),
          const Divider(),
          for (final p in allProviders)
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.md),
              child: DsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.label, style: AppText.headline),
                    const SizedBox(height: AppSpace.md),
                    TextField(
                      controller: _keys[p.id],
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'API key'),
                    ),
                    const SizedBox(height: AppSpace.md),
                    TextField(
                      controller: _models[p.id],
                      decoration: InputDecoration(labelText: 'Model (default: ${p.defaultModel})'),
                    ),
                    Row(children: [
                      TextButton(onPressed: () => _test(p), child: const Text('Test connection')),
                      Expanded(child: Text(_testStatus[p.id] ?? '', style: AppText.caption)),
                    ]),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpace.lg),
          ChunkyButton(label: context.l10n.save, onPressed: _save),
        ],
      ),
    );
  }
}
