 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/theme_provider.dart';
import 'services/background_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Workmanager with the background callback
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // Change to true for debugging
  );

  // Register a periodic task that will trigger the background fetch.
  // Note: The minimum frequency on Android is 15 minutes.
  Workmanager().registerPeriodicTask(
    "1",
    backgroundTaskKey,
    frequency: Duration(minutes: 15),
    initialDelay: Duration(seconds: 10), // Optional: delay before the first run
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Status Monitor',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}
