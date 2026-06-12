import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_message.dart';
import '../models/uploaded_document.dart';

class ChatService extends ChangeNotifier {
  static const _kSessions = 'aa_sessions';

  List<ChatMessage> _messages          = [];
  bool              _isTyping          = false;
  String            _streamingContent  = '';
  String            _currentSessionId  = '';

  List<ChatMessage> get messages          => List.unmodifiable(_messages);
  bool              get isTyping          => _isTyping;
  String            get streamingContent  => _streamingContent;
  String?           get currentSessionId  =>
      _currentSessionId.isEmpty ? null : _currentSessionId;

  Future<void> initSession() async {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _messages         = [];
    _streamingContent = '';
    _isTyping         = false;

    // ignore: spell_check_configuration_errors
    addAIMessage('''
## Welcome to AccessAlly AI 👋

I\'m your intelligent assistant for disability-inclusive admissions, aligned with:
- **UGC Accessibility Guidelines 2022**
- **RPWD Act 2016** (21 Benchmark Disabilities)
- **NEP 2020** disability provisions

**How I can help you:**
1. 🗂️ **Verify documents** — Upload UDID cards, medical reports, or checklists using the 📎 button
2. ♿ **Assess accommodations** — Get a tailored plan based on disability type
3. 📋 **Guide the admission process** — Step-by-step per UGC 3-step protocol
4. 📊 **Generate compliance summaries** — Management-ready responses

**To get started**, tell me about the student you\'re admitting, or tap a quick question below.
''');
    notifyListeners();
  }

  ChatMessage addUserMessage(String text, {UploadedDocument? document}) {
    final msg = ChatMessage(
      id:               DateTime.now().microsecondsSinceEpoch.toString(),
      text:             text,
      isUser:           true,
      timestamp:        DateTime.now(),
      attachedDocument: document,
    );
    _messages.add(msg);
    notifyListeners();
    _persist();
    return msg;
  }

  ChatMessage addAIMessage(String text) {
    final msg = ChatMessage(
      id:        DateTime.now().microsecondsSinceEpoch.toString(),
      text:      text,
      isUser:    false,
      timestamp: DateTime.now(),
    );
    _messages.add(msg);
    notifyListeners();
    _persist();
    return msg;
  }

  void startStreaming() {
    _isTyping         = true;
    _streamingContent = '';
    notifyListeners();
  }

  void appendStreamingContent(String chunk) {
    _streamingContent += chunk;
    notifyListeners();
  }

  ChatMessage finalizeStreaming() {
    _isTyping = false;
    final content     = _streamingContent;
    _streamingContent = '';
    final msg = ChatMessage(
      id:        DateTime.now().microsecondsSinceEpoch.toString(),
      text:      content,
      isUser:    false,
      timestamp: DateTime.now(),
    );
    _messages.add(msg);
    notifyListeners();
    _persist();
    return msg;
  }

  void addErrorMessage(String error) {
    _isTyping         = false;
    _streamingContent = '';
    addAIMessage(
      '⚠️ **Error**: $error\n\n'
          'Please check your NVIDIA API key in `nvidia_service.dart` and try again.',
    );
  }

  void setTyping(bool value) {
    _isTyping = value;
    notifyListeners();
  }

  Future<void> clearConversation() async {
    _messages         = [];
    _streamingContent = '';
    _isTyping         = false;
    await initSession();
  }

  // ── Persist last session locally ──────────────────────────────────────────
  Future<void> _persist() async {
    try {
      final prefs    = await SharedPreferences.getInstance();
      final sessions = _loadSessions(prefs);
      sessions[_currentSessionId] = {
        'id':           _currentSessionId,
        'updatedAt':    DateTime.now().toIso8601String(),
        'messageCount': _messages.length,
        'lastMessage':  _messages.isNotEmpty
            ? _messages.last.text
            .substring(0, _messages.last.text.length.clamp(0, 80))
            : '',
        'messages': _messages
            .map((m) => {
          'id':        m.id,
          'text':      m.text,
          'isUser':    m.isUser,
          'timestamp': m.timestamp.toIso8601String(),
        })
            .toList(),
      };
      // Keep last 10 sessions
      if (sessions.length > 10) {
        final sorted = sessions.entries.toList()
          ..sort((a, b) => (b.value['updatedAt'] as String)
              .compareTo(a.value['updatedAt'] as String));
        final keep = Map.fromEntries(sorted.take(10));
        await prefs.setString(_kSessions, jsonEncode(keep));
      } else {
        await prefs.setString(_kSessions, jsonEncode(sessions));
      }
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final prefs    = await SharedPreferences.getInstance();
    final sessions = _loadSessions(prefs);
    return sessions.values
        .map((v) => Map<String, dynamic>.from(v))
        .toList()
      ..sort((a, b) =>
          (b['updatedAt'] as String).compareTo(a['updatedAt'] as String));
  }

  Future<void> loadSession(String sessionId) async {
    final prefs    = await SharedPreferences.getInstance();
    final sessions = _loadSessions(prefs);
    final session  = sessions[sessionId];
    if (session == null) return;
    _currentSessionId = sessionId;
    _messages = (session['messages'] as List)
        .map((m) => ChatMessage(
      id:        m['id'] as String,
      text:      m['text'] as String,
      isUser:    m['isUser'] as bool,
      timestamp: DateTime.parse(m['timestamp'] as String),
    ))
        .toList();
    notifyListeners();
  }

  Map<String, dynamic> _loadSessions(SharedPreferences prefs) {
    final raw = prefs.getString(_kSessions);
    if (raw == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }
}