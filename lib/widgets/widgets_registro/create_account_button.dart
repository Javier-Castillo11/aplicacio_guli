import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class CreateAccountButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateAccountButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed, // Usar el onPressed proporcionado
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF22AE), // Color inicial
                Color(0xFFCEAAC1), // Color final
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              languageProvider.currentLanguage == 'es' ? 'Crear cuenta' : 'Create Account', // Texto dinámico
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}