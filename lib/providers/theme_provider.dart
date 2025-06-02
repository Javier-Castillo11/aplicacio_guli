import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Notifica a los widgets que el tema ha cambiado
  }

  // Define tus temas claro y oscuro
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}