import 'package:flutter/material.dart';
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final LanguageProvider languageProvider;

  const PasswordInput({
    Key? key,
    required this.controller,
    required this.languageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Password Label
        Text(
          languageProvider.currentLanguage == 'es' ? 'Contraseña' : 'Password', // Texto dinámico
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),

        const SizedBox(height: 15),

        // Password Input
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
            obscureText: true,
            style: const TextStyle(
              color: Color.fromRGBO(203, 203, 203, 1),
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              hintText: languageProvider.currentLanguage == 'es'
                  ? 'Introduce tu contraseña'
                  : 'Enter your password', // Texto dinámico
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
                    ? 'Por favor, introduzca su contraseña'
                    : 'Please enter your password'; // Texto dinámico
              }
              if (value.length < 8) {
                return languageProvider.currentLanguage == 'es'
                    ? 'La contraseña debe tener al menos 8 caracteres'
                    : 'Password must be at least 8 characters'; // Texto dinámico
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}