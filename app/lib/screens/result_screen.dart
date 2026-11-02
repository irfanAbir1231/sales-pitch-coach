import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ai/score_result.dart';
import '../l10n/l10n.dart';
import '../models/product.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';

class ResultScreen extends StatefulWidget {
  final Product product;
  final String pitch;
  final ScoreResult result;

  /// Set in objection mode; shown instead of the ideal pitch.
  final String? idealAnswer;

  /// Read the feedback aloud as soon as the screen opens (right after scoring).
  final bool autoSpeak;

  /// Overrides "Try again" (default: pop back to the practice screen).
  final VoidCallback? onTryAgain;
  const ResultScreen({
    this.onTryAgain,
    super.key,
    required this.product,
    required this.pitch,
    required this.result,
    this.idealAnswer,
    this.autoSpeak = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final TtsService _tts = context.read<TtsService>();
  bool _voiceMissing = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoSpeak) WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  /// What the avatar says: the feedback, then the better way to say it.
  String get _script => [widget.result.feedback, widget.result.betterLine].where((t) => t.trim().isNotEmpty).join('. ');

  Future<void> _speak() async {
    final ok = await _tts.speak(_script);
    if (mounted) setState(() => _voiceMissing = !ok);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final r = widget.result;
    return Scaffold(
      appBar: DsAppBar(title: l.yourScore),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
          color: AppColors.chrome,
          border: Border(top: BorderSide(color: AppColors.border, width: 2)),
        ),
          padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.sm),
          child: ChunkyButton(label: l.tryAgain, onPressed: widget.onTryAgain ?? () => Navigator.pop(context)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          _hero(context, r.total),
          const SizedBox(height: AppSpace.lg),
          DsCard(
            child: Column(
              children: [
                _bar(context, l.critKeyPoints, r.keyPointsScore, 4),
                _bar(context, l.critReason, r.reasonScore, 2),
                _bar(context, l.critStructure, r.structureScore, 2),
                _bar(context, l.critTone, r.toneScore, 1),
                _bar(context, l.critNoFalseClaims, r.noFalseClaimsScore, 1),
              ],
            ),
          ),
          if (r.feedback.isNotEmpty)
            _section(l.feedbackTitle, AppIcons.chat, AppColors.accentLight, AppColors.accentTint, AppColors.accent, [
              Text(r.feedback, style: AppText.body),
            ]),
          if (r.coveredPoints.isNotEmpty)
            _section(l.coveredTitle, AppIcons.checkCircle, AppColors.successLight, AppColors.successTint, AppColors.success, [
              for (final c in r.coveredPoints) _item(AppIcons.check, AppColors.successLight, c),
            ]),
          if (r.missedPoints.isNotEmpty)
            _section(l.missedTitle, AppIcons.xCircle, AppColors.redLight, AppColors.redTint, AppColors.red, [
              for (final m in r.missedPoints) _item(AppIcons.close, AppColors.redLight, m),
            ]),
          if (r.falseClaims.isNotEmpty)
            _section(l.falseClaimsTitle, AppIcons.warning, AppColors.orangeLight, AppColors.orangeTint, AppColors.orange, [
              for (final f in r.falseClaims) _item(AppIcons.warning, AppColors.orangeLight, f),
            ]),
          if (r.betterLine.isNotEmpty)
            _section(l.betterLineTitle, AppIcons.hint, AppColors.primaryLight, AppColors.primaryTint, AppColors.primary, [
              Text(r.betterLine, style: AppText.body),
            ]),
          const SizedBox(height: AppSpace.md),
          DsCard(
            padding: EdgeInsets.zero,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                iconColor: AppColors.primary,
                collapsedIconColor: AppColors.textMuted,
                title: Text(widget.idealAnswer == null ? l.viewIdealPitch : l.viewIdealAnswer, style: AppText.headline),
                childrenPadding: const EdgeInsets.fromLTRB(AppSpace.lg, 0, AppSpace.lg, AppSpace.lg),
                expandedAlignment: Alignment.centerLeft,
                children: [Text(widget.idealAnswer ?? widget.product.idealPitch, style: AppText.body)],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Center(child: Text(l.scoredBy(r.providerName), style: AppText.caption)),
        ],
      ),
    );
  }

  /// The avatar reacts to the score and speaks the feedback; the number counts up.
  Widget _hero(BuildContext context, double total) {
    final l = context.l10n;
    final (mood, line) = total >= 7
        ? (MascotMood.celebrating, l.praiseHigh)
        : total >= 4
            ? (MascotMood.happy, l.praiseMid)
            : (MascotMood.sad, l.praiseLow);
    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _tts.speaking,
          builder: (context, speaking, _) => Column(
            children: [
              GestureDetector(
                onTap: speaking ? _tts.stop : _speak,
                child: Mascot(mood: mood, size: 130, talking: speaking),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(line, style: AppText.title),
              const SizedBox(height: AppSpace.sm),
              if (_script.isNotEmpty)
                ChunkyButton(
                  label: speaking ? l.stopSpeaking : l.listenFeedback,
                  icon: speaking ? AppIcons.stop : AppIcons.speaker,
                  variant: ChunkyVariant.secondary,
                  expand: false,
                  compact: true,
                  onPressed: speaking ? _tts.stop : _speak,
                ),
            ],
          ),
        ),
        if (_voiceMissing)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.sm),
            child: Text(l.voiceUnavailable, style: AppText.caption.copyWith(color: AppColors.orangeLight), textAlign: TextAlign.center),
          ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: total),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                localizeDigits(v.toStringAsFixed(1), context),
                style: AppText.display.copyWith(fontSize: 60, height: 1.2, color: scoreColor(total)),
              ),
              const SizedBox(width: AppSpace.xs),
              Text(l.outOfTen, style: AppText.headline.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _section(String title, IconData icon, Color iconColor, Color tint, Color edge, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.lg),
      child: DsCard(
        tint: tint,
        edge: edge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: AppSpace.sm),
                Expanded(child: Text(title, style: AppText.headline)),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _item(IconData i, Color c, String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 4), child: Icon(i, color: c, size: 20)),
          const SizedBox(width: AppSpace.sm),
          Expanded(child: Text(t, style: AppText.body)),
        ]),
      );

  Widget _bar(BuildContext context, String label, double v, double max) {
    final ratio = max == 0 ? 0.0 : v / max;
    final color = ratio >= 0.7 ? AppColors.success : (ratio >= 0.4 ? AppColors.orange : AppColors.red);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
      child: Row(children: [
        SizedBox(width: 112, child: Text(label, style: AppText.bodyStrong.copyWith(fontSize: 14))),
        Expanded(child: DsProgressBar(value: ratio, color: color, height: 12)),
        const SizedBox(width: AppSpace.sm),
        SizedBox(
          width: 40,
          child: Text(
            localizeDigits('${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)}/${max.toInt()}', context),
            textAlign: TextAlign.end,
            style: AppText.caption,
          ),
        ),
      ]),
    );
  }
}
