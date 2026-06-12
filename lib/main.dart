import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/document_service.dart';
import 'services/language_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load persisted language before first frame.
  final languageService = LanguageService();
  await languageService.init();
  runApp(AccessAllyApp(languageService: languageService));
}

class AccessAllyApp extends StatelessWidget {
  final LanguageService languageService;
  const AccessAllyApp({super.key, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
        // Reuse the already-initialised instance so the persisted language
        // is available from the very first frame.
        ChangeNotifierProvider.value(value: languageService),
        Provider(create: (_) => DocumentService()),
      ],
      child: Consumer<LanguageService>(
        builder: (context, lang, _) => MaterialApp(
          title: 'AccessAlly AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,

          // ── Localization ────────────────────────────────────────────────
          locale: lang.locale,
          supportedLocales: LanguageService.supportedLanguages
              .map((l) => Locale(l['code']!))
              .toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          home: const SplashScreen(),
          routes: {
            '/login':   (_) => const LoginScreen(),
            '/chat':    (_) => const ChatScreen(),
            '/profile': (_) => const ProfileScreen(),
          },
        ),
      ),
    );
  }
}