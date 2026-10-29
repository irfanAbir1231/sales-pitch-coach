import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ai/providers.dart';
import '../dev_defaults.dart';

/// API keys, chosen models, active provider, fallback order and admin PIN.
/// Keys live in encrypted secure storage on phones; non-secret options in
/// preferences. On web, secure storage is only obfuscated localStorage and was
/// unreliable, so secrets go to preferences there.
class SettingsStore {
  static const _secureStorage = FlutterSecureStorage();
  late SharedPreferences _prefs;

  Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  Future<String?> _readSecret(String k) async =>
      kIsWeb ? _prefs.getString('secret_$k') : _secureStorage.read(key: k);

  Future<void> _writeSecret(String k, String v) async {
    if (kIsWeb) {
      await _prefs.setString('secret_$k', v);
    } else {
      await _secureStorage.write(key: k, value: v);
    }
  }

  Future<void> _deleteSecret(String k) async {
    if (kIsWeb) {
      await _prefs.remove('secret_$k');
    } else {
      await _secureStorage.delete(key: k);
    }
  }

  String get activeProviderId => _prefs.getString('active_provider') ?? 'groq';
  Future<void> setActiveProvider(String id) => _prefs.setString('active_provider', id);

  bool get fallbackEnabled => _prefs.getBool('fallback_enabled') ?? true;
  Future<void> setFallbackEnabled(bool v) => _prefs.setBool('fallback_enabled', v);

  // 'model2_' (was 'model_'): older builds saved a Groq default the API no longer serves.
  String modelFor(LlmProvider p) => _prefs.getString('model2_${p.id}') ?? p.defaultModel;
  Future<void> setModel(LlmProvider p, String m) => _prefs.setString('model2_${p.id}', m.trim());

  Future<String?> apiKey(LlmProvider p) async {
    final saved = await _readSecret('key_${p.id}');
    if (saved != null && saved.isNotEmpty) return saved;
    return p.id == 'groq' && devGroqKey.isNotEmpty ? devGroqKey : null;
  }
  Future<void> setApiKey(LlmProvider p, String key) async {
    if (key.trim().isEmpty) {
      await _deleteSecret('key_${p.id}');
    } else {
      await _writeSecret('key_${p.id}', key.trim());
    }
  }

  static const defaultPin = '1234';

  // A PIN is always set: the default until someone calls setPin().
  Future<bool> hasPin() async => true;
  // 'admin_pin_v2' (was 'admin_pin'): drops PINs typed during earlier test builds.
  Future<bool> checkPin(String pin) async => ((await _readSecret('admin_pin_v2')) ?? defaultPin) == pin;
  Future<void> setPin(String pin) => _writeSecret('admin_pin_v2', pin);
}
