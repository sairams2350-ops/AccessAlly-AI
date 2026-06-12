import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

/// Local Auth Service — uses SharedPreferences (no Firebase needed).
/// Stores users as JSON on device. Works on web, Android, Windows, etc.
class AuthService extends ChangeNotifier {
  static const _kUsers    = 'aa_users';
  static const _kLoggedIn = 'aa_logged_in_uid';

  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _error;

  // ── OTP state (in-memory only) ────────────────────────────────────────────
  String?   _pendingOtp;
  String?   _pendingEmail;
  DateTime? _otpExpiry;

  // ── Sign-in OTP state ─────────────────────────────────────────────────────
  String?               _pendingSignInOtp;
  DateTime?             _signInOtpExpiry;
  Map<String, dynamic>? _pendingSignInUser;
  String?               _pendingSignInUid;

  // ── Registration OTP state ────────────────────────────────────────────────
  String?   _pendingRegOtp;
  String?   _pendingRegEmail;
  DateTime? _regOtpExpiry;

  Map<String, dynamic>? get user            => _currentUser;
  bool                   get isLoading       => _isLoading;
  String?                get error           => _error;
  bool                   get isAuthenticated => _currentUser != null;
  String?                get displayName     => _currentUser?['displayName'];
  String?                get email           => _currentUser?['email'];
  String?                get institution     => _currentUser?['institution'];
  String?                get role            => _currentUser?['role'];
  String?                get uid             => _currentUser?['uid'];

  // ── EmailJS config ─────────────────────────────────────────────────────────
  static const _emailjsServiceId  = 'service_abc1234';   // ← your Service ID
  static const _emailjsTemplateId = 'template_nxil00i';  // ← your Template ID
  static const _emailjsPublicKey  = 'PVgtC4XPSQOU2-PA_'; // ← your Public Key

  AuthService() { _restoreSession(); }

  // ── Restore session on app launch ─────────────────────────────────────────
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final uid   = prefs.getString(_kLoggedIn);
    if (uid == null) return;
    final users = _loadUsers(prefs);
    if (users.containsKey(uid)) {
      _currentUser = Map<String, dynamic>.from(users[uid]);
      notifyListeners();
    }
  }

  // ── Sign In Step 1: Verify credentials & send OTP ─────────────────────────
  Future<bool> signInWithEmail(String email, String password) async {
    _set(loading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    final entry = users.entries.where((e) =>
    (e.value['email'] as String).toLowerCase() == email.trim().toLowerCase()
    ).firstOrNull;

    if (entry == null) return _fail('No account found with this email.');
    if (entry.value['password'] != _hash(password)) {
      return _fail('Incorrect password. Please try again.');
    }

    // Credentials valid — generate & send sign-in OTP
    final otp = (100000 + Random().nextInt(900000)).toString();
    _pendingSignInOtp   = otp;
    _pendingSignInUser  = Map<String, dynamic>.from(entry.value);
    _pendingSignInUid   = entry.key;
    _signInOtpExpiry    = DateTime.now().add(const Duration(minutes: 10));

    final sent = await _sendOtp(
      toEmail:     email.trim(),
      toName:      entry.value['displayName'] ?? 'User',
      otp:         otp,
      subjectHint: 'Sign-In Verification',
    );

    if (!sent) return false;

    _set(loading: false);
    return true;
  }

  // ── Sign In Step 2: Verify OTP and complete login ─────────────────────────
  Future<bool> verifySignInOtp(String enteredOtp) async {
    if (_pendingSignInOtp == null || _signInOtpExpiry == null) {
      return _fail('No sign-in OTP found. Please try again.');
    }
    if (DateTime.now().isAfter(_signInOtpExpiry!)) {
      _pendingSignInOtp = null;
      return _fail('OTP has expired. Please sign in again.');
    }
    if (enteredOtp.trim() != _pendingSignInOtp) {
      return _fail('Incorrect OTP. Please check your email.');
    }

    // OTP valid — complete sign in
    _set(loading: true, error: null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLoggedIn, _pendingSignInUid!);
    _currentUser = _pendingSignInUser;

    // Clear sign-in OTP state
    _pendingSignInOtp  = null;
    _pendingSignInUser = null;
    _pendingSignInUid  = null;
    _signInOtpExpiry   = null;

    _set(loading: false);
    return true;
  }

  // ── Register Step 1: Check email availability & send OTP ──────────────────
  Future<bool> sendRegistrationOtp({
    required String email,
    required String displayName,
  }) async {
    _set(loading: true, error: null);

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    final exists = users.values.any((u) =>
    (u['email'] as String).toLowerCase() == email.trim().toLowerCase());
    if (exists) return _fail('An account with this email already exists.');

    final otp = (100000 + Random().nextInt(900000)).toString();
    _pendingRegOtp   = otp;
    _pendingRegEmail = email.trim().toLowerCase();
    _regOtpExpiry    = DateTime.now().add(const Duration(minutes: 10));

    final sent = await _sendOtp(
      toEmail:     email.trim(),
      toName:      displayName,
      otp:         otp,
      subjectHint: 'Email Verification',
    );

    if (!sent) return false;

    _set(loading: false);
    return true;
  }

  // ── Register Step 2: Verify OTP & create account ──────────────────────────
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String institution,
    required String role,
    required String otp,
  }) async {
    // Validate the registration OTP first
    if (_pendingRegOtp == null || _regOtpExpiry == null) {
      return _fail('No registration OTP found. Please try again.');
    }
    if (DateTime.now().isAfter(_regOtpExpiry!)) {
      _pendingRegOtp = null;
      return _fail('OTP has expired. Please request a new one.');
    }
    if (otp.trim() != _pendingRegOtp) {
      return _fail('Incorrect OTP. Please check your email.');
    }

    _set(loading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    // Double-check email uniqueness (race-condition guard)
    final exists = users.values.any((u) =>
    (u['email'] as String).toLowerCase() == email.trim().toLowerCase());
    if (exists) return _fail('An account with this email already exists.');

    final uid  = DateTime.now().millisecondsSinceEpoch.toString();
    final user = {
      'uid':         uid,
      'email':       email.trim(),
      'displayName': displayName,
      'institution': institution,
      'role':        role,
      'password':    _hash(password),
      'createdAt':   DateTime.now().toIso8601String(),
    };

    users[uid] = user;
    await prefs.setString(_kUsers, jsonEncode(users));
    await prefs.setString(_kLoggedIn, uid);
    _currentUser = Map<String, dynamic>.from(user);

    // Clear registration OTP state
    _pendingRegOtp   = null;
    _pendingRegEmail = null;
    _regOtpExpiry    = null;

    _set(loading: false);
    return true;
  }

  // ── Password Reset Step 1: Send OTP ───────────────────────────────────────
  Future<bool> sendPasswordResetOtp(String email) async {
    _set(loading: true, error: null);

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    final entry = users.entries.where((e) =>
    (e.value['email'] as String).toLowerCase() == email.trim().toLowerCase()
    ).firstOrNull;

    if (entry == null) return _fail('No account found with this email.');

    final otp = (100000 + Random().nextInt(900000)).toString();
    _pendingOtp   = otp;
    _pendingEmail = email.trim().toLowerCase();
    _otpExpiry    = DateTime.now().add(const Duration(minutes: 10));

    final sent = await _sendOtp(
      toEmail:     email.trim(),
      toName:      entry.value['displayName'] ?? 'User',
      otp:         otp,
      subjectHint: 'Password Reset',
    );

    if (!sent) return false;

    _set(loading: false);
    return true;
  }

  // ── Password Reset Step 2: Verify OTP ─────────────────────────────────────
  bool verifyOtp(String enteredOtp) {
    if (_pendingOtp == null || _otpExpiry == null) {
      _set(error: 'No OTP request found. Please try again.');
      return false;
    }
    if (DateTime.now().isAfter(_otpExpiry!)) {
      _pendingOtp = null;
      _set(error: 'OTP has expired. Please request a new one.');
      return false;
    }
    if (enteredOtp.trim() != _pendingOtp) {
      _set(error: 'Incorrect OTP. Please check your email.');
      return false;
    }
    _error = null;
    notifyListeners();
    return true;
  }

  // ── Password Reset Step 3: Save new password ──────────────────────────────
  Future<bool> resetPassword(String email, String newPassword) async {
    _set(loading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    final entry = users.entries.where((e) =>
    (e.value['email'] as String).toLowerCase() == email.trim().toLowerCase()
    ).firstOrNull;

    if (entry == null) return _fail('No account found with this email.');

    users[entry.key]['password'] = _hash(newPassword);
    await prefs.setString(_kUsers, jsonEncode(users));

    _pendingOtp   = null;
    _pendingEmail = null;
    _otpExpiry    = null;

    _set(loading: false);
    return true;
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedIn);
    _currentUser = null;
    notifyListeners();
  }


  // ── Delete Account ─────────────────────────────────────────────────────────
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return _fail('No user is signed in.');
    _set(loading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = _loadUsers(prefs);
      final uidToDelete = _currentUser!['uid'] as String?;
      if (uidToDelete != null) users.remove(uidToDelete);
      await prefs.setString(_kUsers, jsonEncode(users));
      await prefs.remove(_kLoggedIn);
      _currentUser = null;
      _set(loading: false);
      return true;
    } catch (e) {
      return _fail('Failed to delete account: ${e.toString()}');
    }
  }

  // ── Shared OTP sender ─────────────────────────────────────────────────────
  Future<bool> _sendOtp({
    required String toEmail,
    required String toName,
    required String otp,
    required String subjectHint,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id':  _emailjsServiceId,
          'template_id': _emailjsTemplateId,
          'user_id':     _emailjsPublicKey,
          'template_params': {
            'to_email':     toEmail,
            'to_name':      toName,
            'otp_code':     otp,
            'app_name':     'AccessAlly AI',
            'subject_hint': subjectHint,
          },
        }),
      );

      if (response.statusCode != 200) {
        return _fail('EmailJS error ${response.statusCode}: ${response.body}');
      }
      return true;
    } catch (e) {
      return _fail('Network error: ${e.toString()}');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Map<String, dynamic> _loadUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_kUsers);
    if (raw == null) return {};
    try { return Map<String, dynamic>.from(jsonDecode(raw)); }
    catch (_) { return {}; }
  }

  String _hash(String input) {
    var h = 0;
    for (final c in input.codeUnits) { h = (h * 31 + c) & 0x7fffffff; }
    return h.toRadixString(16);
  }

  bool _fail(String msg) { _set(loading: false, error: msg); return false; }

  void _set({bool? loading, String? error}) {
    if (loading != null) _isLoading = loading;
    _error = error;
    notifyListeners();
  }
}