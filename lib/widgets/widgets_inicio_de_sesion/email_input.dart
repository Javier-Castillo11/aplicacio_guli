import 'package:flutter/material.dart';
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class EmailInput extends StatelessWidget {
  final TextEditingController controller;
  final LanguageProvider languageProvider;

  const EmailInput({
    Key? key,
    required this.controller,
    required this.languageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Label
        Text(
          languageProvider.currentLanguage == 'es' ? 'Email' : 'Email', // Texto dinámico
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),

        const SizedBox(height: 14),

        // Email Input
        Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(217, 217, 217, 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromRGBO(255, 34, 174, 1),
              width: 3,
            ),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(
              color: Color.fromRGBO(203, 203, 203, 1),
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              hintText: languageProvider.currentLanguage == 'es'
                  ? 'Usuario@TuEmail.com'
                  : 'User@YourEmail.com', // Texto dinámico
              hintStyle: const TextStyle(
                color: Color.fromRGBO(203, 203, 203, 1),
                fontSize: 18,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 31,
                vertical: 23,
              ),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return languageProvider.currentLanguage == 'es'
                    ? 'Por favor, introduzca su correo electrónico'
                    : 'Please enter your email address'; // Texto dinámico
              }
              if (!value.contains('@')) {
                return languageProvider.currentLanguage == 'es'
                    ? 'Introduzca una dirección de correo válida'
                    : 'Please enter a valid email address'; // Texto dinámico
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}