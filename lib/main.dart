import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/transaction.dart';
import 'models/transaction_item.dart';
import 'providers/transaction_provider.dart';
import 'screens/permission_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register Adapters safely
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionItemAdapter());
    }

    // Create provider instance
    final transactionProvider = TransactionProvider();
    
    // We await init() to ensure data is loaded before UI starts
    await transactionProvider.init();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: transactionProvider),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint("Error during initialization: $e");
    // Run a fallback error app if initialization fails completely
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text("Startup Error: $e")))));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Su-Profit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const PermissionScreen(),
    );
  }
}
