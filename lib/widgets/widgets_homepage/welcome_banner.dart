import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../constants/app_colors.dart';

class WelcomeBanner extends StatelessWidget {
  final String welcomeText; // Parámetro para el texto de bienvenida
  final String userName; // Parámetro para el nombre del usuario

  const WelcomeBanner({
    Key? key,
    required this.welcomeText, // Hacemos el parámetro requerido
    required this.userName, // Hacemos el parámetro requerido
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.only(top: 25),
      width: 489,
      height: 160, // Altura fija para el banner
      child: Stack(
        children: [
          // Fondo del banner
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/welcome_bg.png', // Reemplaza con la ruta correcta
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenido del banner (mensaje de bienvenida y nombre del usuario)
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 16, 13, 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensaje de bienvenida
                  Text(
                    welcomeText, // Usamos el parámetro welcomeText
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBackground, // Texto dinámico
                    ),
                  ),

                  // Espaciado entre el mensaje y el nombre del usuario
                  const SizedBox(height: 8),

                  // Nombre del usuario
                  Text(
                    userName,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: themeProvider.isDarkMode ? Colors.grey[800] : AppColors.darkBackground, // Texto dinámico
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}