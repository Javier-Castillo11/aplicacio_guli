import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../../providers/theme_provider.dart'; // Importa tu ThemeProvider

class UserInfo extends StatelessWidget {
  final String label;
  final String value;

  const UserInfo({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Accede al ThemeProvider
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inria Serif',
            fontSize: 16,
            color: themeProvider.isDarkMode ? Colors.white : AppColors.black, // Texto dinámico
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inria Serif',
            fontSize: 14,
            color: themeProvider.isDarkMode ? Colors.white : AppColors.black, // Texto dinámico
          ),
        ),
      ],
    );
  }
}