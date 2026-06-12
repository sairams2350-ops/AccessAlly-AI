import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  // ── Persisted state ────────────────────────────────────────────────────────
  String _langCode = 'en';
  String _langName = 'English';

  // ── Primary getters (used by chat_screen, login_screen, nvidia_service) ───
  String get langCode => _langCode;
  String get langName => _langName;

  // ── Alias getters (used by profile_screen & AppStrings) ───────────────────
  String get currentLanguageCode => _langCode;
  String get currentLanguageName => _langName;

  // ── Locale for MaterialApp ─────────────────────────────────────────────────
  Locale get locale => Locale(_langCode);

  // ── Static supported-language list (used by main.dart & profile_screen) ───
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English',    'native': 'English',    'flag': '🇬🇧'},
    {'code': 'hi', 'name': 'Hindi',      'native': 'हिन्दी',       'flag': '🇮🇳'},
    {'code': 'ta', 'name': 'Tamil',      'native': 'தமிழ்',        'flag': '🇮🇳'},
    {'code': 'te', 'name': 'Telugu',     'native': 'తెలుగు',       'flag': '🇮🇳'},
    {'code': 'kn', 'name': 'Kannada',    'native': 'ಕನ್ನಡ',        'flag': '🇮🇳'},
    {'code': 'ml', 'name': 'Malayalam',  'native': 'മലയാളം',      'flag': '🇮🇳'},
    {'code': 'mr', 'name': 'Marathi',    'native': 'मराठी',        'flag': '🇮🇳'},
    {'code': 'gu', 'name': 'Gujarati',   'native': 'ગુજરાતી',      'flag': '🇮🇳'},
    {'code': 'bn', 'name': 'Bengali',    'native': 'বাংলা',        'flag': '🇮🇳'},
    {'code': 'pa', 'name': 'Punjabi',    'native': 'ਪੰਜਾਬੀ',       'flag': '🇮🇳'},
    {'code': 'or', 'name': 'Odia',       'native': 'ଓଡ଼ିଆ',        'flag': '🇮🇳'},
    {'code': 'as', 'name': 'Assamese',   'native': 'অসমীয়া',      'flag': '🇮🇳'},
    {'code': 'ur', 'name': 'Urdu',       'native': 'اردو',         'flag': '🇮🇳'},
    {'code': 'ks', 'name': 'Kashmiri',   'native': 'كشميري',       'flag': '🇮🇳'},
    {'code': 'sd', 'name': 'Sindhi',     'native': 'سنڌي',         'flag': '🇮🇳'},
    {'code': 'sa', 'name': 'Sanskrit',   'native': 'संस्कृतम्',     'flag': '🇮🇳'},
    {'code': 'ne', 'name': 'Nepali',     'native': 'नेपाली',       'flag': '🇮🇳'},
    {'code': 'si', 'name': 'Sinhala',    'native': 'සිංහල',        'flag': '🇱🇰'},
    {'code': 'ar', 'name': 'Arabic',     'native': 'العربية',      'flag': '🇸🇦'},
    {'code': 'fr', 'name': 'French',     'native': 'Français',    'flag': '🇫🇷'},
    {'code': 'de', 'name': 'German',     'native': 'Deutsch',     'flag': '🇩🇪'},
    {'code': 'zh', 'name': 'Chinese',    'native': '中文',          'flag': '🇨🇳'},
    {'code': 'ja', 'name': 'Japanese',   'native': '日本語',         'flag': '🇯🇵'},
    {'code': 'ko', 'name': 'Korean',     'native': '한국어',         'flag': '🇰🇷'},
    {'code': 'es', 'name': 'Spanish',    'native': 'Español',     'flag': '🇪🇸'},
    {'code': 'pt', 'name': 'Portuguese', 'native': 'Português',   'flag': '🇧🇷'},
    {'code': 'ru', 'name': 'Russian',    'native': 'Русский',     'flag': '🇷🇺'},
  ];

  // ── Initialise from shared preferences ────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('lang_code') ?? 'en';
    final match = supportedLanguages.where((l) => l['code'] == saved);
    if (match.isNotEmpty) {
      _langCode = match.first['code']!;
      _langName = match.first['name']!;
    }
    notifyListeners();
  }

  // ── setLanguage ────────────────────────────────────────────────────────────
  Future<void> setLanguage(String code, [String? name]) async {
    _langCode = code;
    if (name != null && name.isNotEmpty) {
      _langName = name;
    } else {
      final match = supportedLanguages.where((l) => l['code'] == code);
      _langName = match.isNotEmpty ? match.first['name']! : code;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang_code', code);
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UI strings — all languages supported; English is the fallback.
  // ══════════════════════════════════════════════════════════════════════════

  // ── Chat screen ────────────────────────────────────────────────────────────
  String get inputHint => _t({
    'hi': 'विकलांगता सुविधाओं के बारे में पूछें...',
    'ta': 'இயலாமை வசதிகள் பற்றி கேளுங்கள்...',
    'te': 'వికలాంగుల సౌకర్యాల గురించి అడగండి...',
    'kn': 'ಅಂಗವಿಕಲತೆ ಸೌಲಭ್ಯಗಳ ಬಗ್ಗೆ ಕೇಳಿ...',
    'ml': 'വൈകല്യ സൗകര്യങ്ങളെ കുറിച്ച് ചോദിക്കൂ...',
    'mr': 'अपंगत्व सुविधांबद्दल विचारा...',
    'gu': 'વિકલાંગ સુવિધાઓ વિશે પૂછો...',
    'bn': 'প্রতিবন্ধী সুবিধা সম্পর্কে জিজ্ঞাসা করুন...',
    'pa': 'ਅਪਾਹਜਤਾ ਸਹੂਲਤਾਂ ਬਾਰੇ ਪੁੱਛੋ...',
    'ur': 'معذوری کی سہولیات کے بارے میں پوچھیں...',
    'ar': 'اسأل عن تسهيلات الإعاقة...',
    'fr': 'Posez une question sur les aménagements...',
    'de': 'Fragen Sie zu Behinderungsanpassungen...',
    'zh': '询问无障碍设施...',
    'ja': '障害者支援について質問する...',
    'ko': '장애 편의시설에 대해 질문하세요...',
    'es': 'Pregunta sobre adaptaciones por discapacidad...',
    'pt': 'Pergunte sobre acomodações para deficiência...',
    'ru': 'Спросите об услугах для инвалидов...',
  }, 'Ask about disability accommodations...');

  String get selectLanguage => _t({
    'hi': 'भाषा चुनें',
    'ta': 'மொழி தேர்ந்தெடுக்கவும்',
    'te': 'భాష ఎంచుకోండి',
    'kn': 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ',
    'ml': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
    'mr': 'भाषा निवडा',
    'gu': 'ભાષા પસંદ કરો',
    'bn': 'ভাষা নির্বাচন করুন',
    'pa': 'ਭਾਸ਼ਾ ਚੁਣੋ',
    'ur': 'زبان منتخب کریں',
    'ar': 'اختر اللغة',
    'fr': 'Choisir la langue',
    'de': 'Sprache wählen',
    'zh': '选择语言',
    'ja': '言語を選択',
    'ko': '언어 선택',
    'es': 'Seleccionar idioma',
    'pt': 'Selecionar idioma',
    'ru': 'Выбрать язык',
  }, 'Select Language');

  String get searchLanguage => _t({
    'hi': 'भाषा खोजें...',
    'ta': 'மொழி தேடுங்கள்...',
    'te': 'భాషను శోధించండి...',
    'kn': 'ಭಾಷೆ ಹುಡುಕಿ...',
    'ml': 'ഭാഷ തിരയുക...',
    'mr': 'भाषा शोधा...',
    'gu': 'ભાષા શોધો...',
    'bn': 'ভাষা অনুসন্ধান করুন...',
    'pa': 'ਭਾਸ਼ਾ ਖੋਜੋ...',
    'ur': 'زبان تلاش کریں...',
    'ar': 'ابحث عن اللغة...',
    'fr': 'Rechercher une langue...',
    'de': 'Sprache suchen...',
    'zh': '搜索语言...',
    'ja': '言語を検索...',
    'ko': '언어 검색...',
    'es': 'Buscar idioma...',
    'pt': 'Pesquisar idioma...',
    'ru': 'Поиск языка...',
  }, 'Search language...');

  String get newSession => _t({
    'hi': 'नया सत्र',
    'ta': 'புதிய அமர்வு',
    'te': 'కొత్త సెషన్',
    'kn': 'ಹೊಸ ಸೆಷನ್',
    'ml': 'പുതിയ സെഷൻ',
    'mr': 'नवीन सत्र',
    'gu': 'નવું સત્ર',
    'bn': 'নতুন সেশন',
    'pa': 'ਨਵਾਂ ਸੈਸ਼ਨ',
    'ur': 'نیا سیشن',
    'ar': 'جلسة جديدة',
    'fr': 'Nouvelle session',
    'de': 'Neue Sitzung',
    'zh': '新会话',
    'ja': '新しいセッション',
    'ko': '새 세션',
    'es': 'Nueva sesión',
    'pt': 'Nova sessão',
    'ru': 'Новая сессия',
  }, 'New Session');

  String get myProfile => _t({
    'hi': 'मेरी प्रोफ़ाइल',
    'ta': 'என் சுயவிவரம்',
    'te': 'నా ప్రొఫైల్',
    'kn': 'ನನ್ನ ಪ್ರೊಫೈಲ್',
    'ml': 'എന്റെ പ്രൊഫൈൽ',
    'mr': 'माझे प्रोफाइल',
    'gu': 'મારી પ્રોફાઇલ',
    'bn': 'আমার প্রোফাইল',
    'pa': 'ਮੇਰੀ ਪ੍ਰੋਫਾਈਲ',
    'ur': 'میری پروفائل',
    'ar': 'ملفي الشخصي',
    'fr': 'Mon profil',
    'de': 'Mein Profil',
    'zh': '我的资料',
    'ja': 'マイプロフィール',
    'ko': '내 프로필',
    'es': 'Mi perfil',
    'pt': 'Meu perfil',
    'ru': 'Мой профиль',
  }, 'My Profile');

  String get signOut => _t({
    'hi': 'साइन आउट',
    'ta': 'வெளியேறு',
    'te': 'సైన్ అవుట్',
    'kn': 'ಸೈನ್ ಔಟ್',
    'ml': 'സൈൻ ഔട്ട്',
    'mr': 'साइन आउट',
    'gu': 'સાઇન આઉટ',
    'bn': 'সাইন আউট',
    'pa': 'ਸਾਈਨ ਆਊਟ',
    'ur': 'سائن آؤٹ',
    'ar': 'تسجيل الخروج',
    'fr': 'Se déconnecter',
    'de': 'Abmelden',
    'zh': '退出登录',
    'ja': 'サインアウト',
    'ko': '로그아웃',
    'es': 'Cerrar sesión',
    'pt': 'Sair',
    'ru': 'Выйти',
  }, 'Sign Out');

  String get uploadFailedPrefix => _t({
    'hi': 'अपलोड विफल: ',
    'ta': 'பதிவேற்றம் தோல்வியடைந்தது: ',
    'te': 'అప్‌లోడ్ విఫలమైంది: ',
    'kn': 'ಅಪ್‌ಲೋಡ್ ವಿಫಲವಾಗಿದೆ: ',
    'ml': 'അപ്‌ലോഡ് പരാജയപ്പെട്ടു: ',
    'mr': 'अपलोड अयशस्वी: ',
    'gu': 'અપલોડ નિષ્ફળ: ',
    'bn': 'আপলোড ব্যর্থ: ',
    'pa': 'ਅਪਲੋਡ ਅਸਫਲ: ',
    'ur': 'اپلوڈ ناکام: ',
    'ar': 'فشل الرفع: ',
    'fr': 'Échec du téléchargement : ',
    'de': 'Upload fehlgeschlagen: ',
    'zh': '上传失败：',
    'ja': 'アップロード失敗：',
    'ko': '업로드 실패: ',
    'es': 'Error al subir: ',
    'pt': 'Falha no upload: ',
    'ru': 'Ошибка загрузки: ',
  }, 'Upload failed: ');

  // ── Document upload sheet ──────────────────────────────────────────────────
  String get uploadSheetTitle => _t({
    'hi': 'दस्तावेज़ अपलोड करें',
    'ta': 'ஆவணம் பதிவேற்றவும்',
    'te': 'పత్రాన్ని అప్‌లోడ్ చేయండి',
    'kn': 'ದಾಖಲೆ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ',
    'ml': 'രേഖ അപ്‌ലോഡ് ചെയ്യുക',
    'mr': 'दस्तऐवज अपलोड करा',
    'gu': 'દસ્તાવેજ અપલોડ કરો',
    'bn': 'নথি আপলোড করুন',
    'pa': 'ਦਸਤਾਵੇਜ਼ ਅਪਲੋਡ ਕਰੋ',
    'ur': 'دستاویز اپلوڈ کریں',
    'ar': 'رفع مستند',
    'fr': 'Télécharger un document',
    'de': 'Dokument hochladen',
    'zh': '上传文件',
    'ja': '書類をアップロード',
    'ko': '문서 업로드',
    'es': 'Subir documento',
    'pt': 'Enviar documento',
    'ru': 'Загрузить документ',
  }, 'Upload Document');

  String get uploadSheetSubtitle => _t({
    'hi': 'एक विकल्प चुनें',
    'ta': 'ஒரு விருப்பத்தைத் தேர்ந்தெடுக்கவும்',
    'te': 'ఒక ఎంపికను ఎంచుకోండి',
    'kn': 'ಒಂದು ಆಯ್ಕೆಯನ್ನು ಆರಿಸಿ',
    'ml': 'ഒരു ഓപ്ഷൻ തിരഞ്ഞെടുക്കുക',
    'mr': 'एक पर्याय निवडा',
    'gu': 'એક વિકલ્પ પસંદ કરો',
    'bn': 'একটি বিকল্প বেছে নিন',
    'pa': 'ਇੱਕ ਵਿਕਲਪ ਚੁਣੋ',
    'ur': 'ایک آپشن منتخب کریں',
    'ar': 'اختر خياراً',
    'fr': 'Choisissez une option',
    'de': 'Wählen Sie eine Option',
    'zh': '选择一个选项',
    'ja': 'オプションを選んでください',
    'ko': '옵션을 선택하세요',
    'es': 'Elige una opción',
    'pt': 'Escolha uma opção',
    'ru': 'Выберите вариант',
  }, 'Choose an option to upload your document');

  String get uploadFromFiles => _t({
    'hi': 'फ़ाइलों से अपलोड करें',
    'ta': 'கோப்புகளிலிருந்து பதிவேற்றவும்',
    'te': 'ఫైళ్ళ నుండి అప్‌లోడ్ చేయండి',
    'kn': 'ಫೈಲ್‌ಗಳಿಂದ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ',
    'ml': 'ഫയലുകളിൽ നിന്ന് അപ്‌ലോഡ് ചെയ്യുക',
    'mr': 'फाईल्समधून अपलोड करा',
    'gu': 'ફાઇલ્સમાંથી અપલોડ કરો',
    'bn': 'ফাইল থেকে আপলোড করুন',
    'pa': 'ਫਾਈਲਾਂ ਤੋਂ ਅਪਲੋਡ ਕਰੋ',
    'ur': 'فائلوں سے اپلوڈ کریں',
    'ar': 'رفع من الملفات',
    'fr': 'Télécharger depuis les fichiers',
    'de': 'Aus Dateien hochladen',
    'zh': '从文件上传',
    'ja': 'ファイルからアップロード',
    'ko': '파일에서 업로드',
    'es': 'Subir desde archivos',
    'pt': 'Enviar de arquivos',
    'ru': 'Загрузить из файлов',
  }, 'Upload from Files');

  String get uploadFromCamera => _t({
    'hi': 'फ़ोटो लें',
    'ta': 'புகைப்படம் எடு',
    'te': 'ఫోటో తీయండి',
    'kn': 'ಫೋಟೋ ತೆಗೆಯಿರಿ',
    'ml': 'ഫോട്ടോ എടുക്കുക',
    'mr': 'फोटो काढा',
    'gu': 'ફોટો લો',
    'bn': 'ছবি তুলুন',
    'pa': 'ਫੋਟੋ ਲਓ',
    'ur': 'تصویر لیں',
    'ar': 'التقط صورة',
    'fr': 'Prendre une photo',
    'de': 'Foto aufnehmen',
    'zh': '拍照',
    'ja': '写真を撮る',
    'ko': '사진 찍기',
    'es': 'Tomar una foto',
    'pt': 'Tirar uma foto',
    'ru': 'Сделать фото',
  }, 'Take a Photo');

  String get uploadFromGallery => _t({
    'hi': 'गैलरी से चुनें',
    'ta': 'கேலரியிலிருந்து தேர்ந்தெடுக்கவும்',
    'te': 'గ్యాలరీ నుండి ఎంచుకోండి',
    'kn': 'ಗ್ಯಾಲರಿಯಿಂದ ಆರಿಸಿ',
    'ml': 'ഗ്യാലറിയിൽ നിന്ന് തിരഞ്ഞെടുക്കുക',
    'mr': 'गॅलरीमधून निवडा',
    'gu': 'ગૅલેરીમાંથી પસંદ કરો',
    'bn': 'গ্যালারি থেকে বেছে নিন',
    'pa': 'ਗੈਲਰੀ ਤੋਂ ਚੁਣੋ',
    'ur': 'گیلری سے منتخب کریں',
    'ar': 'اختر من المعرض',
    'fr': 'Choisir depuis la galerie',
    'de': 'Aus Galerie auswählen',
    'zh': '从相册选择',
    'ja': 'ギャラリーから選ぶ',
    'ko': '갤러리에서 선택',
    'es': 'Elegir de la galería',
    'pt': 'Escolher da galeria',
    'ru': 'Выбрать из галереи',
  }, 'Choose from Gallery');

  String get uploadSupportedFormats => _t({
    'hi': 'समर्थित: PDF, JPG, PNG, DOCX',
    'ta': 'ஆதரிக்கப்படுகின்றன: PDF, JPG, PNG, DOCX',
    'te': 'మద్దతు ఉన్నవి: PDF, JPG, PNG, DOCX',
    'kn': 'ಬೆಂಬಲಿತ: PDF, JPG, PNG, DOCX',
    'ml': 'പിന്തുണ: PDF, JPG, PNG, DOCX',
    'mr': 'समर्थित: PDF, JPG, PNG, DOCX',
    'gu': 'સમર્થિત: PDF, JPG, PNG, DOCX',
    'bn': 'সমর্থিত: PDF, JPG, PNG, DOCX',
    'pa': 'ਸਮਰਥਿਤ: PDF, JPG, PNG, DOCX',
    'ur': 'معاون: PDF, JPG, PNG, DOCX',
    'ar': 'الصيغ المدعومة: PDF, JPG, PNG, DOCX',
    'fr': 'Formats supportés : PDF, JPG, PNG, DOCX',
    'de': 'Unterstützte Formate: PDF, JPG, PNG, DOCX',
    'zh': '支持格式：PDF, JPG, PNG, DOCX',
    'ja': '対応形式：PDF, JPG, PNG, DOCX',
    'ko': '지원 형식: PDF, JPG, PNG, DOCX',
    'es': 'Formatos admitidos: PDF, JPG, PNG, DOCX',
    'pt': 'Formatos suportados: PDF, JPG, PNG, DOCX',
    'ru': 'Форматы: PDF, JPG, PNG, DOCX',
  }, 'Supported formats: PDF, JPG, PNG, DOCX');

  String get uploadCancel => _t({
    'hi': 'रद्द करें',
    'ta': 'ரத்து செய்',
    'te': 'రద్దు చేయండి',
    'kn': 'ರದ್ದು ಮಾಡಿ',
    'ml': 'റദ്ദാക്കുക',
    'mr': 'रद्द करा',
    'gu': 'રદ કરો',
    'bn': 'বাতিল করুন',
    'pa': 'ਰੱਦ ਕਰੋ',
    'ur': 'منسوخ کریں',
    'ar': 'إلغاء',
    'fr': 'Annuler',
    'de': 'Abbrechen',
    'zh': '取消',
    'ja': 'キャンセル',
    'ko': '취소',
    'es': 'Cancelar',
    'pt': 'Cancelar',
    'ru': 'Отмена',
  }, 'Cancel');

  // ── Quick-action chips ─────────────────────────────────────────────────────
  String get chipUdidCard => _t({
    'hi': 'UDID कार्ड कैसे पाएं',
    'ta': 'UDID அட்டை எப்படி பெறுவது',
    'te': 'UDID కార్డ్ ఎలా పొందాలి',
    'kn': 'UDID ಕಾರ್ಡ್ ಹೇಗೆ ಪಡೆಯಬೇಕು',
    'ml': 'UDID കാർഡ് എങ്ങനെ നേടാം',
    'mr': 'UDID कार्ड कसे मिळवायचे',
    'gu': 'UDID કાર્ડ કેવી રીતે મેળવવું',
    'bn': 'UDID কার্ড কীভাবে পাবেন',
    'pa': 'UDID ਕਾਰਡ ਕਿਵੇਂ ਪ੍ਰਾਪਤ ਕਰੀਏ',
    'ur': 'UDID کارڈ کیسے حاصل کریں',
    'ar': 'كيفية الحصول على بطاقة UDID',
    'fr': 'Comment obtenir une carte UDID',
    'de': 'Wie bekomme ich eine UDID-Karte',
    'zh': '如何申请UDID卡',
    'ja': 'UDIDカードの取得方法',
    'ko': 'UDID 카드 신청 방법',
    'es': 'Cómo obtener una tarjeta UDID',
    'pt': 'Como obter um cartão UDID',
    'ru': 'Как получить карту UDID',
  }, 'UDID Card');

  String get chipSchemes => _t({
    'hi': 'विकलांगता योजनाएं',
    'ta': 'மாற்றுத்திறன் திட்டங்கள்',
    'te': 'వికలాంగుల పథకాలు',
    'kn': 'ಅಂಗವಿಕಲತೆ ಯೋಜನೆಗಳು',
    'ml': 'വൈകല്യ പദ്ധതികൾ',
    'mr': 'अपंगत्व योजना',
    'gu': 'વિકલાંગ યોજનાઓ',
    'bn': 'প্রতিবন্ধী প্রকল্প',
    'pa': 'ਅਪਾਹਜਤਾ ਯੋਜਨਾਵਾਂ',
    'ur': 'معذوری اسکیمیں',
    'ar': 'مخططات الإعاقة',
    'fr': 'Programmes handicap',
    'de': 'Behinderungsprogramme',
    'zh': '残障计划',
    'ja': '障害者支援制度',
    'ko': '장애인 제도',
    'es': 'Programas de discapacidad',
    'pt': 'Programas de deficiência',
    'ru': 'Программы для инвалидов',
  }, 'Disability Schemes');

  String get chipRights => _t({
    'hi': 'RPWD अधिनियम अधिकार',
    'ta': 'RPWD சட்டம் உரிமைகள்',
    'te': 'RPWD చట్టం హక్కులు',
    'kn': 'RPWD ಕಾಯ್ದೆ ಹಕ್ಕುಗಳು',
    'ml': 'RPWD നിയമ അവകാശങ്ങൾ',
    'mr': 'RPWD कायदा अधिकार',
    'gu': 'RPWD અધિનિયમ અધિકારો',
    'bn': 'RPWD আইনের অধিকার',
    'pa': 'RPWD ਐਕਟ ਅਧਿਕਾਰ',
    'ur': 'RPWD ایکٹ حقوق',
    'ar': 'حقوق قانون RPWD',
    'fr': 'Droits loi RPWD',
    'de': 'RPWD-Gesetz Rechte',
    'zh': 'RPWD法律权利',
    'ja': 'RPWD法の権利',
    'ko': 'RPWD법 권리',
    'es': 'Derechos Ley RPWD',
    'pt': 'Direitos Lei RPWD',
    'ru': 'Права по закону RPWD',
  }, 'Rights (RPWD Act)');

  String get chipNearbyHelp => _t({
    'hi': 'नज़दीकी सहायता केंद्र',
    'ta': 'அருகிலுள்ள உதவி மையங்கள்',
    'te': 'సమీప సహాయ కేంద్రాలు',
    'kn': 'ಹತ್ತಿರದ ಸಹಾಯ ಕೇಂದ್ರಗಳು',
    'ml': 'സമീപ സഹായ കേന്ദ്രങ്ങൾ',
    'mr': 'जवळील मदत केंद्रे',
    'gu': 'નજીકના સહાય કેન્દ્રો',
    'bn': 'কাছের সাহায্য কেন্দ্র',
    'pa': 'ਨੇੜੇ ਦੇ ਸਹਾਇਤਾ ਕੇਂਦਰ',
    'ur': 'قریبی مدد مراکز',
    'ar': 'مراكز المساعدة القريبة',
    'fr': 'Centres d\'aide proches',
    'de': 'Hilfe in der Nähe',
    'zh': '附近帮助中心',
    'ja': '近くの支援センター',
    'ko': '근처 도움 센터',
    'es': 'Centros de ayuda cercanos',
    'pt': 'Centros de ajuda próximos',
    'ru': 'Ближайшие центры помощи',
  }, 'Nearby Help Centers');

  String get chipPensionBenefits => _t({
    'hi': 'पेंशन और लाभ',
    'ta': 'ஓய்வூதியம் மற்றும் நலன்கள்',
    'te': 'పెన్షన్ మరియు ప్రయోజనాలు',
    'kn': 'ಪಿಂಚಣಿ ಮತ್ತು ಪ್ರಯೋಜನಗಳು',
    'ml': 'പെൻഷൻ & ആനുകൂല്യങ്ങൾ',
    'mr': 'पेन्शन आणि फायदे',
    'gu': 'પેન્શન અને લાભ',
    'bn': 'পেনশন ও সুবিধা',
    'pa': 'ਪੈਨਸ਼ਨ ਅਤੇ ਲਾਭ',
    'ur': 'پنشن اور فوائد',
    'ar': 'المعاش والمزايا',
    'fr': 'Pension et avantages',
    'de': 'Rente und Leistungen',
    'zh': '养老金与福利',
    'ja': '年金と給付',
    'ko': '연금 및 혜택',
    'es': 'Pensión y beneficios',
    'pt': 'Pensão e benefícios',
    'ru': 'Пенсия и льготы',
  }, 'Pension & Benefits');

  String get chipEducation => _t({
    'hi': 'शिक्षा सहायता',
    'ta': 'கல்வி ஆதரவு',
    'te': 'విద్యా మద్దతు',
    'kn': 'ಶಿಕ್ಷಣ ಬೆಂಬಲ',
    'ml': 'വിദ്യാഭ്യാസ പിന്തുണ',
    'mr': 'शिक्षण सहाय्य',
    'gu': 'શૈક્ષણિક સહાય',
    'bn': 'শিক্ষা সহায়তা',
    'pa': 'ਸਿੱਖਿਆ ਸਹਾਇਤਾ',
    'ur': 'تعلیمی مدد',
    'ar': 'دعم التعليم',
    'fr': 'Soutien éducatif',
    'de': 'Bildungsunterstützung',
    'zh': '教育支持',
    'ja': '教育サポート',
    'ko': '교육 지원',
    'es': 'Apoyo educativo',
    'pt': 'Apoio educacional',
    'ru': 'Образовательная поддержка',
  }, 'Education Support');

  // ── Internal helper ────────────────────────────────────────────────────────
  String _t(Map<String, String> t, String fallback) =>
      t[_langCode] ?? fallback;
}
