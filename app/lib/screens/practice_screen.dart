import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../ai/ai_service.dart';
import '../l10n/l10n.dart';
import '../main.dart';
import '../models/product.dart';
import '../services/history_store.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';
import '../widgets/product_image.dart';
import 'result_screen.dart';

class PracticeScreen extends StatefulWidget {
  final Product product;
  final bool startInObjection;
  const PracticeScreen({
    super.key,
    required this.product,
    this.startInObjection = false,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final _speech = SpeechToText();
  final _controller = TextEditingController();
  bool _speechReady = false;
  bool _listening = false;
  bool _scoring = false;
  // Dictation state. The recognizer restarts its word list after every pause, so
  // finished phrases are kept in _committed and only _partial is replaced.
  String _committed = '';
  String _partial = '';
  bool _wantListening = false; // true from mic-on until the user taps stop
  bool _acceptResults = false; // false once dictation is fully stopped
  bool _restarting = false;
  int _errorRestarts = 0;

  String _localeId = 'bn_BD';
  bool _objectionMode = false;
  Objection? _objection;
  bool _loadingObjection = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    if (widget.startInObjection) {
      _objectionMode = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadObjection());
    }
  }

  Future<void> _setMode(bool objection) async {
    await _stopListening();
    setState(() {
      _objectionMode = objection;
      _listening = false;
      _clearPitch();
    });
    if (objection && _objection == null) await _loadObjection();
  }

  Future<void> _loadObjection() async {
    final ai = context.read<AiService>();
    setState(() => _loadingObjection = true);
    try {
      final o = await ai.nextObjection(
        widget.product,
        previous: _objection?.question,
      );
      if (!mounted) return;
      setState(() {
        _objection = o;
        _clearPitch();
      });
    } catch (e) {
      if (mounted) _snack(context.l10n.questionLoadFailed('$e'));
    } finally {
      if (mounted) setState(() => _loadingObjection = false);
    }
  }

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onStatus: (s) {
        // The engine ends its session after a pause. Keep dictating until the user stops.
        if ((s == 'done' || s == 'notListening') && mounted && _wantListening) {
          _onSessionEnded();
        }
      },
      onError: (e) {
        if (!mounted) return;
        final quiet =
            e.errorMsg == 'error_no_match' ||
            e.errorMsg == 'error_speech_timeout';
        // Silence is not a failure: keep listening until the user taps stop.
        if (_wantListening && quiet) {
          _onSessionEnded();
          return;
        }
        // Other hiccups (busy/client) get a few retries before giving up.
        if (_wantListening && _errorRestarts < 3) {
          _errorRestarts++;
          _onSessionEnded();
          return;
        }
        _stopListening();
        _snack(context.l10n.micProblem(e.errorMsg));
      },
    );
    if (mounted) setState(() => _speechReady = ok);
  }

  /// Push-to-talk: dictation runs only while the mic button is held down.
  Future<void> _startHold() async {
    if (_scoring || _listening || _wantListening) return;
    if (!_speechReady) {
      _snack(context.l10n.micUnavailable);
      return;
    }
    FocusScope.of(context).unfocus();
    _localeId = context.isEnglish ? 'en_US' : 'bn_BD';
    _committed = _controller.text.trim(); // keep whatever is already in the box
    _partial = '';
    _errorRestarts = 0;
    _wantListening = true;
    _acceptResults = true;
    setState(() => _listening = true);
    try {
      await _listen();
    } catch (_) {
      await _stopListening();
      return;
    }
    // The finger may have lifted while the engine was still starting up.
    if (!_wantListening && _speech.isListening) await _speech.stop();
  }

  Future<void> _endHold(Duration held) async {
    if (!_listening && !_wantListening) return;
    final l = context.l10n;
    await _stopListening();
    if (held < const Duration(milliseconds: 400) && mounted) {
      _snack(l.holdMicSnack);
    }
  }

  Future<void> _listen() => _speech.listen(
    onResult: _onResult,
    listenOptions: SpeechListenOptions(
      localeId: _localeId,
      partialResults: true,
      listenMode: ListenMode.dictation,
      cancelOnError: false,
      listenFor: const Duration(minutes: 10),
      pauseFor: const Duration(seconds: 30),
    ),
  );

  Future<void> _stopListening() async {
    final wasOn = _wantListening || _speech.isListening;
    _wantListening = false;
    if (wasOn) {
      if (_speech.isListening) await _speech.stop();
      // Give the engine a moment to deliver its final result, then bank the rest.
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
    _commitPartial();
    _acceptResults = false;
    _syncController();
    if (mounted) setState(() => _listening = false);
  }

  /// The engine stopped on its own (a pause): bank what was heard and listen again.
  Future<void> _onSessionEnded() async {
    if (_restarting) return;
    _restarting = true;
    try {
      _commitPartial();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted || !_wantListening || _speech.isListening) return;
      await _listen();
    } catch (_) {
      if (_wantListening) _stopListening();
    } finally {
      _restarting = false;
    }
  }

  static String _join(String a, String b) =>
      a.isEmpty ? b : (b.isEmpty ? a : '$a $b');

  void _commitPartial() {
    _committed = _join(_committed, _partial);
    _partial = '';
  }

  void _syncController() {
    final text = _join(_committed, _partial);
    if (text == _controller.text) return;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// Empty the box and forget any dictated text, so the next attempt starts fresh.
  void _clearPitch() {
    _committed = '';
    _partial = '';
    _controller.clear();
  }

  void _onResult(SpeechRecognitionResult r) {
    if (!_acceptResults) return;
    final words = r.recognizedWords.trim();
    debugPrint(
      'stt final=${r.finalResult} words="$words" committed="$_committed" partial="$_partial"',
    );
    // Engines emit empty results around a pause; never let them erase text.
    if (words.isEmpty) {
      if (r.finalResult) _commitPartial();
      return;
    }

    // Some engines start a new phrase without flagging the old one as final: the word
    // list shrinks and starts differently. Bank the old phrase instead of overwriting it.
    if (!r.finalResult && _partial.isNotEmpty) {
      final startsSame = words.startsWith(_partial.split(' ').first);
      if (!startsSame && words.length < _partial.length) _commitPartial();
    }

    if (r.finalResult) {
      // A late final repeating what is already banked must not be added twice.
      if (_partial.isEmpty && _committed.endsWith(words)) return;
      _partial = words;
      _commitPartial();
    } else {
      _partial = words;
    }
    _syncController();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final language = context.isEnglish ? 'en' : 'bn';
    final ai = context.read<AiService>();
    final history = context.read<HistoryNotifier>();
    final navigator = Navigator.of(context);
    if (_listening || _wantListening) await _stopListening();
    final pitch = _controller.text.trim();
    if (pitch.length < 10) {
      _snack(l.speakOrTypeFirst);
      return;
    }
    final question = _objectionMode ? _objection : null;
    if (_objectionMode && question == null) {
      _snack(l.waitForQuestion);
      return;
    }
    setState(() {
      _scoring = true;
      _listening = false;
    });
    try {
      final result = await ai.score(widget.product, pitch, question: question, language: language);
      final name = question == null
          ? widget.product.name
          : '${widget.product.name} (আপত্তি)';
      await history.add(
        Attempt(widget.product.id, name, pitch, DateTime.now(), result),
      );
      if (!mounted) return;
      _clearPitch(); // fresh box when the user comes back to try again
      navigator.push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            product: widget.product,
            pitch: pitch,
            result: result,
            idealAnswer: question?.idealAnswer,
            autoSpeak: true,
          ),
        ),
      );
    } catch (e) {
      if (mounted) _snack(l.scoreFailed('$e'));
    } finally {
      if (mounted) setState(() => _scoring = false);
    }
  }

  Widget _objectionBubble() {
    if (_loadingObjection) {
      return Row(
        children: [
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 3)),
          const SizedBox(width: AppSpace.md),
          Expanded(child: Text(context.l10n.shopkeeperThinking, style: AppText.bodyStrong)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.shopkeeperSays, style: AppText.caption.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpace.xs),
        Text(_objection?.question ?? context.l10n.questionNotLoaded, style: AppText.bodyStrong),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _scoring ? null : _loadObjection,
            icon: const Icon(AppIcons.refresh),
            label: Text(context.l10n.anotherQuestion),
          ),
        ),
      ],
    );
  }

  Widget _productHeader(Product p) {
    return DsCard(
      padding: const EdgeInsets.all(AppSpace.md),
      child: Row(
        children: [
          Hero(
            tag: 'product-${p.id}',
            child: ProductImage(product: p, size: 88, radius: 16),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizedCategory(context, p.category), style: AppText.caption.copyWith(color: AppColors.accentLight, fontWeight: FontWeight.w800)),
                Text(p.localName(context.isEnglish), style: AppText.headline),
                if (p.mrp.isNotEmpty) Text('MRP: ${localizeDigits(p.mrpText, context)}', style: AppText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The avatar guides the user: it voices the current step, and in objection
  /// mode the shopkeeper's question sits in its bubble.
  Widget _prompt() {
    final l = context.l10n;
    final mood = _listening
        ? MascotMood.listening
        : (_scoring || _loadingObjection ? MascotMood.thinking : MascotMood.happy);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Mascot(mood: mood, size: 72),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: DsCard(
              padding: const EdgeInsets.all(AppSpace.md),
              child: _objectionMode && !_listening && !_scoring
                  ? _objectionBubble()
                  : Text(
                      _listening ? l.tipListening : (_scoring ? l.tipScoring : l.tipPitch),
                      style: AppText.bodyStrong,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  void dispose() {
    _wantListening = false;
    _acceptResults = false;
    _speech.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Key points in a bottom sheet, so the page itself never has to grow or scroll.
  void _showHintsSheet() {
    final l = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(AppIcons.hint, color: AppColors.orange),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(child: Text(l.hints, style: AppText.title)),
                  IconButton(tooltip: l.close, onPressed: () => Navigator.pop(ctx), icon: const Icon(AppIcons.close)),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              for (final k in widget.product.keyPoints)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.sm),
                  child: Text('• ${k.point}', style: AppText.body),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.chrome,
          border: Border(top: BorderSide(color: AppColors.border, width: 2)),
        ),
        padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.sm),
        child: Row(
          children: [
            ChunkyButton(
              label: context.l10n.hints,
              icon: AppIcons.hint,
              variant: ChunkyVariant.secondary,
              expand: false,
              onPressed: _showHintsSheet,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: ChunkyButton(
                label: _scoring ? context.l10n.scoring : context.l10n.getScore,
                icon: _scoring ? null : AppIcons.check,
                onPressed: _scoring ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: DsAppBar(title: context.l10n.pitchPractice),
      bottomNavigationBar: _bottomBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          _productHeader(p),
          const SizedBox(height: AppSpace.lg),
          Row(
            children: [
              Expanded(
                child: DsChoicePill(
                  label: context.l10n.pitchMode,
                  expand: true,
                  selected: !_objectionMode,
                  onTap: () => _setMode(false),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: DsChoicePill(
                  label: context.l10n.handleObjections,
                  expand: true,
                  selected: _objectionMode,
                  onTap: () => _setMode(true),
                ),
              ),
            ],
          ),
          _prompt(),
          Center(
            child: HoldToTalkButton(
              listening: _listening,
              enabled: !_scoring,
              size: 112,
              onStart: _startHold,
              onEnd: _endHold,
            ),
          ),
          Center(
            child: Text(
              _listening ? context.l10n.listeningRelease : context.l10n.holdToTalk,
              style: AppText.bodyStrong.copyWith(color: _listening ? AppColors.redLight : AppColors.textMuted),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          TextField(
            controller: _controller,
            // Manual edits become the new base text for dictation.
            onChanged: (t) {
              _committed = t.trim();
              _partial = '';
            },
            minLines: 4,
            maxLines: 10,
            style: AppText.body,
            decoration: InputDecoration(
              hintText: _listening
                  ? context.l10n.listeningHint
                  : (_objectionMode ? context.l10n.answerHint : context.l10n.pitchHint),
            ),
          ),
        ],
      ),
    );
  }
}
