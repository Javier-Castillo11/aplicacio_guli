import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class PasswordInput extends StatelessWidget {
  final TextEditingController controller;

  const PasswordInput({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.currentLanguage == 'es'
              ? 'Contraseña'
              : 'Password', // Texto dinámico
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFFCBCBCB),
          ),
          decoration: InputDecoration(
            hintText: languageProvider.currentLanguage == 'es'
                ? 'Ingresa tu contraseña'
                : 'Enter your password', // Texto dinámico
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFFCBCBCB),
            ),
            filled: true,
            fillColor: const Color(0x1AD9D9D9),
            contentPadding: const EdgeInsets.fromLTRB(31, 23, 31, 23),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFFF22AE),
                width: 3,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFFF22AE),
                width: 3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFFF22AE),
                width: 3,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return languageProvider.currentLanguage == 'es'
                  ? 'Por favor, ingresa tu contraseña'
                  : 'Please enter your password'; // Texto dinámico
            }
            if (value.length < 6) {
              return languageProvider.currentLanguage == 'es'
                  ? 'La contraseña debe tener al menos 6 caracteres'
                  : 'Password must be at least 6 characters'; // Texto dinámico
            }
            return null;
          },
        ),
      ],
    );
  }
}