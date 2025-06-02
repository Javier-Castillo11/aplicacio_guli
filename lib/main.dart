import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import 'package:shared_preferences/shared_preferences.dart'; // Importa SharedPreferences
import '../providers/theme_provider.dart'; // Importa tu ThemeProvider
import '../providers/language_provider.dart'; // Importa el LanguageProvider
import '../providers/notification_provider.dart'; // Importa el NotificationProvider
import 'screens/inicio_screen.dart'; // Importa la pantalla inicial
import 'screens/pacientes_ecg_screen.dart'; // Importa la pantalla de pacientes
import 'screens/configuraciones_screen.dart'; // Importa la pantalla de configuraciones


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // inicializa Flutter
  final prefs = await SharedPreferences.getInstance(); // Obtén la instancia de SharedPreferences

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()), // Añade el NotificationProvider
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        Provider<SharedPreferences>.value(value: prefs), // Provee SharedPreferences
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Accede al ThemeProvider

    return MaterialApp(
      title: 'Mi Aplicación', // Título de la aplicación
      theme: themeProvider.currentTheme, // Usa el tema actual
      home: const InicioScreen(), // Pantalla inicial
      debugShowCheckedModeBanner: false, // Oculta el banner de "Debug"
      routes: {
        '/pacientes-ecg': (context) => const PacientesEcgScreen(), // Define la ruta
        '/configuraciones': (context) => const ConfiguracionesScreen(), // Define la ruta
      },
    );
  }
}