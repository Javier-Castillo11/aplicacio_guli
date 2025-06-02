import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class ResetPasswordTitle extends StatelessWidget {
  const ResetPasswordTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return Text(
      languageProvider.currentLanguage == 'es'
          ? 'Restablecer contraseña'
          : 'Reset Password', // Texto dinámico
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontFamily: 'Inria Serif',
        fontWeight: FontWeight.bold,
      ),
    );
  }
}