import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/chat_message.dart';

class NvidiaService {
  static const String _apiKey = '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';
  static String get _baseUrl => kIsWeb
      ? 'http://localhost:8010/proxy/v1'
      : 'https://integrate.api.nvidia.com/v1';

  static const String _textModel  = 'meta/llama-3.1-70b-instruct';
  static const String _visionModel = 'meta/llama-3.2-11b-vision-instruct';

  // ── Dynamic system prompt with language injection ─────────────────────────
  static String _buildSystemPrompt(String langCode, String langName) {
    final langInstruction = langCode == 'en'
        ? ''
        : '\n\nIMPORTANT: You MUST respond ONLY in $langName language. '
        'Every part of your response — headers, bullet points, explanations — '
        'must be written in $langName. Do not use English except for proper nouns '
        'like "RPWD Act 2016", "UGC", "UDID", "NEP 2020".';

    return '''
You are AccessAlly AI, a STRICTLY FACTUAL assistant for disability-inclusive admissions in Indian Higher Education Institutions (HEIs).

CRITICAL ANTI-HALLUCINATION RULES — MUST FOLLOW AT ALL TIMES:
1. ONLY state information that is EXPLICITLY present in UGC Accessibility Guidelines 2022, RPWD Act 2016, or NEP 2020.
2. If you are NOT 100% certain a fact exists in these documents, say: "I don't have verified information on this. Please refer to the official UGC/MSJE guidelines directly."
3. NEVER invent section numbers, clause numbers, percentages, or deadlines that you are not certain about.
4. NEVER fabricate names of committees, schemes, or government bodies.
5. If asked something outside your knowledge base, say: "This is outside my verified knowledge. Please consult the official source."
6. ALWAYS distinguish between what is MANDATORY vs RECOMMENDED in the law.
7. Do NOT extrapolate or infer rules — only state what is explicitly written.

VERIFIED KNOWLEDGE BASE:
- UGC Accessibility Guidelines 2022
- Rights of Persons with Disabilities (RPWD) Act 2016 — 21 benchmark disabilities
- National Education Policy (NEP) 2020 disability provisions
- UDID (Unique Disability ID) system by MSJE
- ICF (International Classification of Functioning) coding
- ICD-10/11 medical classification
- CRC (Composite Regional Centre) / DDRC (District Disability Rehabilitation Centre) processes

YOUR TASKS:
1. Guide admission officers through the UGC 3-step admission process
2. Map disability type to correct RPWD 2016 benchmark category (1–21)
3. Generate accommodation plans (academic, physical, information, social)
4. Verify document requirements (UDID card, specialist reports, certificates)
5. Calculate exam concessions (extra time, scribe, assistive tech)
6. Flag when CRC/DDRC referral is needed
7. Recommend WCAG 2.1 AA compliant digital solutions

RESPONSE FORMAT:
- Use markdown with clear headers
- Always cite which law/guideline your answer comes from
- If uncertain, explicitly say so — never guess
- Keep responses concise and actionable

TONE: Warm, professional, empathetic, and precise.$langInstruction
''';
  }

  // ── Image detection helpers ───────────────────────────────────────────────
  static bool _isImage(String? content) =>
      content != null && content.startsWith('[IMAGE_BASE64:');

  static Map<String, String> _parseImage(String content) {
    final closeBracket = content.indexOf(']');
    final ext = content.substring(14, closeBracket);
    final base64Data = content.substring(closeBracket + 1);
    return {'ext': ext, 'base64': base64Data};
  }

  static String _mimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png':  return 'image/png';
      default:     return 'image/jpeg';
    }
  }

  // ── Main stream method ────────────────────────────────────────────────────
  Stream<String> streamMessage({
    required List<ChatMessage> conversationHistory,
    required String userMessage,
    String? documentContent,
    String? documentName,
    String languageCode = 'en',
    String languageName = 'English',
  }) async* {
    try {
      final isImage = _isImage(documentContent);
      final model   = isImage ? _visionModel : _textModel;

      final messages = isImage
          ? _buildVisionMessages(conversationHistory, userMessage,
          documentContent!, documentName, languageCode, languageName)
          : _buildTextMessages(conversationHistory, userMessage,
          documentContent, documentName, languageCode, languageName);

      final request = http.Request('POST', Uri.parse('$_baseUrl/chat/completions'));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      });
      request.body = jsonEncode({
        'model': model,
        'messages': messages,
        'max_tokens': isImage ? 1024 : 2048,
        'temperature': 0.1,
        'top_p': 0.8,
        'stream': true,
      });

      final client = http.Client();
      final response = await client.send(request);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        yield '\n\n⚠️ **API Error ${response.statusCode}**: $body';
        return;
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        for (final line in chunk.split('\n')) {
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') return;
          try {
            final json = jsonDecode(data);
            final text = json['choices']?[0]?['delta']?['content'];
            if (text is String && text.isNotEmpty) yield text;
          } catch (_) {}
        }
      }
    } catch (e) {
      yield '\n\n⚠️ **Connection Error**: ${e.toString()}\n\nCheck your internet connection and NVIDIA API key.';
    }
  }

  // ── Text messages (PDF / plain text) ─────────────────────────────────────
  List<Map<String, dynamic>> _buildTextMessages(
      List<ChatMessage> history,
      String userMessage,
      String? documentContent,
      String? documentName,
      String langCode,
      String langName,
      ) {
    String content = userMessage;
    if (documentContent != null && documentName != null) {
      content = '[UPLOADED DOCUMENT: $documentName]\n---\n$documentContent\n---\nUser Query: $userMessage';
    }

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': _buildSystemPrompt(langCode, langName)},
    ];
    final recent = history.length > 10 ? history.sublist(history.length - 10) : history;
    for (final m in recent) {
      messages.add({'role': m.isUser ? 'user' : 'assistant', 'content': m.text});
    }
    messages.add({'role': 'user', 'content': content});
    return messages;
  }

  // ── Vision messages (PNG / JPG images) ───────────────────────────────────
  List<Map<String, dynamic>> _buildVisionMessages(
      List<ChatMessage> history,
      String userMessage,
      String documentContent,
      String? documentName,
      String langCode,
      String langName,
      ) {
    final parsed  = _parseImage(documentContent);
    final mime    = _mimeType(parsed['ext']!);
    final base64  = parsed['base64']!;
    final dataUrl = 'data:$mime;base64,$base64';

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': _buildSystemPrompt(langCode, langName)},
    ];

    final recent = history.length > 6 ? history.sublist(history.length - 6) : history;
    for (final m in recent) {
      messages.add({'role': m.isUser ? 'user' : 'assistant', 'content': m.text});
    }

    messages.add({
      'role': 'user',
      'content': [
        {
          'type': 'image_url',
          'image_url': {'url': dataUrl},
        },
        {
          'type': 'text',
          'text': documentName != null
              ? 'Document: $documentName\n\n$userMessage'
              : userMessage,
        },
      ],
    });

    return messages;
  }
}