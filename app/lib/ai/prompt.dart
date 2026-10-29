import 'dart:convert';

import '../models/product.dart';
import 'score_result.dart';

/// Shared by every provider so the score format is identical.
class ScoringPrompt {
  static const system = '''
তুমি একজন অভিজ্ঞ সেলস ট্রেইনার। একজন সেলস অফিসার একজন দোকানদারকে (retailer) একটি পণ্য পিচ করার অনুশীলন করছে। তুমি তার পিচ মূল্যায়ন করবে।
নিয়ম:
- অর্থ দেখে মূল্যায়ন করো, হুবহু শব্দ মেলানো লাগবে না। সমার্থক শব্দ ও বাংলার ভেতরে ইংরেজি শব্দ (যেমন white booster, fast, clean) গ্রহণযোগ্য।
- পিচটি স্পিচ-টু-টেক্সট থেকে এসেছে, তাই ছোটখাটো বানান/শব্দ ভুল উপেক্ষা করো।
- শুধুমাত্র দেওয়া পণ্যের তথ্যের ভিত্তিতে বিচার করো। তালিকার বাইরের দাবি করলে এবং তা পণ্যের তথ্যের সাথে মিলে না গেলে, বা must_not_say তে থাকা কিছু বললে সেটি false_claims এ রাখো।
- feedback এবং better_line বাংলায় লেখো। feedback সংক্ষিপ্ত, উৎসাহব্যঞ্জক ও নির্দিষ্ট হবে (সর্বোচ্চ ৩-৪ বাক্য)।
- শুধু একটি JSON অবজেক্ট ফেরত দাও, অন্য কোনো লেখা নয়।
''';

  static const objectionSystem = '''
তুমি একজন অভিজ্ঞ সেলস ট্রেইনার। একজন দোকানদার (retailer) সেলস অফিসারকে একটি আপত্তি বা প্রশ্ন করেছে। শুধু একটি JSON অবজেক্ট ফেরত দাও, অন্য কোনো লেখা নয়।
''';

  /// Asks the model to invent a realistic retailer objection for [p].
  static String objectionRequest(Product p) => '''
পণ্য: ${p.name}
আদর্শ পিচ: ${p.idealPitch}

এই পণ্য নিয়ে একজন দোকানদার সত্যিকারের দোকানে যে ধরনের আপত্তি বা সন্দেহ তুলতে পারে (যেমন: দাম, অন্য ব্র্যান্ড, চাহিদা, ফলাফল নিয়ে সন্দেহ) তার একটি তৈরি করো। প্রশ্ন বাংলায়, ছোট ও স্বাভাবিক কথ্য ভাষায়। আদর্শ উত্তর শুধু উপরের আদর্শ পিচের তথ্যের ভিত্তিতে হবে, নতুন তথ্য বানাবে না।
{"question": "দোকানদারের প্রশ্ন", "ideal_answer": "অফিসারের আদর্শ উত্তর"}
''';

  static Objection parseObjection(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) throw const FormatException('AI reply did not contain JSON');
    final j = jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
    return Objection(j['question'].toString(), j['ideal_answer'].toString());
  }

  /// [question] is set in objection mode: the pitch is then an answer to it.
  static String user(Product p, String pitch, {Objection? question}) {
    final points = p.keyPoints
        .map((k) => {
              'id': k.id,
              'point': k.point,
              'keywords': k.keywords,
              'synonyms': k.synonyms,
            })
        .toList();
    final objectionBlock = question == null
        ? ''
        : '''
এটি আপত্তি-মোকাবিলার অনুশীলন। দোকানদার বলেছে: "${question.question}"
আদর্শ উত্তর (রেফারেন্স): ${question.idealAnswer}
অফিসারের লেখাটি এই প্রশ্নের উত্তর। মূল্যায়ন করো সে প্রশ্নটির সরাসরি জবাব দিয়েছে কি না, দোকানদারের চিন্তা বিনয়ের সাথে স্বীকার করেছে কি না, পণ্যের সঠিক তথ্য ও কারণ দিয়ে বুঝিয়েছে কি না। structure_score এ দেখো: আপত্তি স্বীকার, উত্তর/কারণ, ইতিবাচক সমাপ্তি। "relevant_point_ids" এ শুধু সেই মূল পয়েন্টগুলো দাও যা এই প্রশ্নের উত্তরে প্রাসঙ্গিক (অপ্রাসঙ্গিক পয়েন্ট না বলায় নম্বর কাটা যাবে না)।
''';
    return '''
পণ্য: ${p.name}
আদর্শ পিচ (রেফারেন্স): ${p.idealPitch}
মূল পয়েন্টসমূহ: ${jsonEncode(points)}
must_not_say: ${jsonEncode(p.mustNotSay)}
$objectionBlock
সেলস অফিসারের ${question == null ? 'পিচ' : 'উত্তর'}:
"""
$pitch
"""

এই JSON ফরম্যাটে উত্তর দাও:
{${question == null ? '' : '\n  "relevant_point_ids": ["প্রাসঙ্গিক মূল পয়েন্টের id"],'}
  "covered_point_ids": ["মূল পয়েন্টের যেসব id পিচে কভার হয়েছে"],
  "reason_score": 0-2 (পণ্যের মূল কারণ/উপাদান কেন কাজ করে তা "কারণ/তাই" দিয়ে যুক্ত করে বলেছে কি; ০=না, ১=আংশিক, ২=স্পষ্টভাবে),
  "structure_score": 0-2 (শুরুতে বিনয়ী সম্বোধন, উপকারিতা, কারণ, সমাপ্তি/স্টকে রাখার আহ্বান - কয়টি আছে),
  "tone_score": 0-1 (বিনয়ী, স্পষ্ট ও ছোট বাক্য কি না; ১ বা ০),
  "false_claims": ["ভুল বা নিষিদ্ধ দাবি, না থাকলে খালি"],
  "feedback": "বাংলায় সংক্ষিপ্ত মতামত",
  "better_line": "বাংলায় একটি উন্নত বাক্য বা পিচ যা অফিসার পরেরবার বলতে পারে"
}
''';
  }

  /// Extracts the JSON object from a model reply and converts it into a
  /// [ScoreResult]. The numeric score is computed here, not by the model.
  static ScoreResult parse(String raw, Product p, String providerName) {
    var text = raw.trim();
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw const FormatException('AI reply did not contain JSON');
    }
    text = text.substring(start, end + 1);
    final j = jsonDecode(text) as Map<String, dynamic>;

    final covered = Set<String>.from((j['covered_point_ids'] ?? const []).map((e) => e.toString()));
    // Objection mode: only points relevant to the question count towards the score.
    final relevantIds = Set<String>.from((j['relevant_point_ids'] ?? const []).map((e) => e.toString()));
    final scored = relevantIds.isEmpty ? p.keyPoints : p.keyPoints.where((k) => relevantIds.contains(k.id)).toList();
    final totalWeight = scored.fold<int>(0, (s, k) => s + k.weight);
    final coveredWeight = scored.where((k) => covered.contains(k.id)).fold<int>(0, (s, k) => s + k.weight);
    final keyScore = totalWeight == 0 ? 0.0 : 4.0 * coveredWeight / totalWeight;

    double clamp(num? v, double max) => ((v ?? 0).toDouble()).clamp(0, max).toDouble();
    final reason = clamp(j['reason_score'] as num?, 2);
    final structure = clamp(j['structure_score'] as num?, 2);
    final tone = clamp(j['tone_score'] as num?, 1);
    final falseClaims = List<String>.from((j['false_claims'] ?? const []).map((e) => e.toString()));
    final noFalse = falseClaims.isEmpty ? 1.0 : 0.0;

    final total = double.parse((keyScore + reason + structure + tone + noFalse).clamp(0, 10).toStringAsFixed(1));

    return ScoreResult(
      total: total,
      keyPointsScore: double.parse(keyScore.toStringAsFixed(1)),
      reasonScore: reason,
      structureScore: structure,
      toneScore: tone,
      noFalseClaimsScore: noFalse,
      coveredPoints: scored.where((k) => covered.contains(k.id)).map((k) => k.point).toList(),
      missedPoints: scored.where((k) => !covered.contains(k.id)).map((k) => k.point).toList(),
      falseClaims: falseClaims,
      feedback: (j['feedback'] ?? '').toString(),
      betterLine: (j['better_line'] ?? '').toString(),
      providerName: providerName,
    );
  }
}
