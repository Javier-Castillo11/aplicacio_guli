import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../../providers/theme_provider.dart'; // Importa tu ThemeProvider
import '../../providers/language_provider.dart'; // Importa el LanguageProvider
import '../../constants/app_colors.dart';
import '../../screens/pacientes_ecg_screen.dart'; // Importa la pantalla
import '../../screens/account_screen.dart';
import '../../screens/configuraciones_screen.dart';
import '../../screens/perfil_screen.dart';
import '../../screens/clasificador_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchBar extends StatelessWidget {
  SearchBar({Key? key}) : super(key: key);

  // Mapeo de búsquedas en español a valores en inglés
  final Map<String, String> searchMap = {
    'pacientes': 'patients',
    'inicio': 'home',
    'perfil': 'profile',
    'configuración': 'settings',
    'configuracion': 'settings',
    'cuenta': 'account',
    'historial': 'history',
    'clasificador': 'sorter',
    'clasificar': 'classify',
  };

  void _handleSearch(BuildContext context, String query) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final prefs = Provider.of<SharedPreferences>(context, listen: false);

    // Convertir la consulta a minúsculas y eliminar espacios adicionales
    query = query.trim().toLowerCase();

    // Traducir la consulta si está en español
    if (languageProvider.currentLanguage == 'es') {
      query = searchMap[query] ?? query;
    }

    // Navegar a la pantalla correspondiente según la consulta
    switch (query) {
      case 'patients':
        if (prefs.getString('userRole') == 'patient') {
          // Mostrar mensaje de advertencia si el usuario es un paciente
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                languageProvider.currentLanguage == 'es'
                    ? 'Acceso restringido. Cuenta de paciente.'
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
      case 'home':
        // Aquí puedes redirigir a la pantalla de inicio
        // Navigator.push(...);
        break;
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PerfilScreen(),
          ),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ConfiguracionesScreen(),
          ),
        );
        break;
      case 'account':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AccountScreen(),
          ),
        );
        break;
      case 'sorter':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ClasificadorScreen(),
          ),
        );
        break;
      case 'classify':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ClasificadorScreen(),
          ),
        );
        break;
      default:
        // Mostrar un mensaje si no se encuentran resultados
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.currentLanguage == 'es'
                  ? 'No se encontraron resultados'
                  : 'No results found', // Mensaje dinámico
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final themeProvider = context.watch<ThemeProvider>(); // Usa context.watch
    final TextEditingController _searchController = TextEditingController();

    return Container(
      margin: const EdgeInsets.only(top: 10), // Subimos el SearchBar
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), // Reducimos la altura
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : AppColors.white, // Fondo dinámico
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: themeProvider.isDarkMode ? Colors.grey[700]! : AppColors.borderColor, // Borde dinámico
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de búsqueda como botón
          GestureDetector(
            onTap: () {
              _handleSearch(context, _searchController.text);
            },
            child: Image.asset(
              'assets/images/search_icon.png', // Reemplaza con la ruta correcta
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: languageProvider.currentLanguage == 'es'
                        ? 'Buscar...' // Texto en español
                        : 'Search...', // Texto en inglés
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: themeProvider.isDarkMode ? Colors.white : AppColors.black, // Texto dinámico
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: themeProvider.isDarkMode ? Colors.white : AppColors.black, // Texto dinámico
              ),
              onSubmitted: (value) {
                _handleSearch(context, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}