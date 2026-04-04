import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'state/game_provider.dart';
import 'state/ai_provider.dart';
import 'state/auth_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider(storageService)),
        ChangeNotifierProvider(create: (_) => AiProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const CrosswordMasterApp(),
    ),
  );
}

class CrosswordMasterApp extends StatelessWidget {
  const CrosswordMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crossword Master',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/home',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomeScreen(),
        '/game': (context) => const GameScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
