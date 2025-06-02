import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class ResetPasswordSubtitle extends StatelessWidget {
  const ResetPasswordSubtitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return Text(
      languageProvider.currentLanguage == 'es'
          ? 'Introduzca su dirección de correo electrónico para recibir un enlace de restablecimiento de contraseña.'
          : 'Enter your email address to receive a password reset link.', // Texto dinámico
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'Inria Serif',
      ),
    );
  }
}