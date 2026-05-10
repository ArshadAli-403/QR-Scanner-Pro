# QR Scanner App (Flutter + MVVM)

A modern, fast, and user-friendly **QR Code Scanner Mobile Application** built using Flutter.  
This project follows **MVVM architecture** and uses **SQLite local database** to store scan history.

---

## Features

- ⚡ Fast QR Code Scanning using device camera
- 💾 Local storage of scan history (SQLite)
- 📋 Copy scanned result to clipboard
- 🔗 Open URLs directly from scanned QR codes
- 📤 Share scanned results
- 🔦 Flashlight toggle support
- 🔄 Camera switching (front/back)
- 📜 Scan history screen
- 🎨 Clean and modern UI (Material 3 Design)

---

## 🛠️ Tech Stack

- Flutter (Dart)
- MVVM Architecture
- Provider (State Management)
- SQLite (Local Database)
- mobile_scanner (QR Scanning)
- url_launcher (Open links)

---

## 🏗️ Architecture

This project follows **MVVM (Model-View-ViewModel)** architecture:

- **Model** → Data structure (QR Scan Model)
- **View** → UI Screens (Home, Scanner, Result, History)
- **ViewModel** → Business logic & state management

---

## 📂 Project Structure
lib/
│
├── constants/ # App colors & strings
├── models/ # Data models
├── providers/ # State management (ViewModel)
├── screens/ # UI Screens
├── services/ # Database services
├── widgets/ # Reusable widgets
└── main.dart


---

## 💾 Database (SQLite)

- Stores scanned QR results locally
- Data includes:
  - QR Text
  - Scan Date & Time

---

## 📱 Screens

- Splash Screen
- Home Screen
- QR Scanner Screen
- Result Screen
- Scan History Screen

---

## ⚙️ Installation & Setup

1. Clone the repository
```bash
git clone https://github.com/your-username/qr-scanner-app.git
2. Navigate to Project
cd qr-scanner-app
3. Install Dependencies
flutter pub get
4. Run the App
flutter run
5. Build APK
flutter build apk --release

Developer
Arshad Ali
