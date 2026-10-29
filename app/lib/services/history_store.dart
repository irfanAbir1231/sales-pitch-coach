import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../ai/score_result.dart';

class Attempt {
  final String productId;
  final String productName;
  final String pitch;
  final DateTime at;
  final ScoreResult result;
  Attempt(this.productId, this.productName, this.pitch, this.at, this.result);

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'pitch': pitch,
        'at': at.toIso8601String(),
        'result': result.toJson(),
      };

  factory Attempt.fromJson(Map<String, dynamic> j) => Attempt(
        j['productId'] as String,
        j['productName'] as String,
        j['pitch'] as String,
        DateTime.parse(j['at'] as String),
        ScoreResult.fromJson(j['result'] as Map<String, dynamic>),
      );
}

class HistoryStore {
  static const _key = 'attempts_v1';
  late SharedPreferences _prefs;
  List<Attempt> attempts = [];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_key);
    if (raw != null) {
      attempts = (jsonDecode(raw) as List).map((e) => Attempt.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> add(Attempt a) async {
    attempts.insert(0, a);
    if (attempts.length > 200) attempts = attempts.sublist(0, 200);
    await _prefs.setString(_key, jsonEncode(attempts.map((e) => e.toJson()).toList()));
  }

  double? bestFor(String productId) {
    final s = attempts.where((a) => a.productId == productId).map((a) => a.result.total);
    return s.isEmpty ? null : s.reduce((a, b) => a > b ? a : b);
  }
}
