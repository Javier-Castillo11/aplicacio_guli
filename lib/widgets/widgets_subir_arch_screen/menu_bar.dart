import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import 'package:shared_preferences/shared_preferences.dart'; // Importa SharedPreferences
import '../../constants/app_colors.dart';
import '../../providers/theme_provider.dart'; // Importa tu ThemeProvider
import '../../providers/language_provider.dart'; // Importa el LanguageProvider
import '../../screens/homepage.dart'; // Importa la pantalla de Homepage
import '../../screens/pacientes_ecg_screen.dart'; // Importa la pantalla de PacientesEcgScreen
import '../../screens/configuraciones_screen.dart'; 
import '../../screens/perfil_screen.dart'; 
import '../../screens/login_screen.dart'; 
import '../../screens/clasificador_screen.dart';

class MenuBar extends StatelessWidget {
  const MenuBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Accede al ThemeProvider
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider
    final prefs = Provider.of<SharedPreferences>(context); // Accede a SharedPreferences

    // Mapeo de textos en español a valores en inglés
    final Map<String, String> menuItemMap = {
      'Inicio': 'Home',
      'Pacientes': 'Patients',
      'Perfil': 'Profile',
      'Clasificador': 'Sorter',
      'Configuración': 'Settings',
      'Cerrar sesión': 'Log out',
    };

    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.menu,
          color: themeProvider.isDarkMode ? Colors.white : AppColors.black, // Cambia el color del ícono según el tema
        ),
        onSelected: (value) {
          // Traducir el valor seleccionado al inglés usando el mapa
          final translatedValue = menuItemMap[value] ?? value;

          // Navegar a la pantalla correspondiente según la opción seleccionada
          switch (translatedValue) {
            case 'Home':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Homepage(),
                ),
              );
              break;
            case 'Patients':
              if (prefs.getString('userRole') == 'patient') {
                // Mostrar mensaje de advertencia si el usuario es un paciente
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      languageProvider.currentLanguage == 'es'
                          ? 'No puedes acceder. Cuenta de paciente.'
                          : 'Access denied. Patient account.',
                    ),
                  ),
                );
              } else {
                // Navegar a la pantalla de pacientes si el usuario es un profesional de la salud
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PacientesEcgScreen(),
                  ),
                );
              }
              break;
            case 'Settings':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfiguracionesScreen(),
                ),
              );
              break;
            case 'Profile':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PerfilScreen(),
                ),
              );
              break;
            case 'Log out':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
              break;
            case 'Sorter':
            ////////
             Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClasificadorScreen(),
                ),
              );
              break;
            default:
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          // Textos dinámicos según el idioma seleccionado
          final menuItems = languageProvider.currentLanguage == 'es'
               ? ['Inicio', 'Pacientes', 'Perfil', 'Clasificador', 'Configuración', 'Cerrar sesión']
              : ['Home', 'Patients', 'Profile', 'Sorter', 'Settings', 'Log out'];

          return menuItems.map((String choice) {
            return PopupMenuItem<String>(
              value: choice, // El valor es el texto mostrado (en español o inglés)
              child: Text(
                choice,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: themeProvider.isDarkMode ? Colors.white : AppColors.black, // Cambia el color del texto según el tema
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }
}