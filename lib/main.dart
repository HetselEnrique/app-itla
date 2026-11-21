import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  await appState.init();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const ItlaOrganizerApp(),
    ),
  );
}

class ItlaOrganizerApp extends StatelessWidget {
  const ItlaOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      title: 'App Organizadora ITLA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.polarTheme,
      darkTheme: AppTheme.tormentaTheme,
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'DO'), // República Dominicana / Español
        Locale('es', ''),
      ],
      // Si ya hay sesión iniciada o datos guardados, entra directo a Hoy
      home: (appState.session.isLoggedIn || appState.tasks.isNotEmpty)
          ? const MainLayout()
          : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainLayout(),
      },
    );
  }
}
