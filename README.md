# Local Business Ledger

A Flutter application for tracking business transactions offline with a Glassmorphism UI.

## Getting Started

### Prerequisites
- Flutter SDK
- Android Studio (for Android development)
- Android Device enabled for USB Debugging

### Running in Android Studio
1.  **Open Project**: Launch Android Studio and click **Open**. Select the `Cal-Org` folder on your desktop.
2.  **Sync**: Wait for Android Studio to sync Gradle files and index the project.
3.  **Select Device**: In the top toolbar, you should see a device dropdown. Select your connected phone (e.g., `I2221`).
4.  **Run**: Click the green **Play** button (▶) to build and install the app on your phone.

### Running via Terminal
You can also run the app directly from the terminal without opening Android Studio full GUI:
```bash
flutter run
```
If multiple devices are connected, specify the device:
```bash
flutter run -d 10BF4D0GAZ002B1
```

## Features
- **Offline Storage**: Hive NoSQL
- **UI**: Glassmorphism
- **Analytics**: FL Chart
