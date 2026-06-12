import 'uploaded_document.dart';

/// A single message in the AccessAlly AI conversation.
///
/// Field naming follows what every call-site already uses:
///   • chat_service.dart  — id, text, isUser, timestamp, attachedDocument
///   • chat_bubble.dart   — text, isUser, timestamp, attachedDocument
///   • nvidia_service.dart — role, content  (derived getters below)
class ChatMessage {
  final String           id;
  final String           text;
  final bool             isUser;
  final DateTime         timestamp;
  final UploadedDocument? attachedDocument;
  /// Optional override for the OpenAI role string.
  /// Defaults to 'user' / 'assistant' derived from [isUser].
  final String?          _roleOverride;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachedDocument,
    String? role,
  }) : _roleOverride = role;

  // ── OpenAI-compatible getters (used by nvidia_service.dart) ───────────────
  /// 'system' | 'user' | 'assistant'
  String get role    => _roleOverride ?? (isUser ? 'user' : 'assistant');

  /// Alias for [text] — keeps nvidia_service.dart happy.
  String get content => text;

  // ── Convenience ───────────────────────────────────────────────────────────
  ChatMessage copyWith({String? text, String? role}) => ChatMessage(
    id:               id,
    text:             text ?? this.text,
    isUser:           isUser,
    timestamp:        timestamp,
    attachedDocument: attachedDocument,
    role:             role ?? _roleOverride,
  );

  @override
  String toString() => 'ChatMessage(role: $role, text: $text)';
}