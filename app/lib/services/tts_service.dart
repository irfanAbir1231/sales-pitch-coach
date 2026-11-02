import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Reads text aloud and tells the UI when it is speaking (the avatar's mouth
/// animates while [speaking] is true).
class TtsService {
  final FlutterTts _tts = FlutterTts();
  final ValueNotifier<bool> speaking = ValueNotifier(false);
  bool _ready = false;

  static final _bangla = RegExp('[ঀ-৿]');

  /// Bangla text is read with a Bangla voice, anything else in English.
  static String localeFor(String text) => _bangla.hasMatch(text) ? 'bn-BD' : 'en-US';

  Future<void> _init() async {
    if (_ready) return;
    _ready = true;
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.05);
    _tts.setStartHandler(() => speaking.value = true);
    _tts.setCompletionHandler(() => speaking.value = false);
    _tts.setCancelHandler(() => speaking.value = false);
    _tts.setErrorHandler((_) => speaking.value = false);
  }

  /// Speaks [text]; returns false when the phone has no voice for its language.
  Future<bool> speak(String text) async {
    final t = text.trim();
    if (t.isEmpty) return true;
    await _init();
    await stop();
    final locale = localeFor(t);
    try {
      final available = await _tts.isLanguageAvailable(locale);
      if (available != true) return false;
      await _tts.setLanguage(locale);
      await _tts.speak(t);
      return true;
    } catch (_) {
      speaking.value = false;
      return false;
    }
  }

  Future<void> stop() async {
    if (!_ready) return;
    await _tts.stop();
    speaking.value = false;
  }
}
