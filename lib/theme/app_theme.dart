import 'package:flutter/material.dart';

/// Regla 60-30-10 definida en el diseño de la App ITLA:
/// - Edición Polar (Claro):
///   60% Blanco Polar (#F1F3F4) - Fondo
///   30% Azul Glaciar (#9CC6E0) - Tarjetas
///   10% Rojo Racing (#E4002B) - Botones y alertas
///
/// - Edición Tormenta (Oscuro):
///   60% Gris Tormenta (#5A6068) - Fondo
///   30% Negro Mate (#1C1D20) - Tarjetas
///   10% Naranja Seguridad (#FF5F00) - Botones y alertas
class AppTheme {
  // Colores Polar
  static const Color polarBackground = Color(0xFFF1F3F4);
  static const Color polarCards = Color(0xFF9CC6E0);
  static const Color polarAccent = Color(0xFFE4002B); // Rojo Racing
  static const Color polarTextPrimary = Color(0xFF1A1A1A);
  static const Color polarTextSecondary = Color(0xFF4A4A4A);
  static const Color polarCardSecondary = Color(0xFFE2EDF5);

  // Colores Tormenta
  static const Color tormentaBackground = Color(0xFF5A6068);
  static const Color tormentaCards = Color(0xFF1C1D20);
  static const Color tormentaAccent = Color(0xFFFF5F00); // Naranja Seguridad
  static const Color tormentaTextPrimary = Color(0xFFFFFFFF);
  static const Color tormentaTextSecondary = Color(0xFFB0B3B8);
  static const Color tormentaCardSecondary = Color(0xFF282A2E);

  // Tema Claro (Edición Polar)
  static ThemeData get polarTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: polarBackground,
      colorScheme: const ColorScheme.light(
        background: polarBackground,
        surface: polarCards,
        primary: polarAccent,
        secondary: polarCards,
        onPrimary: Colors.white,
        onSurface: polarTextPrimary,
        error: polarAccent,
      ),
      cardTheme: CardTheme(
        color: polarCards,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: polarBackground,
        foregroundColor: polarTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: polarAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: polarTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: polarTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: polarTextPrimary,
        ),
        bodyMedium: TextStyle(
          color: polarTextSecondary,
        ),
      ),
    );
  }

  // Tema Oscuro (Edición Tormenta)
  static ThemeData get tormentaTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: tormentaBackground,
      colorScheme: const ColorScheme.dark(
        background: tormentaBackground,
        surface: tormentaCards,
        primary: tormentaAccent,
        secondary: tormentaCards,
        onPrimary: Colors.white,
        onSurface: tormentaTextPrimary,
        error: tormentaAccent,
      ),
      cardTheme: CardTheme(
        color: tormentaCards,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: tormentaBackground,
        foregroundColor: tormentaTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tormentaAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: tormentaTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: tormentaTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: tormentaTextPrimary,
        ),
        bodyMedium: TextStyle(
          color: tormentaTextSecondary,
        ),
      ),
    );
  }
}
