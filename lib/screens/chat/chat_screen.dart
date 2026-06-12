import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/document_service.dart';
import '../../services/nvidia_service.dart';
import '../../services/language_service.dart';
import '../../models/uploaded_document.dart';
import '../../utils/theme.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/document_upload_sheet.dart';
import '../../widgets/typing_indicator.dart';
import '../../widgets/quick_action_chips.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _nvidia     = NvidiaService();
  UploadedDocument? _pendingDoc;
  bool   _isUploading    = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatService>().initSession();
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? override]) async {
    final text = override ?? _inputCtrl.text.trim();
    if (text.isEmpty && _pendingDoc == null) return;

    final chat = context.read<ChatService>();
    final doc  = _pendingDoc;
    _inputCtrl.clear();
    setState(() => _pendingDoc = null);

    chat.addUserMessage(text, document: doc);
    _scrollToBottom();
    chat.startStreaming();

    final lang = context.read<LanguageService>();
    try {
      await for (final chunk in _nvidia.streamMessage(
        conversationHistory: chat.messages.toList(),
        userMessage: text.isEmpty ? 'Please analyse this document.' : text,
        documentContent: doc?.extractedText,
        documentName: doc?.name,
        languageCode: lang.langCode,
        languageName: lang.langName,
      )) {
        chat.appendStreamingContent(chunk);
        _scrollToBottom();
      }
      chat.finalizeStreaming();
    } catch (e) {
      chat.addErrorMessage(e.toString());
    }
    _scrollToBottom();
  }

  // ── Document pick ──────────────────────────────────────────────────────────
  Future<void> _pickDocument() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DocumentUploadSheet(),
    );
    if (!mounted) return;

    final docService  = context.read<DocumentService>();
    final chatService = context.read<ChatService>();
    // FIX: read lang here so the snackbar error is also translated
    final lang        = context.read<LanguageService>();

    setState(() { _isUploading = true; _uploadProgress = 0; });
    try {
      final picked = await docService.pickDocument();
      if (picked == null) {
        setState(() => _isUploading = false);
        return;
      }
      final uploaded = await docService.processDocument(
        picked: picked,
        sessionId: chatService.currentSessionId ?? 'default',
        documentCategory: 'general',
        onProgress: (p) => setState(() => _uploadProgress = p),
      );
      setState(() { _pendingDoc = uploaded; _isUploading = false; });
      _inputCtrl.text =
      'Please analyse this document and tell me what accommodations are required.';
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          // FIX: was hardcoded 'Upload failed: $e'
          content: Text('${lang.uploadFailedPrefix}$e'),
          backgroundColor: AppTheme.error,
        ));
      }
    }
  }

  // ── Language picker ────────────────────────────────────────────────────────
  void _showLanguagePicker() {
    final langService = context.read<LanguageService>();
    final search = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          // FIX: use LanguageService.supportedLanguages — single source of truth
          final filtered = LanguageService.supportedLanguages
              .where((l) =>
          l['name']!.toLowerCase().contains(search.text.toLowerCase()) ||
              l['native']!.toLowerCase().contains(search.text.toLowerCase()))
              .toList();
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  const Icon(Icons.language_rounded,
                      color: AppTheme.primary, size: 22),
                  const SizedBox(width: 10),
                  // FIX: was hardcoded 'Select Language'
                  Text(langService.selectLanguage,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: search,
                  onChanged: (_) => setS(() {}),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    // FIX: was hardcoded 'Search language...'
                    hintText: langService.searchLanguage,
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textMuted, size: 20),
                    filled: true,
                    fillColor: AppTheme.surfaceElevated,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final lang = filtered[i];
                    final isSelected =
                        lang['code'] == langService.langCode;
                    return ListTile(
                      leading: Text(lang['flag']!,
                          style: const TextStyle(fontSize: 22)),
                      title: Text(lang['name']!,
                          style: TextStyle(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                      subtitle: Text(lang['native']!,
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12)),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primary, size: 20)
                          : null,
                      onTap: () {
                        langService.setLanguage(
                            lang['code']!, lang['name']!);
                        context.read<ChatService>().clearConversation();
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final chat = context.watch<ChatService>();
    // FIX: watch LanguageService here so the entire screen rebuilds on change
    final lang = context.watch<LanguageService>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      // FIX: pass lang into _appBar so it receives translated strings
      appBar: _appBar(auth, lang),
      body: Column(children: [
        if (_isUploading)
          LinearProgressIndicator(
            value: _uploadProgress > 0 ? _uploadProgress : null,
            backgroundColor: AppTheme.surfaceBorder,
            color: AppTheme.primary,
            minHeight: 3,
          ),
        Expanded(child: _messageList(chat)),
        if (chat.messages.length <= 1)
          QuickActionChips(onChipTap: _send),
        if (_pendingDoc != null) _docPreview(),
        // FIX: pass lang into _inputBar for translated hint text
        _inputBar(chat, lang),
      ]),
    );
  }

  // FIX: accept LanguageService so all strings in the AppBar are translated
  PreferredSizeWidget _appBar(AuthService auth, LanguageService lang) => AppBar(
    backgroundColor: AppTheme.bg,
    leading: Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.accent]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.accessibility_new_rounded,
          color: Colors.white, size: 22),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AccessAlly AI',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Row(children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
                color: AppTheme.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(auth.displayName ?? 'Officer',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ]),
      ],
    ),
    actions: [
      // FIX: no Consumer needed here — build() already watches LanguageService
      GestureDetector(
        onTap: _showLanguagePicker,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.language_rounded,
                color: AppTheme.primary, size: 14),
            const SizedBox(width: 4),
            Text(lang.langCode.toUpperCase(),
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.refresh_rounded,
            color: AppTheme.textSecondary),
        // FIX: was hardcoded 'New Session'
        tooltip: lang.newSession,
        onPressed: () => context.read<ChatService>().clearConversation(),
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded,
            color: AppTheme.textSecondary),
        color: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        onSelected: (v) async {
          if (v == 'profile') {
            Navigator.pushNamed(context, '/profile');
          } else if (v == 'logout') {
            await auth.signOut();
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          }
        },
        // FIX: removed const — items now use runtime lang.xxx strings
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'profile',
            child: Row(children: [
              const Icon(Icons.person_outline_rounded,
                  size: 18, color: AppTheme.primary),
              const SizedBox(width: 10),
              // FIX: was hardcoded 'My Profile'
              Text(lang.myProfile,
                  style: const TextStyle(color: AppTheme.textPrimary)),
            ]),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'logout',
            child: Row(children: [
              const Icon(Icons.logout_rounded,
                  size: 18, color: AppTheme.error),
              const SizedBox(width: 10),
              // FIX: was hardcoded 'Sign Out'
              Text(lang.signOut,
                  style: const TextStyle(color: AppTheme.error)),
            ]),
          ),
        ],
      ),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: AppTheme.surfaceBorder),
    ),
  );

  Widget _messageList(ChatService chat) => ListView.builder(
    controller: _scrollCtrl,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    itemCount: chat.messages.length + (chat.isTyping ? 1 : 0),
    itemBuilder: (_, i) {
      if (i == chat.messages.length && chat.isTyping) {
        return TypingIndicator(streamingContent: chat.streamingContent);
      }
      return ChatBubble(message: chat.messages[i]);
    },
  );

  Widget _docPreview() {
    final doc = _pendingDoc!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Text(doc.iconEmoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doc.name,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(doc.categoryLabel,
                  style: const TextStyle(
                      color: AppTheme.primary, fontSize: 11)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded,
              color: AppTheme.textMuted, size: 18),
          onPressed: () => setState(() => _pendingDoc = null),
        ),
      ]),
    );
  }

  // FIX: accept LanguageService so hintText is translated
  Widget _inputBar(ChatService chat, LanguageService lang) => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
    decoration: BoxDecoration(
      color: AppTheme.bg,
      border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(
        width: 44, height: 44,
        margin: const EdgeInsets.only(right: 8),
        child: Material(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _isUploading ? null : _pickDocument,
            child: Center(
              child: _isUploading
                  ? SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  value: _uploadProgress > 0 ? _uploadProgress : null,
                  color: AppTheme.primary,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.attach_file_rounded,
                  color: AppTheme.textSecondary, size: 22),
            ),
          ),
        ),
      ),
      Expanded(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 120),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: TextField(
            controller: _inputCtrl,
            maxLines: null,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              // FIX: was hardcoded 'Ask about disability accommodations...'
              hintText: lang.inputHint,
              hintStyle: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
            onSubmitted: (_) => _send(),
          ),
        ),
      ),
      Container(
        width: 44, height: 44,
        margin: const EdgeInsets.only(left: 8),
        child: Material(
          color: chat.isTyping
              ? AppTheme.surfaceBorder
              : AppTheme.primary,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: chat.isTyping ? null : () => _send(),
            child: Center(
              child: chat.isTyping
                  ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    color: AppTheme.primary, strokeWidth: 2),
              )
                  : const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    ]),
  );
}