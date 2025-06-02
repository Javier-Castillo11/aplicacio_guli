import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class EmailInput extends StatelessWidget {
  final TextEditingController controller;

  const EmailInput({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.currentLanguage == 'es' ? 'Correo electrónico' : 'Email', // Texto dinámico
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFCBCBCB),
          ),
          decoration: InputDecoration(
            hintText: languageProvider.currentLanguage == 'es'
                ? 'Usuario@TuEmail.com'
                : 'User@YourEmail.com', // Texto dinámico
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFCBCBCB),
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
                  ? 'Por favor ingrese su correo electrónico'
                  : 'Please enter your email'; // Texto dinámico
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return languageProvider.currentLanguage == 'es'
                  ? 'Por favor ingrese un correo válido'
                  : 'Please enter a valid email'; // Texto dinámico
            }
            return null;
          },
        ),
      ],
    );
  }
}