import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../ai/ai_service.dart';
import '../main.dart';
import '../models/product.dart';
import '../services/history_store.dart';
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
  bool _showHints = false;
  // Dictation state. The recognizer restarts its word list after every pause, so
  // finished phrases are kept in _committed and only _partial is replaced.
  String _committed = '';
  String _partial = '';
  bool _wantListening = false; // true from mic-on until the user taps stop
  int _silentRestarts = 0;

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
      _controller.clear();
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
        _controller.clear();
      });
    } catch (e) {
      if (mounted) _snack('প্রশ্ন আনা যায়নি: $e');
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
        if (_wantListening && quiet && _silentRestarts < 3) {
          _silentRestarts++;
          _onSessionEnded();
          return;
        }
        _wantListening = false;
        setState(() => _listening = false);
        _snack(
          quiet
              ? 'কিছু শোনা যায়নি। আবার মাইক চাপুন।'
              : 'মাইক্রোফোন সমস্যা: ${e.errorMsg}',
        );
      },
    );
    if (mounted) setState(() => _speechReady = ok);
  }

  Future<void> _toggleMic() async {
    if (_listening || _wantListening) {
      await _stopListening();
      return;
    }
    if (!_speechReady) {
      _snack('এই ডিভাইসে voice input চালু করা যায়নি। টাইপ করে লিখুন।');
      return;
    }
    _committed = _controller.text.trim(); // keep whatever is already in the box
    _partial = '';
    _silentRestarts = 0;
    _wantListening = true;
    setState(() => _listening = true);
    await _listen();
  }

  Future<void> _listen() => _speech.listen(
    onResult: _onResult,
    listenOptions: SpeechListenOptions(
      localeId: 'bn_BD',
      partialResults: true,
      listenMode: ListenMode.dictation,
      cancelOnError: false,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 8),
    ),
  );

  Future<void> _stopListening() async {
    _wantListening = false;
    _commitPartial();
    if (_speech.isListening) await _speech.stop();
    if (mounted) setState(() => _listening = false);
  }

  /// The engine stopped on its own (a pause): bank what was heard and listen again.
  Future<void> _onSessionEnded() async {
    _commitPartial();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted || !_wantListening || _speech.isListening) return;
    try {
      await _listen();
    } catch (_) {
      _wantListening = false;
      if (mounted) setState(() => _listening = false);
    }
  }

  static String _join(String a, String b) =>
      a.isEmpty ? b : (b.isEmpty ? a : '$a $b');

  void _commitPartial() {
    _committed = _join(_committed, _partial);
    _partial = '';
  }

  void _onResult(SpeechRecognitionResult r) {
    final words = r.recognizedWords.trim();
    if (words.isNotEmpty) _silentRestarts = 0;
    debugPrint(
      'stt final=${r.finalResult} words="$words" committed="$_committed" partial="$_partial"',
    );

    // Some engines start a new phrase without flagging the old one as final: the word
    // list shrinks and starts differently. Bank the old phrase instead of overwriting it.
    if (!r.finalResult && _partial.isNotEmpty && words.isNotEmpty) {
      final startsSame = words.startsWith(_partial.split(' ').first);
      if (!startsSame && words.length < _partial.length) _commitPartial();
    }

    if (r.finalResult) {
      _partial = words;
      _commitPartial();
    } else {
      _partial = words;
    }
    final text = _join(_committed, _partial);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _submit() async {
    final pitch = _controller.text.trim();
    if (pitch.length < 10) {
      _snack('আগে পিচটি বলুন বা লিখুন।');
      return;
    }
    final question = _objectionMode ? _objection : null;
    if (_objectionMode && question == null) {
      _snack('আগে দোকানদারের প্রশ্ন লোড হতে দিন।');
      return;
    }
    final ai = context.read<AiService>();
    final history = context.read<HistoryNotifier>();
    final navigator = Navigator.of(context);
    await _stopListening();
    setState(() {
      _scoring = true;
      _listening = false;
    });
    try {
      final result = await ai.score(widget.product, pitch, question: question);
      final name = question == null
          ? widget.product.name
          : '${widget.product.name} (আপত্তি)';
      await history.add(
        Attempt(widget.product.id, name, pitch, DateTime.now(), result),
      );
      if (!mounted) return;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            product: widget.product,
            pitch: pitch,
            result: result,
            idealAnswer: question?.idealAnswer,
          ),
        ),
      );
    } catch (e) {
      if (mounted) _snack('স্কোর করা যায়নি: $e');
    } finally {
      if (mounted) setState(() => _scoring = false);
    }
  }

  Widget _objectionCard() {
    if (_loadingObjection) {
      return const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('দোকানদার প্রশ্ন ভাবছে...'),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'দোকানদার বলছে:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _objection?.question ?? 'প্রশ্ন লোড হয়নি।',
          style: const TextStyle(fontSize: 16),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _scoring ? null : _loadObjection,
            icon: const Icon(Icons.refresh),
            label: const Text('অন্য প্রশ্ন'),
          ),
        ),
      ],
    );
  }

  Widget _productHeader(Product p) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primaryContainer, cs.secondaryContainer],
        ),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'product-${p.id}',
            child: ProductImage(product: p, size: 130, radius: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(p.category),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: cs.surface.withValues(alpha: 0.6),
                  side: BorderSide.none,
                ),
                Text(
                  p.name,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                if (p.mrp.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'MRP: ${p.mrpText}',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  void dispose() {
    _wantListening = false;
    _speech.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(title: const Text('পিচ প্র্যাকটিস')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _productHeader(p),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('পিচ করুন'),
                icon: Icon(Icons.record_voice_over),
              ),
              ButtonSegment(
                value: true,
                label: Text('আপত্তি সামলান'),
                icon: Icon(Icons.question_answer),
              ),
            ],
            selected: {_objectionMode},
            onSelectionChanged: (s) => _setMode(s.first),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _objectionMode
                  ? _objectionCard()
                  : const Text(
                      'দোকানদারকে এই পণ্যটি পিচ করুন। মাইক বাটনে চেপে বলুন, তারপর লেখা ঠিক করে স্কোর নিন।',
                    ),
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _showHints = !_showHints),
            icon: Icon(
              _showHints ? Icons.visibility_off : Icons.lightbulb_outline,
            ),
            label: Text(
              _showHints ? 'ইঙ্গিত লুকান' : 'ইঙ্গিত দেখুন (মূল পয়েন্ট)',
            ),
          ),
          if (_showHints)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final k in p.keyPoints) Text('• ${k.point}')],
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            minLines: 6,
            maxLines: 12,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: _listening
                  ? 'শুনছি...'
                  : (_objectionMode
                        ? 'আপনার উত্তর এখানে আসবে (এডিট করা যাবে)'
                        : 'আপনার পিচ এখানে আসবে (এডিট করা যাবে)'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FloatingActionButton(
                heroTag: 'mic',
                backgroundColor: _listening ? Colors.red : null,
                onPressed: _scoring ? null : _toggleMic,
                child: Icon(_listening ? Icons.stop : Icons.mic),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _scoring ? null : _submit,
                  icon: _scoring
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_scoring ? 'স্কোর হচ্ছে...' : 'স্কোর দেখুন'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
