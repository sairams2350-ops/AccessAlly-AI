// lib/utils/app_strings.dart
// All UI strings in supported languages

class AppStrings {
  final String languageCode;
  const AppStrings(this.languageCode);

  // ── App general ───────────────────────────────────────────────────────────
  String get appName       => _s('AccessAlly AI',    'AccessAlly AI',       'AccessAlly AI',       'AccessAlly AI',       'AccessAlly AI');
  String get ugcCompliant  => _s('UGC 2022 Compliant','UGC 2022 अनुपालन',   'UGC 2022 இணக்கமான',  'UGC 2022 అనుగుణంగా',  'UGC 2022 ಅನುಸರಣೆ');

  // ── Login Screen ──────────────────────────────────────────────────────────
  String get signIn           => _s('Sign in',           'साइन इन',            'உள்நுழைய',           'సైన్ ఇన్',           'ಸೈನ್ ಇನ್');
  String get signInSubtitle   => _s('Access your disability admission dashboard', 'अपने विकलांगता प्रवेश डैशबोर्ड तक पहुँचें', 'உங்கள் ஊனமுற்றோர் சேர்க்கை டாஷ்போர்டை அணுகவும்', 'మీ వికలాంగుల ప్రవేశ డాష్‌బోర్డ్‌ను యాక్సెస్ చేయండి', 'ನಿಮ್ಮ ಅಂಗವಿಕಲ ಪ್ರವೇಶ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಪ್ರವೇಶಿಸಿ');
  String get institutionalEmail => _s('Institutional Email', 'संस्थागत ईमेल',   'நிறுவன மின்னஞ்சல்', 'సంస్థ ఇమెయిల్',     'ಸಂಸ್ಥೆ ಇಮೇಲ್');
  String get password         => _s('Password',         'पासवर्ड',            'கடவுச்சொல்',         'పాస్‌వర్డ్',          'ಪಾಸ್‌ವರ್ಡ್');
  String get forgotPassword   => _s('Forgot password?', 'पासवर्ड भूल गए?',   'கடவுச்சொல் மறந்தீர்களா?', 'పాస్‌వర్డ్ మర్చిపోయారా?', 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ?');
  String get signInButton     => _s('Sign In',          'साइन इन करें',       'உள்நுழையுங்கள்',    'సైన్ ఇన్ చేయండి',   'ಸೈನ್ ಇನ್ ಮಾಡಿ');
  String get createAccount    => _s('Create Institution Account', 'संस्था खाता बनाएं', 'நிறுவன கணக்கை உருவாக்கவும்', 'సంస్థ ఖాతా సృష్టించండి', 'ಸಂಸ್ಥೆ ಖಾತೆ ರಚಿಸಿ');

  // ── Register Screen ───────────────────────────────────────────────────────
  String get institutionRegistration => _s('Institution Registration', 'संस्था पंजीकरण', 'நிறுவன பதிவு', 'సంస్థ నమోదు', 'ಸಂಸ್ಥೆ ನೋಂದಣಿ');
  String get fullName         => _s('Full Name',        'पूरा नाम',           'முழு பெயர்',         'పూర్తి పేరు',        'ಪೂರ್ಣ ಹೆಸರು');
  String get institutionName  => _s('Institution Name', 'संस्था का नाम',      'நிறுவனத்தின் பெயர்', 'సంస్థ పేరు',        'ಸಂಸ್ಥೆ ಹೆಸರು');
  String get officialEmail    => _s('Official Email',   'आधिकारिक ईमेल',     'அதிகாரப்பூர்வ மின்னஞ்சல்', 'అధికారిక ఇమెయిల్', 'ಅಧಿಕೃತ ಇಮೇಲ್');
  String get yourRole         => _s('Your Role',        'आपकी भूमिका',        'உங்கள் பாத்திரம்',   'మీ పాత్ర',           'ನಿಮ್ಮ ಪಾತ್ರ');
  String get sendVerificationOtp => _s('Send Verification OTP', 'सत्यापन OTP भेजें', 'சரிபார்ப்பு OTP அனுப்பவும்', 'ధృవీకరణ OTP పంపండి', 'ಪರಿಶೀಲನೆ OTP ಕಳುಹಿಸಿ');

  // ── Chat Screen ───────────────────────────────────────────────────────────
  String get newSession       => _s('New Session',      'नया सत्र',           'புதிய அமர்வு',       'కొత్త సెషన్',        'ಹೊಸ ಅಧಿವೇಶನ');
  String get myProfile        => _s('My Profile',       'मेरी प्रोफ़ाइल',    'என் சுயவிவரம்',      'నా ప్రొఫైల్',        'ನನ್ನ ಪ್ರೊಫೈಲ್');
  String get signOut          => _s('Sign Out',         'साइन आउट',          'வெளியேறு',           'సైన్ అవుట్',         'ಸೈನ್ ಔಟ್');
  String get askPlaceholder   => _s('Ask about disability accommodations...', 'विकलांगता आवास के बारे में पूछें...', 'ஊனமுற்றோர் வசதிகள் பற்றி கேளுங்கள்...', 'వికలాంగుల వసతి గురించి అడగండి...', 'ಅಂಗವಿಕಲ ವಸತಿ ಬಗ್ಗೆ ಕೇಳಿ...');

  // ── Profile Screen ────────────────────────────────────────────────────────
  String get accountDetails   => _s('Account Details',  'खाता विवरण',        'கணக்கு விவரங்கள்',   'ఖాతా వివరాలు',      'ಖಾತೆ ವಿವರಗಳು');
  String get compliance       => _s('Compliance',       'अनुपालन',           'இணக்கம்',            'అనుగుణ్యత',          'ಅನುಸರಣೆ');
  String get dangerZone       => _s('Danger Zone',      'खतरा क्षेत्र',      'ஆபத்து மண்டலம்',    'డేంజర్ జోన్',        'ಅಪಾಯ ವಲಯ');
  String get deleteAccount    => _s('Delete Account',   'खाता हटाएं',        'கணக்கை நீக்கவும்',   'ఖాతా తొలగించండి',   'ಖಾತೆ ಅಳಿಸಿ');
  String get languagePreference => _s('Language Preference', 'भाषा प्राथमिकता', 'மொழி விருப்பம்',  'భాషా ప్రాధాన్యత',   'ಭಾಷಾ ಆದ್ಯತೆ');
  String get selectLanguage   => _s('Select Language',  'भाषा चुनें',        'மொழியை தேர்ந்தெடுக்கவும்', 'భాష ఎంచుకోండి', 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ');
  String get appLanguage      => _s('App Language',     'ऐप भाषा',           'செயலி மொழி',         'యాప్ భాష',           'ಅಪ್ಲಿಕೇಶನ್ ಭಾಷೆ');

  // ── OTP dialogs ───────────────────────────────────────────────────────────
  String get sendOtp          => _s('Send OTP',         'OTP भेजें',          'OTP அனுப்பவும்',     'OTP పంపండి',         'OTP ಕಳುಹಿಸಿ');
  String get verifyOtp        => _s('Verify OTP',       'OTP सत्यापित करें',  'OTP சரிபார்க்கவும்', 'OTP ధృవీకరించండి',   'OTP ಪರಿಶೀಲಿಸಿ');
  String get otpSent          => _s('OTP sent! Check your email.', 'OTP भेजा! अपना ईमेल देखें।', 'OTP அனுப்பப்பட்டது! உங்கள் மின்னஞ்சலை சரிபார்க்கவும்.', 'OTP పంపబడింది! మీ ఇమెయిల్ తనిఖీ చేయండి.', 'OTP ಕಳುಹಿಸಲಾಗಿದೆ! ನಿಮ್ಮ ಇಮೇಲ್ ಪರಿಶೀಲಿಸಿ.');
  String get cancel           => _s('Cancel',           'रद्द करें',          'ரத்து செய்',         'రద్దు చేయండి',       'ರದ್ದು ಮಾಡಿ');

  // ── Error messages ────────────────────────────────────────────────────────
  String get enterValidEmail  => _s('Enter a valid email', 'एक वैध ईमेल दर्ज करें', 'சரியான மின்னஞ்சலை உள்ளிடவும்', 'చెల్లుబాటు అయ్యే ఇమెయిల్ నమోదు చేయండి', 'ಮಾನ್ಯ ಇಮೇಲ್ ನಮೂದಿಸಿ');
  String get atLeast6Chars    => _s('At least 6 characters', 'कम से कम 6 अक्षर', 'குறைந்தது 6 எழுத்துகள்', 'కనీసం 6 అక్షరాలు', 'ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳು');

  // ── Helper ────────────────────────────────────────────────────────────────
  String _s(String en, String hi, String ta, String te, String kn) {
    switch (languageCode) {
      case 'hi': return hi;
      case 'ta': return ta;
      case 'te': return te;
      case 'kn': return kn;
      default:   return en;
    }
  }
}