import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../widgets/glass_widgets.dart';
import 'home_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {

  @override
  void initState() {
    super.initState();
    _checkInitialPermission();
  }

  Future<void> _checkInitialPermission() async {
    await Future.delayed(const Duration(milliseconds: 500));
    bool isGranted = await _isStoragePermissionGranted();
    if (isGranted && mounted) {
      _navigateHome();
    }
  }

  Future<bool> _isStoragePermissionGranted() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        // For Android 13+, we check for media permissions
        return await Permission.photos.isGranted || 
               await Permission.videos.isGranted || 
               await Permission.audio.isGranted ||
               await Permission.manageExternalStorage.isGranted;
      }
    }
    return await Permission.storage.isGranted || await Permission.manageExternalStorage.isGranted;
  }

  void _navigateHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      
      if (deviceInfo.version.sdkInt >= 33) {
        // Android 13+ request
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
        
        if (statuses.values.every((status) => status.isGranted)) {
          _navigateHome();
          return;
        }
      } else {
        // Android 12 and below
        PermissionStatus status = await Permission.storage.request();
        if (status.isGranted) {
          _navigateHome();
          return;
        }
      }
    } else {
      // Non-Android platforms
      PermissionStatus status = await Permission.storage.request();
      if (status.isGranted) {
        _navigateHome();
        return;
      }
    }

    // If we reach here, permission wasn't granted or it's a permanent denial
    if (await Permission.storage.isPermanentlyDenied || 
        (Platform.isAndroid && await Permission.photos.isPermanentlyDenied)) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Permission Required"),
            content: const Text("Storage permission is required to save your data. Please enable it in settings."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              TextButton(onPressed: () => openAppSettings(), child: const Text("Settings")),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission is needed to secure your data.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassContainer(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.security, size: 64, color: Colors.white),
                  const SizedBox(height: 24),
                  const Text(
                    "Welcome",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "To ensure your transaction records are saved securely on your device, please grant storage permissions.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _requestPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Grant Permission", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _navigateHome(),
                    child: const Text("Skip", style: TextStyle(color: Colors.white38)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
