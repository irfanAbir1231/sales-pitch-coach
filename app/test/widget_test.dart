import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sales_pitch_coach/ai/prompt.dart';
import 'package:sales_pitch_coach/models/product.dart';

void main() {
  final data = jsonDecode(File('assets/products.json').readAsStringSync()) as Map<String, dynamic>;
  final products = (data['products'] as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();

  test('dataset loads and every product has key points and a pitch', () {
    expect(products.length, greaterThan(100));
    for (final p in products) {
      expect(p.keyPoints, isNotEmpty, reason: p.id);
      expect(p.idealPitch, isNotEmpty, reason: p.id);
    }
    expect(products.map((p) => p.id).toSet().length, products.length);
  });

  test('score is computed from covered weights and clamped to 10', () {
    final p = products.firstWhere((p) => p.id == 'chaka-ball-soap');
    final all = p.keyPoints.map((k) => '"${k.id}"').join(',');
    final perfect = '{"covered_point_ids":[$all],"reason_score":2,"structure_score":2,"tone_score":1,"false_claims":[],"feedback":"ok","better_line":"x"}';
    expect(ScoringPrompt.parse(perfect, p, 'T').total, 10.0);

    final weak = '{"covered_point_ids":[],"reason_score":0,"structure_score":0,"tone_score":0,"false_claims":["x"],"feedback":"","better_line":""}';
    final r = ScoringPrompt.parse(weak, p, 'T');
    expect(r.total, 0.0);
    expect(r.missedPoints.length, p.keyPoints.length);
  });

  test('objection mode scores only the points relevant to the question', () {
    final p = products.firstWhere((p) => p.id == 'chaka-ball-soap'); // kp1..kp4, weights 2,2,3,2
    const reply = '{"relevant_point_ids":["kp3","kp4"],"covered_point_ids":["kp3"],"reason_score":2,"structure_score":2,"tone_score":1,"false_claims":[],"feedback":"","better_line":""}';
    final r = ScoringPrompt.parse(reply, p, 'T');
    expect(r.keyPointsScore, closeTo(4 * 3 / 5, 0.05)); // 3 of 5 relevant weight
    expect(r.missedPoints.length, 1);
    final o = ScoringPrompt.parseObjection('{"question":"q?","ideal_answer":"a"}');
    expect(o.question, 'q?');
  });

  test('parser tolerates markdown fences and rejects non-JSON', () {
    final p = products.first;
    const fenced = '```json\n{"covered_point_ids":["kp1"],"reason_score":1,"structure_score":1,"tone_score":1,"false_claims":[],"feedback":"f","better_line":"b"}\n```';
    expect(ScoringPrompt.parse(fenced, p, 'T').coveredPoints.length, 1);
    expect(() => ScoringPrompt.parse('no json here', p, 'T'), throwsFormatException);
  });
}
