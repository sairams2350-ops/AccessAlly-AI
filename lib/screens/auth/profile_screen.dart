import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/language_service.dart';
import '../../utils/theme.dart';
import '../../utils/app_strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _roleLabels = {
    'officer': 'Admission Officer',
    'admin':   'Institution Admin',
    'viewer':  'Management Viewer',
  };

  static const _roleIcons = {
    'officer': Icons.badge_outlined,
    'admin':   Icons.admin_panel_settings_outlined,
    'viewer':  Icons.visibility_outlined,
  };

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) { return iso; }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final auth = context.read<AuthService>();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 24),
          SizedBox(width: 10),
          Text('Delete Account',
              style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.error.withValues(alpha: 0.25)),
            ),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, color: AppTheme.error, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This will permanently delete your account and all associated data. '
                      'This action cannot be undone.',
                  style: TextStyle(color: AppTheme.error, fontSize: 12),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          const Text('Are you sure you want to continue?',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              textAlign: TextAlign.center),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_forever_rounded, size: 16),
            label: const Text('Yes, Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final success = await auth.deleteAccount();
    if (!context.mounted) return;
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Failed to delete account.'),
        backgroundColor: AppTheme.error,
      ));
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthService>().signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  // ── Language picker dialog ─────────────────────────────────────────────────
  Future<void> _showLanguagePicker(BuildContext context) async {
    final langService = context.read<LanguageService>();
    final strings     = AppStrings(langService.currentLanguageCode);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.language_rounded, color: AppTheme.primary, size: 22),
          const SizedBox(width: 10),
          Text(strings.selectLanguage,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        ]),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: LanguageService.supportedLanguages.length,
            separatorBuilder: (_, __) => const Divider(
                height: 1, color: AppTheme.surfaceBorder),
            itemBuilder: (_, i) {
              final lang     = LanguageService.supportedLanguages[i];
              final isActive = lang['code'] == langService.currentLanguageCode;
              return ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primary.withValues(alpha: 0.15)
                        : AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? AppTheme.primary
                          : AppTheme.surfaceBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      lang['code']!.toUpperCase(),
                      style: TextStyle(
                        color: isActive
                            ? AppTheme.primary
                            : AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  lang['native']!,
                  style: TextStyle(
                    color: isActive
                        ? AppTheme.primary
                        : AppTheme.textPrimary,
                    fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  lang['name']!,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11),
                ),
                trailing: isActive
                    ? const Icon(Icons.check_circle_rounded,
                    color: AppTheme.primary, size: 20)
                    : null,
                onTap: () async {
                  await langService.setLanguage(lang['code']!);
                  // Clear chat history so the new language takes full effect
                  // without old-language context confusing the AI model.
                  if (ctx.mounted) {
                    context.read<ChatService>().clearConversation();
                    Navigator.pop(ctx);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel,
                style: const TextStyle(color: AppTheme.textMuted)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth        = context.watch<AuthService>();
    final langService = context.watch<LanguageService>();
    final strings     = AppStrings(langService.currentLanguageCode);
    final user        = auth.user ?? {};

    final role      = user['role'] as String? ?? 'officer';
    final roleLabel = _roleLabels[role] ?? role;
    final roleIcon  = _roleIcons[role] ?? Icons.person_outline;
    final initials  = _initials(user['displayName']);
    final createdAt = _formatDate(user['createdAt'] as String?);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(strings.myProfile),
        backgroundColor: AppTheme.bg,
        actions: [
          IconButton(
            tooltip: strings.signOut,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Avatar + name card ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 14),
                Text(user['displayName'] ?? '—',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(user['email'] ?? '—',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13)),
                const SizedBox(height: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(roleIcon, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(roleLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ),

            const SizedBox(height: 28),

            // ── Account Details ────────────────────────────────────────────
            Text(strings.accountDetails,
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            const SizedBox(height: 10),

            _DetailCard(children: [
              _DetailRow(
                  icon: Icons.person_outline,
                  label: strings.fullName,
                  value: user['displayName'] ?? '—'),
              const _Divider(),
              _DetailRow(
                  icon: Icons.email_outlined,
                  label: strings.officialEmail,
                  value: user['email'] ?? '—'),
              const _Divider(),
              _DetailRow(
                  icon: Icons.school_outlined,
                  label: strings.institutionName,
                  value: user['institution'] ?? '—'),
              const _Divider(),
              _DetailRow(
                  icon: roleIcon,
                  label: strings.yourRole,
                  value: roleLabel),
              const _Divider(),
              _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member Since',
                  value: createdAt),
            ]),

            const SizedBox(height: 28),

            // ── Language Preference ────────────────────────────────────────
            Text(strings.languagePreference,
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.language_rounded,
                      color: AppTheme.primary, size: 20),
                ),
                title: Text(strings.appLanguage,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                subtitle: Text(langService.currentLanguageName,
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textMuted, size: 20),
                onTap: () => _showLanguagePicker(context),
              ),
            ),

            const SizedBox(height: 28),

            // ── Compliance ─────────────────────────────────────────────────
            Text(strings.compliance,
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            const SizedBox(height: 10),

            _DetailCard(children: [
              _DetailRow(
                  icon: Icons.verified_rounded,
                  label: 'Standard',
                  value:
                  // ignore: spell_check_configuration_errors
                  'UGC 2022 · RPWD 2016 · NEP 2020',
                  valueColor: AppTheme.accent),
            ]),

            const SizedBox(height: 28),

            // ── Danger Zone ────────────────────────────────────────────────
            Text(strings.dangerZone,
                style: const TextStyle(
                    color: AppTheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border:
                Border.all(color: AppTheme.error.withValues(alpha: 0.25)),
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_forever_rounded,
                      color: AppTheme.error, size: 20),
                ),
                title: Text(strings.deleteAccount,
                    style: const TextStyle(
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                subtitle: const Text(
                    'Permanently remove your account and data',
                    style:
                    TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.error, size: 20),
                onTap: auth.isLoading ? null : () => _confirmDelete(context),
              ),
            ),

            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.surfaceBorder),
    ),
    child: Column(children: children),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color?   valueColor;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 17),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      color: valueColor ?? AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ]),
      ),
    ]),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 1,
    indent: 16,
    endIndent: 16,
    color: AppTheme.surfaceBorder,
  );
}