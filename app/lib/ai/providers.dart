import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'prompt.dart';
import 'score_result.dart';

class ProviderConfig {
  final String apiKey;
  final String model;
  const ProviderConfig(this.apiKey, this.model);
}

abstract class LlmProvider {
  String get id;
  String get label;
  String get defaultModel;

  /// Sends the prompt and returns the raw text reply of the model.
  Future<String> complete(ProviderConfig cfg, String system, String user);

  Future<ScoreResult> score(ProviderConfig cfg, Product p, String pitch, {Objection? question}) async {
    final prompt = ScoringPrompt.user(p, pitch, question: question);
    final raw = await complete(cfg, ScoringPrompt.system, prompt);
    try {
      return ScoringPrompt.parse(raw, p, label);
    } on FormatException {
      // One retry for malformed JSON.
      final retry = await complete(cfg, ScoringPrompt.system, '$prompt\n\nশুধু বৈধ JSON দাও।');
      return ScoringPrompt.parse(retry, p, label);
    }
  }

  Future<Objection> generateObjection(ProviderConfig cfg, Product p) async {
    final raw = await complete(cfg, ScoringPrompt.objectionSystem, ScoringPrompt.objectionRequest(p));
    return ScoringPrompt.parseObjection(raw);
  }
}

Never _fail(String name, http.Response r) {
  final body = utf8.decode(r.bodyBytes, allowMalformed: true);
  throw Exception('$name error ${r.statusCode}: ${body.length > 300 ? body.substring(0, 300) : body}');
}

class ClaudeProvider extends LlmProvider {
  @override
  String get id => 'claude';
  @override
  String get label => 'Claude';
  @override
  String get defaultModel => 'claude-haiku-5-5';

  @override
  Future<String> complete(ProviderConfig cfg, String system, String user) async {
    final r = await http
        .post(
          Uri.parse('https://api.anthropic.com/v1/messages'),
          headers: {
            'x-api-key': cfg.apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          body: jsonEncode({
            'model': cfg.model,
            'max_tokens': 1200,
            'temperature': 0,
            'system': system,
            'messages': [
              {'role': 'user', 'content': user}
            ],
          }),
        )
        .timeout(const Duration(seconds: 45));
    if (r.statusCode != 200) _fail(label, r);
    final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    return (j['content'] as List).map((c) => c['text'] ?? '').join();
  }
}

class GroqProvider extends LlmProvider {
  @override
  String get id => 'groq';
  @override
  String get label => 'Groq';
  @override
  String get defaultModel => 'openai/gpt-oss-120b';

  @override
  Future<String> complete(ProviderConfig cfg, String system, String user) async {
    final r = await http
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer ${cfg.apiKey}',
            'content-type': 'application/json',
          },
          body: jsonEncode({
            'model': cfg.model,
            'temperature': 0,
            'response_format': {'type': 'json_object'},
            'messages': [
              {'role': 'system', 'content': system},
              {'role': 'user', 'content': user},
            ],
          }),
        )
        .timeout(const Duration(seconds: 45));
    if (r.statusCode != 200) _fail(label, r);
    final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    return j['choices'][0]['message']['content'] as String;
  }
}

class GeminiProvider extends LlmProvider {
  @override
  String get id => 'gemini';
  @override
  String get label => 'Gemini';
  @override
  String get defaultModel => 'gemini-2.5-flash';

  @override
  Future<String> complete(ProviderConfig cfg, String system, String user) async {
    final r = await http
        .post(
          Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/${cfg.model}:generateContent'),
          headers: {
            'x-goog-api-key': cfg.apiKey,
            'content-type': 'application/json',
          },
          body: jsonEncode({
            'systemInstruction': {
              'parts': [
                {'text': system}
              ]
            },
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': user}
                ]
              }
            ],
            'generationConfig': {'temperature': 0, 'responseMimeType': 'application/json'},
          }),
        )
        .timeout(const Duration(seconds: 45));
    if (r.statusCode != 200) _fail(label, r);
    final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    final parts = j['candidates'][0]['content']['parts'] as List;
    return parts.map((p) => p['text'] ?? '').join();
  }
}

final allProviders = <LlmProvider>[ClaudeProvider(), GroqProvider(), GeminiProvider()];
