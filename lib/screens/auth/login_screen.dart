import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../utils/theme.dart';
import 'register_screen.dart';

// ── Supported languages ───────────────────────────────────────────────────────
class _Lang {
  final String code;
  final String name;
  final String native;
  final String flag;
  const _Lang(this.code, this.name, this.native, this.flag);
}

const _languages = [
  _Lang('en', 'English',    'English',    '🇬🇧'),
  _Lang('hi', 'Hindi',      'हिन्दी',       '🇮🇳'),
  _Lang('ta', 'Tamil',      'தமிழ்',        '🇮🇳'),
  _Lang('te', 'Telugu',     'తెలుగు',       '🇮🇳'),
  _Lang('kn', 'Kannada',    'ಕನ್ನಡ',        '🇮🇳'),
  _Lang('ml', 'Malayalam',  'മലയാളം',      '🇮🇳'),
  _Lang('mr', 'Marathi',    'मराठी',        '🇮🇳'),
  _Lang('gu', 'Gujarati',   'ગુજરાતી',      '🇮🇳'),
  _Lang('bn', 'Bengali',    'বাংলা',        '🇮🇳'),
  _Lang('pa', 'Punjabi',    'ਪੰਜਾਬੀ',       '🇮🇳'),
  _Lang('or', 'Odia',       'ଓଡ଼ିଆ',        '🇮🇳'),
  _Lang('as', 'Assamese',   'অসমীয়া',      '🇮🇳'),
  _Lang('ur', 'Urdu',       'اردو',         '🇮🇳'),
  _Lang('ks', 'Kashmiri',   'كشميري',       '🇮🇳'),
  _Lang('sd', 'Sindhi',     'سنڌي',         '🇮🇳'),
  _Lang('sa', 'Sanskrit',   'संस्कृतम्',     '🇮🇳'),
  _Lang('ne', 'Nepali',     'नेपाली',       '🇮🇳'),
  // ignore: spell_check_configuration_errors
  _Lang('si', 'Sinhala',    'සිංහල',        '🇱🇰'),
  _Lang('ar', 'Arabic',     'العربية',      '🇸🇦'),
  _Lang('fr', 'French',     'Français',    '🇫🇷'),
  _Lang('de', 'German',     'Deutsch',     '🇩🇪'),
  _Lang('zh', 'Chinese',    '中文',          '🇨🇳'),
  _Lang('ja', 'Japanese',   '日本語',         '🇯🇵'),
  _Lang('ko', 'Korean',     '한국어',         '🇰🇷'),
  // ignore: spell_check_configuration_errors
  _Lang('es', 'Spanish',    'Español',     '🇪🇸'),
  // ignore: spell_check_configuration_errors
  _Lang('pt', 'Portuguese', 'Português',   '🇧🇷'),
  _Lang('ru', 'Russian',    'Русский',     '🇷🇺'),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  _Lang _selectedLang = _languages.first; // default: English

  @override
  void initState() {
    super.initState();
    // Sync with persisted language on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final langService = context.read<LanguageService>();
      final match = _languages.where((l) => l.code == langService.langCode);
      if (match.isNotEmpty) setState(() => _selectedLang = match.first);
    });
  }

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  // ── Language picker bottom sheet ──────────────────────────────────────────
  void _showLanguagePicker() {
    final search = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final filtered = _languages.where((l) =>
          l.name.toLowerCase().contains(search.text.toLowerCase()) ||
              l.native.toLowerCase().contains(search.text.toLowerCase())).toList();
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  const Icon(Icons.language_rounded, color: AppTheme.primary, size: 22),
                  const SizedBox(width: 10),
                  const Text('Select Language',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ]),
              ),
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: search,
                  onChanged: (_) => setS(() {}),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search language...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textMuted, size: 20),
                    filled: true,
                    fillColor: AppTheme.surfaceElevated,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final lang = filtered[i];
                    final selected = lang.code == _selectedLang.code;
                    return ListTile(
                      leading: Text(lang.flag,
                          style: const TextStyle(fontSize: 22)),
                      title: Text(lang.name,
                          style: TextStyle(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                      subtitle: Text(lang.native,
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12)),
                      trailing: selected
                          ? const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primary, size: 20)
                          : null,
                      onTap: () {
                        setState(() => _selectedLang = lang);
                        context.read<LanguageService>().setLanguage(lang.code, lang.name);
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

  // ── Sign In — 2-step: credentials → OTP → chat ────────────────────────────
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();

    _showLoadingDialog('Sending verification OTP...');
    final credentialsOk = await auth.signInWithEmail(
        _emailCtrl.text, _passCtrl.text);
    if (mounted) Navigator.pop(context);

    if (!mounted) return;
    if (!credentialsOk) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text('OTP sent to ${_emailCtrl.text}'),
      ]),
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 4),
    ));

    final otpCtrl  = TextEditingController();
    final formKey  = GlobalKey<FormState>();

    final otpConfirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.verified_user_rounded, color: AppTheme.primary, size: 22),
          SizedBox(width: 10),
          Text('Verify Sign-In',
              style: TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        ]),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                children: [
                  const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                  TextSpan(
                    text: _emailCtrl.text,
                    style: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  letterSpacing: 10,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                  hintText: '------',
                  counterText: '',
                  prefixIcon: Icon(Icons.pin_outlined, size: 20)),
              validator: (v) => (v?.length == 6) ? null : 'Enter all 6 digits',
            ),
            const SizedBox(height: 10),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.timer_outlined, size: 13, color: AppTheme.textMuted),
              SizedBox(width: 4),
              Text('Valid for 10 minutes',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ]),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
              },
              icon: const Icon(Icons.login_rounded, size: 16),
              label: const Text('Verify & Sign In'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary)),
        ],
      ),
    );

    if (otpConfirmed != true || !mounted) return;

    _showLoadingDialog('Signing in...');
    final success = await auth.verifySignInOtp(otpCtrl.text);
    if (mounted) Navigator.pop(context);

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/chat');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Invalid OTP.'),
        backgroundColor: AppTheme.error,
      ));
    }
  }

  // ── Forgot Password — 3-step OTP flow ─────────────────────────────────────
  Future<void> _forgotPassword() async {
    final auth = context.read<AuthService>();

    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    final formKey1  = GlobalKey<FormState>();

    final emailConfirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.lock_reset_rounded, color: AppTheme.primary, size: 22),
          SizedBox(width: 10),
          Text('Forgot Password',
              style: TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        ]),
        content: Form(
          key: formKey1,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'We\'ll send a 6-digit OTP to verify your identity.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Registered Email',
                  prefixIcon: Icon(Icons.email_outlined, size: 20)),
              validator: (v) =>
              (v?.contains('@') == true) ? null : 'Enter a valid email',
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton.icon(
              onPressed: () {
                if (formKey1.currentState!.validate()) Navigator.pop(ctx, true);
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Send OTP'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary)),
        ],
      ),
    );

    if (emailConfirmed != true || !mounted) return;

    _showLoadingDialog('Sending OTP...');
    final sent = await auth.sendPasswordResetOtp(emailCtrl.text);
    if (mounted) Navigator.pop(context);

    if (!mounted) return;
    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Failed to send OTP.'),
        backgroundColor: AppTheme.error,
      ));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text('OTP sent to ${emailCtrl.text}'),
      ]),
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 4),
    ));

    final otpCtrl  = TextEditingController();
    final formKey2 = GlobalKey<FormState>();

    final otpConfirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.verified_user_rounded, color: AppTheme.primary, size: 22),
          SizedBox(width: 10),
          Text('Verify OTP',
              style: TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        ]),
        content: Form(
          key: formKey2,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                children: [
                  const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                  TextSpan(
                    text: emailCtrl.text,
                    style: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  letterSpacing: 10,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                  hintText: '------',
                  counterText: '',
                  prefixIcon: Icon(Icons.pin_outlined, size: 20)),
              validator: (v) => (v?.length == 6) ? null : 'Enter all 6 digits',
            ),
            const SizedBox(height: 10),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.timer_outlined, size: 13, color: AppTheme.textMuted),
              SizedBox(width: 4),
              Text('Valid for 10 minutes',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ]),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton.icon(
              onPressed: () {
                if (formKey2.currentState!.validate()) Navigator.pop(ctx, true);
              },
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
              label: const Text('Verify'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary)),
        ],
      ),
    );

    if (otpConfirmed != true || !mounted) return;

    final otpValid = auth.verifyOtp(otpCtrl.text);
    if (!mounted) return;
    if (!otpValid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Invalid OTP.'),
        backgroundColor: AppTheme.error,
      ));
      return;
    }

    final newPassCtrl   = TextEditingController();
    final confirmCtrl   = TextEditingController();
    final formKey3      = GlobalKey<FormState>();
    bool obscureNew     = true;
    bool obscureConfirm = true;

    final resetConfirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.lock_open_rounded, color: Colors.green, size: 22),
            SizedBox(width: 10),
            Text('New Password',
                style: TextStyle(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          ]),
          content: Form(
            key: formKey3,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10)),
                child: const Row(children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text('Identity verified! Set your new password.',
                      style: TextStyle(color: Colors.green, fontSize: 12)),
                ]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPassCtrl,
                obscureText: obscureNew,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscureNew
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textMuted, size: 20),
                      onPressed: () => setS(() => obscureNew = !obscureNew),
                    )),
                validator: (v) =>
                (v?.length ?? 0) >= 6 ? null : 'At least 6 characters',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmCtrl,
                obscureText: obscureConfirm,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textMuted, size: 20),
                      onPressed: () => setS(() => obscureConfirm = !obscureConfirm),
                    )),
                validator: (v) =>
                v == newPassCtrl.text ? null : 'Passwords do not match',
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel',
                    style: TextStyle(color: AppTheme.textMuted))),
            ElevatedButton.icon(
                onPressed: () {
                  if (formKey3.currentState!.validate()) Navigator.pop(ctx, true);
                },
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Reset Password'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary)),
          ],
        ),
      ),
    );

    if (resetConfirmed != true || !mounted) return;

    _showLoadingDialog('Resetting password...');
    final success = await auth.resetPassword(emailCtrl.text, newPassCtrl.text);
    if (mounted) Navigator.pop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Icon(
            success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            color: Colors.white, size: 18,
          ),
          const SizedBox(width: 8),
          Text(success
              ? 'Password reset successfully! Please sign in.'
              : auth.error ?? 'Something went wrong.'),
        ]),
        backgroundColor: success ? Colors.green.shade700 : AppTheme.error,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
                color: AppTheme.primary, strokeWidth: 2.5),
          ),
          const SizedBox(width: 16),
          Text(message,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
        backgroundColor: AppTheme.bg,
        body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // ── Header row: logo + language picker ──────────────────
                  Row(children: [
                    Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.accent]),
                            borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.accessibility_new_rounded,
                            color: Colors.white, size: 28)),
                    const SizedBox(width: 14),
                    const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AccessAlly AI',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700)),
                          Text('UGC 2022 Compliant',
                              style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ]),
                    const Spacer(),
                    // ── Language selector button ─────────────────────────
                    GestureDetector(
                      onTap: _showLanguagePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.surfaceBorder)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(_selectedLang.flag,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(_selectedLang.code.toUpperCase(),
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more_rounded,
                              color: AppTheme.textMuted, size: 16),
                        ]),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 48),
                  const Text('Sign in',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('Access your disability admission dashboard',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 28),

                  if (auth.error != null)
                    Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.error.withValues(alpha: 0.3))),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(auth.error!,
                                  style: const TextStyle(
                                      color: AppTheme.error, fontSize: 13))),
                        ])),

                  Form(
                      key: _formKey,
                      child: Column(children: [
                        _field(
                            _emailCtrl,
                            'Institutional Email',
                            'officer@university.edu.in',
                            Icons.email_outlined,
                                (v) => (v?.contains('@') == true)
                                ? null
                                : 'Enter a valid email',
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 14),
                        _field(
                            _passCtrl,
                            'Password',
                            '••••••••',
                            Icons.lock_outline_rounded,
                                (v) => (v?.length ?? 0) >= 6
                                ? null
                                : 'At least 6 characters',
                            obscure: _obscure,
                            suffix: IconButton(
                                icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppTheme.textMuted, size: 20),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure))),
                      ])),

                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text('Forgot password?',
                              style: TextStyle(
                                  color: AppTheme.primary, fontSize: 13)))),

                  const SizedBox(height: 4),
                  SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          child: auth.isLoading
                              ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                              : const Text('Sign In',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)))),

                  const SizedBox(height: 20),
                  Row(children: [
                    const Expanded(child: Divider(color: AppTheme.surfaceBorder)),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 13))),
                    const Expanded(child: Divider(color: AppTheme.surfaceBorder)),
                  ]),
                  const SizedBox(height: 20),

                  SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen())),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.surfaceBorder),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          child: const Text('Create Institution Account',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)))),

                  const SizedBox(height: 32),
                  Center(
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.accent.withValues(alpha: 0.3))),
                          child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    color: AppTheme.accent, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  // ignore: spell_check_configuration_errors
                                    'UGC 2022 · RPWD 2016 · NEP 2020',
                                    style: TextStyle(
                                        color: AppTheme.accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ]))),
                ],
              )),
        ));
  }

  Widget _field(
      TextEditingController ctrl,
      String label,
      String hint,
      IconData icon,
      String? Function(String?)? validator, {
        bool obscure = false,
        TextInputType? keyboardType,
        Widget? suffix,
      }) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
              controller: ctrl,
              obscureText: obscure,
              validator: validator,
              keyboardType: keyboardType,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
                  suffixIcon: suffix)),
        ]);
  }
}