import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../../providers/language_provider.dart'; // Importa el LanguageProvider
import '../../constants/app_colors.dart';
import '../../screens/account_screen.dart'; // Importa la pantalla AccountScreen

class CuentaItem extends StatelessWidget {
  const CuentaItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary, // Color rosa
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            languageProvider.currentLanguage == 'es'
                ? 'Cuenta'
                : 'Account', // Texto dinámico
            style: TextStyle(
              fontFamily: 'Inria Serif',
              fontSize: 16,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(), // Espacio entre el texto y la flecha
          IconButton(
            onPressed: () {
              // Navegar a AccountScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_forward,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}