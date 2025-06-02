import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class SignUpSubtitle extends StatelessWidget {
  const SignUpSubtitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.white,
        ),
        children: [
          TextSpan(
            text: languageProvider.currentLanguage == 'es' ? 'Regístrate en ' : 'Sign up to ', // Texto dinámico
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: 'Guli App',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}