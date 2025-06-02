import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class RegisterText extends StatelessWidget {
  final String text; // Parámetro para el texto dinámico
  final VoidCallback onPressed;

  const RegisterText({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    return SizedBox(
      width: 244, // Ancho fijo
      height: 27, // Alto fijo
      child: GestureDetector(
        onTap: onPressed, // Usar el onPressed proporcionado
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(
                text: text, // Usar el texto dinámico
                style: const TextStyle(
                  color: Color(0xFFE5E5E5),
                ),
              ),
              TextSpan(
                text: languageProvider.currentLanguage == 'es'
                ? "Regístrate" : "Register",
                style: const TextStyle(
                  color: Color(0xFFFF22AE),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}