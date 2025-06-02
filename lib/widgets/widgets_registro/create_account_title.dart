import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class CreateAccountTitle extends StatelessWidget {
  const CreateAccountTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return Text(
      languageProvider.currentLanguage == 'es' ? 'Crea tu cuenta' : 'Create Account', // Texto dinámico
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    );
  }
}