import 'package:flutter/material.dart';
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final LanguageProvider languageProvider;

  const LoginButton({
    Key? key,
    required this.onPressed,
    required this.languageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // Usar el onPressed proporcionado
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF22AE), // Color inicial
              Color(0xFFCEAAC1), // Color final
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: Text(
            languageProvider.currentLanguage == 'es' ? 'Acceso' : 'Login', // Texto dinámico
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}