import 'package:flutter/material.dart';

import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class TitleSubtitle extends StatelessWidget {
  final LanguageProvider languageProvider; // Parámetro para el LanguageProvider

  const TitleSubtitle({Key? key, required this.languageProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          languageProvider.currentLanguage == 'es'
              ? 'Inicio de sesión en Guli App'
              : 'Guli App Login', // Texto dinámico
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            fontFamily: 'Inter',
          ),
        ),

        const SizedBox(height: 33),

        // Subtitle
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
            children: languageProvider.currentLanguage == 'es'
                ? [
                    const TextSpan(
                      text: 'Inicia sesión con tu ',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    const TextSpan(
                      text: 'cuenta de ',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    const TextSpan(
                      text: 'Guli App',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ]
                : [
                    const TextSpan(
                      text: 'Sign in with your ',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    const TextSpan(
                      text: 'Guli App ',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(
                      text: 'account',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}