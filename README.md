<div align="center">

# 📹 V-Connect

**High-Quality Real-Time Video & Voice Calling App**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Agora](https://img.shields.io/badge/Agora_RTC-6.6.3-099DFD?style=for-the-badge)](https://www.agora.io)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*Make high-quality video and voice calls in real time*

</div>

---

## 📋 Overview

**V-Connect** is a Flutter application that enables real-time video and voice calls using **Agora RTC** technology. It features a clean Arabic-first UI with full RTL support and a professional dark theme.

---

## ✨ Features

- 🎥 **Video Calls** — Two-way high-quality video streaming
- 🎙️ **Voice Calls** — Audio-only call support
- 🔇 **Mute Toggle** — Mute/unmute microphone during a call
- 📷 **Camera Switch** — Flip between front and rear cameras
- 📺 **Multi-Participant View** — View multiple participants in the same room
- 🔗 **Join by Room Code** — Enter any room name to join instantly
- 🌙 **Dark Mode** — Fully dark, polished UI
- 🇸🇦 **Arabic Support** — Full Arabic interface with RTL layout

---

## 📸 Screenshots

> Add screenshots here after running the app

---

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| [Flutter](https://flutter.dev) | `^3.10.4` | UI Framework |
| [Dart](https://dart.dev) | `^3.10.4` | Programming Language |
| [agora_rtc_engine](https://pub.dev/packages/agora_rtc_engine) | `^6.6.3` | Real-Time Communication Engine |
| [permission_handler](https://pub.dev/packages/permission_handler) | `^12.0.1` | Device Permission Management |
| [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) | `^0.14.4` | App Icon Generation |
| Cairo Font | — | Primary Arabic Typeface |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `^3.10.4`
- [Dart SDK](https://dart.dev/get-dart) `^3.10.4`
- A developer account on [Agora.io](https://console.agora.io)
- A physical device or emulator with camera and microphone support

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/video_connect.git
cd video_connect
```

### 2. Configure Your Agora Credentials

Open `lib/core/app_constants.dart` and set your Agora credentials:

```dart
static const String agoraAppId = 'YOUR_AGORA_APP_ID';
static const String agoraToken = 'YOUR_AGORA_TOKEN'; // Leave empty for testing mode
static const String defaultChannelName = 'vconnect-room';
```

> ⚠️ **Warning**: Never commit your real `agoraAppId` or `agoraToken` to a public repository. Use environment variables or a `.env` file in production.

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # App configuration & theme
├── core/
│   └── app_constants.dart             # Global constants & Agora config
└── features/
    ├── home/
    │   └── home_screen.dart           # Home screen
    └── call/
        ├── call_screen.dart           # Call screen UI
        └── agora_call_controller.dart # Agora RTC logic
```

---

## ⚙️ Permissions Setup

### Android

In `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### iOS

In `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice calls</string>
```

---

## 🔑 Getting Your Agora App ID

1. Sign up at [Agora Console](https://console.agora.io)
2. Create a new project
3. Copy the **App ID** into `lib/core/app_constants.dart`
4. For production: generate a **Token** using an Agora Token Server

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. Create a new branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push the branch: `git push origin feature/your-feature-name`
5. Open a **Pull Request**

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

Made with ❤️ using [Flutter](https://flutter.dev)

</div>
