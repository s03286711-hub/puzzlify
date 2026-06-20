import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar, light icons
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF090E1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Pre-warm SharedPreferences
  await StorageService.init();

  // Init audio engine
  await AudioService.instance.init();

  runApp(const PuzzlifyApp());
}

class PuzzlifyApp extends StatelessWidget {
  const PuzzlifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzlify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
