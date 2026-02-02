# 📒 Cal-Org – Offline Business Ledger App (Flutter)

Cal-Org is a **modern, offline-first business transaction management app** built using **Flutter**.
It helps small businesses and individuals **track products, payments, balances, and financial statistics** with a clean, professional, glassmorphism-based UI.

---

## ✨ Features

### 🧾 Transaction Management

* Add product-based transactions
* Store:

  * Product name
  * Product price
  * Date (auto + manual selection)
  * Person name
  * Amount received
  * Auto-calculated balance
* Delete transactions instantly

### 📊 Dashboard & Analytics

* Total income overview
* Total expense summary
* Net balance calculation
* Interactive charts (pie / bar)
* Real-time updates on data change

### 💾 Offline First

* Works **100% offline**
* Data stored securely in **local device storage**
* No internet or cloud dependency

### 🎨 UI / UX

* Glassmorphism (translucent blur effects)
* Dark gradient background
* Smooth animations
* User-friendly & professional design
* Color-coded actions:

  * 🟢 Add button
  * 🔴 Delete button

---

## 🛠️ Tech Stack

| Technology          | Usage                       |
| ------------------- | --------------------------- |
| **Flutter**         | Cross-platform UI framework |
| **Dart**            | Programming language        |
| **Hive**            | Local NoSQL database        |
| **Provider**        | State management            |
| **fl_chart**        | Graphs & charts             |
| **Material Design** | UI components               |

---

## 📂 Project Structure

```
lib/
 ├── main.dart
 ├── models/
 │    └── transaction_model.dart
 ├── providers/
 │    └── transaction_provider.dart
 ├── screens/
 │    ├── home_screen.dart
 │    ├── add_transaction_screen.dart
 │    └── dashboard_screen.dart
 ├── widgets/
 │    └── glass_card.dart
assets/
 └── icon/
     └── app_icon.png
```

---

## 🧮 Business Logic

* **Balance Calculation**

  ```
  Balance = Product Price − Amount Received
  ```
* Auto-updated when transactions are added or deleted
* Persistent storage even after app restart

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK (latest stable)
* Android Studio / VS Code
* Android Emulator or Physical Device

---

### Installation

```bash
git clone https://github.com/your-username/Cal-Org.git
cd Cal-Org
flutter pub get
flutter run
```

---

## 📱 Platform Support

* ✅ Android (Fully supported)
* ❌ iOS (Not configured – Android-focused project)

---

## 🔐 Permissions

* No internet permission required
* Uses app sandboxed storage
* Storage permission not mandatory unless exporting files

---

## 🧪 Tested On

* Android Emulator
* Physical Android device
* Android 12+

---

## 📌 Future Enhancements

* PDF / Excel export
* Monthly & yearly reports
* Search & filter transactions
* Backup & restore
* Multi-business support
* Authentication (optional)

---

## 👨‍💻 Author

**Sujay V**
Flutter Developer | AI & ML Enthusiast

---

## ⭐ Show Your Support

If you like this project:

* ⭐ Star the repo
* 🍴 Fork it
* 🐛 Report issues
* 🚀 Suggest improvements

---

## 📄 License

This project is licensed under the **MIT License**.

---
