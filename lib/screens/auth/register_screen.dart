import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _nameCtrl        = TextEditingController();
  final _institutionCtrl = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passCtrl        = TextEditingController();
  String _role           = 'officer';
  bool   _obscure        = true;

  static const _roles = {
    'officer': 'Admission Officer',
    'admin':   'Institution Admin',
    'viewer':  'Management Viewer',
  };

  @override
  void dispose() {
    _nameCtrl.dispose(); _institutionCtrl.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();

    // Step 1: Send OTP to the provided email
    _showLoadingDialog('Sending verification OTP...');
    final sent = await auth.sendRegistrationOtp(
      email:       _emailCtrl.text,
      displayName: _nameCtrl.text,
    );
    if (mounted) Navigator.pop(context); // dismiss loading

    if (!mounted) return;
    if (!sent) return; // error shown via auth.error banner

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text('OTP sent to ${_emailCtrl.text}'),
      ]),
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 4),
    ));

    // Step 2: Show OTP dialog
    final otpCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final otpConfirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.verified_user_rounded, color: AppTheme.primary, size: 22),
          SizedBox(width: 10),
          Text('Verify Email',
              style: TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        ]),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
              icon: const Icon(Icons.how_to_reg_rounded, size: 16),
              label: const Text('Verify & Register'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary)),
        ],
      ),
    );

    if (otpConfirmed != true || !mounted) return;

    // Step 3: Complete registration
    _showLoadingDialog('Creating your account...');
    final success = await auth.registerWithEmail(
      email:       _emailCtrl.text,
      password:    _passCtrl.text,
      displayName: _nameCtrl.text,
      institution: _institutionCtrl.text,
      role:        _role,
      otp:         otpCtrl.text,
    );
    if (mounted) Navigator.pop(context); // dismiss loading

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
        appBar: AppBar(title: const Text('Create Account'), backgroundColor: AppTheme.bg),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Institution Registration',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      const Text('Create an account for your higher education institution',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 24),

                      if (auth.error != null)
                        Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: AppTheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.error.withOpacity(0.3))),
                            child: Text(auth.error!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),

                      _f(_nameCtrl, 'Full Name', 'Dr. Priya Sharma', Icons.person_outline,
                              (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                      _f(_institutionCtrl, 'Institution Name', 'e.g., IIT Delhi / Delhi University',
                          Icons.school_outlined, (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                      _f(_emailCtrl, 'Official Email', 'name@institution.edu.in', Icons.email_outlined,
                              (v) => v!.contains('@') ? null : 'Enter valid email',
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _f(_passCtrl, 'Password', '••••••••', Icons.lock_outline_rounded,
                              (v) => (v?.length ?? 0) >= 6 ? null : 'Min 6 characters',
                          obscure: _obscure,
                          suffix: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppTheme.textMuted, size: 20),
                              onPressed: () => setState(() => _obscure = !_obscure))),
                      const SizedBox(height: 12),

                      // Role Selector
                      const Text('Your Role',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.surfaceBorder)),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                  value: _role, isExpanded: true,
                                  dropdownColor: AppTheme.surfaceElevated,
                                  style: const TextStyle(color: AppTheme.textPrimary),
                                  items: _roles.entries.map((e) =>
                                      DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                                  onChanged: (v) => setState(() => _role = v!)))),

                      const SizedBox(height: 28),
                      SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              child: auth.isLoading
                                  ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : const Text('Create Account',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
                    ])))));
  }

  Widget _f(TextEditingController c, String label, String hint, IconData icon,
      String? Function(String?)? v, {bool obscure = false, TextInputType? keyboardType, Widget? suffix}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextFormField(
          controller: c, obscureText: obscure, validator: v,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
              suffixIcon: suffix)),
    ]);
  }
}