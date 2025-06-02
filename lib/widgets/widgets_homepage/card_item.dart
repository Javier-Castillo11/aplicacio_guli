import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../../constants/app_colors.dart';
import '../../providers/theme_provider.dart'; // Importa tu ThemeProvider

class CardItem extends StatelessWidget {
  final String imagePath;
  final String label;

  const CardItem({
    Key? key,
    required this.imagePath,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Accede al ThemeProvider

    return Container(
      width: 110,
      height: 110,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        //color: themeProvider.isDarkMode ? Colors.grey[800] : AppColors.cardBackground, // Fondo según el tema
        color:  AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: themeProvider.isDarkMode ? const Color.fromARGB(255, 223, 214, 214) : AppColors.black, // Borde según el tema
          width: 5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: AppColors.black, // Texto según el tema
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}