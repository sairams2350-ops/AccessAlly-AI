import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import '../utils/theme.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: message.isUser ? _buildUserBubble() : _buildAIBubble(),
    );
  }

  Widget _buildAIBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Avatar
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 10, top: 2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.accent],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.accessibility_new_rounded,
              color: Colors.white, size: 18),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AccessAlly AI',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.aiBubble,
                  borderRadius: const BorderRadius.only(
                    topRight:    Radius.circular(16),
                    bottomLeft:  Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: MarkdownBody(
                  data: message.text,
                  styleSheet: _buildMarkdownStyle(),
                  shrinkWrap: true,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(message.timestamp),
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserBubble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Document attachment preview
        if (message.attachedDocument != null)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.attachedDocument!.iconEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.attachedDocument!.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      message.attachedDocument!.categoryLabel,
                      style: const TextStyle(
                          color: AppTheme.primary, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Message bubble
        if (message.text.isNotEmpty)
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: const BoxDecoration(
              color: AppTheme.userBubble,
              borderRadius: BorderRadius.only(
                topLeft:     Radius.circular(16),
                topRight:    Radius.circular(4),
                bottomLeft:  Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 14, height: 1.5),
            ),
          ),

        const SizedBox(height: 4),
        Text(
          _formatTime(message.timestamp),
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
        ),
      ],
    );
  }

  MarkdownStyleSheet _buildMarkdownStyle() {
    return MarkdownStyleSheet(
      p: const TextStyle(
          color: AppTheme.textPrimary, fontSize: 14, height: 1.6),
      h1: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700),
      h2: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600),
      h3: const TextStyle(
          color: AppTheme.accent,
          fontSize: 14,
          fontWeight: FontWeight.w600),
      strong: const TextStyle(
          color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
      em: const TextStyle(
          color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
      code: const TextStyle(
        color:           AppTheme.accent,
        backgroundColor: Color(0xFF1A2A1A),
        fontFamily:      'monospace',
        fontSize:        13,
      ),
      codeblockDecoration: BoxDecoration(
        color:        const Color(0xFF111B11),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.2)),
      ),
      blockquoteDecoration: BoxDecoration(
        color:        AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: const Border(
            left: BorderSide(color: AppTheme.primary, width: 3)),
      ),
      blockquote: const TextStyle(
          color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
      listBullet:
      const TextStyle(color: AppTheme.accent, fontSize: 14),
      tableHead: const TextStyle(
          color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
      tableBody:
      const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      tableBorder: TableBorder.all(
          color:        AppTheme.surfaceBorder,
          borderRadius: BorderRadius.circular(6)),
      tableHeadAlign: TextAlign.left,
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}