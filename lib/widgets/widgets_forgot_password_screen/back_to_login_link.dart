import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class BackToLoginLink extends StatelessWidget {
  final VoidCallback onPressed;

  const BackToLoginLink({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          languageProvider.currentLanguage == 'es'
              ? 'Volver a inicio de sesión'
              : 'Back to Login', // Texto dinámico
          style: const TextStyle(
            color: Color(0xFFFF22AE), // Texto rosa
            fontFamily: 'Inria Serif',
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}