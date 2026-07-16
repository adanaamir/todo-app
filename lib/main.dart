import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

//Global theme provider
final appThemeProvider = ThemeProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appThemeProvider.loadPreference();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(
    ListenableBuilder(
      listenable: appThemeProvider,
      builder: (context, _) => MyApp(themeMode: appThemeProvider.themeMode),
    ),
  );
}

//app build
class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  const MyApp({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ordely',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        // Clamp text scaler to a maximum scale of 1.15 to prevent UI overflows
        // while still respecting user accessibility preferences within reason.
        final double clampedScale = mediaQueryData.textScaler.scale(10) / 10;
        final double finalScale = clampedScale.clamp(0.9, 1.15);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(finalScale),
          ),
          child: child!,
        );
      },
      home: const AuthGate(),
    );
  }
}

//Listens to Firebase auth state and routes to Login or Home.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) return const HomeScreen();
        return const LoginScreen();
      },
    );
  }
}
