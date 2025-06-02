import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class ResetPasswordButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ResetPasswordButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF22AE), // Fondo rosa
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          languageProvider.currentLanguage == 'es'
              ? 'Restablecer contraseña'
              : 'Reset Password', // Texto dinámico
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Inria Serif',
          ),
        ),
      ),
    );
  }
}