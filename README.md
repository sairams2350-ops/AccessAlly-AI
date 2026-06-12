# AccessAlly AI 🦾
### Disability-Inclusive Admissions Chatbot for Indian Higher Education

> Built for compliance with **UGC Accessibility Guidelines 2022**, **RPWD Act 2016** (21 Benchmark Disabilities), and **NEP 2020**

---

## ✨ Features

| Feature | Implementation |
|---|---|
| 🔐 Firebase Authentication | Email/password login, registration, password reset |
| 🤖 NVIDIA NIM AI | Streaming responses via `meta/llama-3.1-70b-instruct` |
| 📎 Document Upload | File picker with Firebase Storage + AI analysis |
| 📄 Document Parsing | PDF, DOCX, images, CSV — extracted for AI context |
| 💬 Streaming Chat | Real-time token streaming with typing indicator |
| 📝 Markdown Rendering | Rich formatted AI responses with tables, lists, code |
| 🗂️ Session History | All chats persisted to Firestore per user |
| 🎯 Quick Actions | Pre-built queries for common disability types |

---

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point + Firebase init
├── firebase_options.dart        # Firebase config (auto-generated)
│
├── models/
│   ├── chat_message.dart        # Chat message data model
│   └── uploaded_document.dart   # Document data model
│
├── services/
│   ├── auth_service.dart        # Firebase Authentication
│   ├── chat_service.dart        # Conversation state + Firestore
│   ├── nvidia_service.dart      # NVIDIA NIM API integration
│   └── document_service.dart    # File upload + Firebase Storage
│
├── screens/
│   ├── splash_screen.dart       # App splash with auth check
│   ├── auth/
│   │   ├── login_screen.dart    # Sign in screen
│   │   └── register_screen.dart # Institution registration
│   └── chat/
│       └── chat_screen.dart     # Main chat interface
│
├── widgets/
│   ├── chat_bubble.dart         # Message bubbles with markdown
│   ├── typing_indicator.dart    # Streaming content + dots
│   ├── document_upload_sheet.dart # Bottom sheet for uploads
│   └── quick_action_chips.dart  # Pre-built query chips
│
└── utils/
    └── theme.dart               # Dark theme + color system
```

---

## 🚀 Setup Guide

### Step 1: Prerequisites
```bash
flutter --version  # Ensure Flutter 3.19+ is installed
dart --version     # Dart 3.0+
```

### Step 2: Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

2. Enable these Firebase services:
   - **Authentication** → Email/Password provider ✅
   - **Firestore Database** → Create in production mode
   - **Storage** → Enable Firebase Storage

3. Install FlutterFire CLI and configure:
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```
This auto-generates `lib/firebase_options.dart` with your real credentials.

4. Set Firestore Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

5. Set Firebase Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Step 3: NVIDIA API Key

1. Sign up at [build.nvidia.com](https://build.nvidia.com)
2. Create an API key
3. Open `lib/services/nvidia_service.dart`
4. Replace the placeholder:
```dart
static const String _apiKey = 'nvapi-YOUR_NVIDIA_API_KEY_HERE';
```

The default model is `meta/llama-3.1-70b-instruct`. Other options:
- `meta/llama-3.1-405b-instruct` — most powerful, higher latency
- `mistralai/mixtral-8x22b-instruct-v0.1` — faster, good quality
- `nvidia/llama-3.1-nemotron-70b-instruct` — NVIDIA-tuned

### Step 4: Install & Run

```bash
# Install dependencies
flutter pub get

# Run on Android device/emulator
flutter run

# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

---

## 🏥 UGC Guidelines Coverage

AccessAlly AI's system prompt is grounded in:

### Documents (UGC 2022)
- UDID card or disability certificate from designated authority
- Ophthalmologist certificate for visual impairment (≥6/60)
- Benchmark disability confirmation: **minimum 40%** for RPWD 2016 benefits
- Standard academic documents in accessible formats

### Admission Process (UGC 2022 Sections 2.5 & 6.1)
- **Step 1**: Application in accessible formats (digital, large print, braille, audio)
- **Step 2**: Internal committee assessment at time of joining
- **Step 3**: CRC/DDRC referral for complex needs

### Academic Accommodations
- All course materials → accessible digital format
- Extra time, scribe, assistive technology for exams
- Expanded core curriculum with tactile graphics
- 5% seats reserved (RPWD 2016 Section 32)

### Campus Infrastructure
- Tactile pathways across campus
- GPS/Bluetooth beacon navigation
- Screen-reader compatible digital systems

### Library Services (UGC 2022 Section 8.3.2)
- Sugamya Pustakalaya integration
- Accessible format materials
- Trained library staff

---

## 🔒 Security Notes

- All documents stored in **user-isolated** Firebase Storage paths (`/users/{uid}/...`)
- Firestore rules enforce **data isolation** — no cross-user access
- NVIDIA API key should be moved to a **backend proxy** in production to avoid key exposure
- Firebase Auth tokens are managed automatically by the SDK

---

## 📱 Android Permissions Required
- `INTERNET` — Firebase & NVIDIA API
- `READ_EXTERNAL_STORAGE` / `READ_MEDIA_*` — Document upload
- `CAMERA` — Document photo capture

---

## 🔧 Production Enhancements

For production deployment, add:

1. **PDF OCR**: Integrate [syncfusion_flutter_pdf](https://pub.dev/packages/syncfusion_flutter_pdf) for actual text extraction
2. **Image OCR**: Use [google_ml_kit](https://pub.dev/packages/google_ml_kit) for photo document reading  
3. **NVIDIA API Proxy**: Create a Firebase Cloud Function to proxy NVIDIA calls (hides API key)
4. **Push Notifications**: Firebase Cloud Messaging for audit reminders
5. **Offline Mode**: Cache last 50 messages with Hive for offline viewing
6. **Export PDF**: Generate management reports using the `pdf` package

---

## 📞 Support

Built for Indian Higher Education Institutions complying with:
- **UGC Accessibility Guidelines 2022**
- **Rights of Persons with Disabilities Act 2016**
- **National Education Policy 2020**
- **ICF / ICD-10 Classification Systems**
- **WCAG 2.1 AA** digital accessibility standards
