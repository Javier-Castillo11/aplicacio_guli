import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class EmailInput extends StatelessWidget {
  final TextEditingController controller;

  const EmailInput({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Email', // Este texto no cambia, pero puedes hacerlo dinámico si lo deseas
        labelStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inria Serif',
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF22AE)),
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Inria Serif',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return languageProvider.currentLanguage == 'es'
              ? 'Introduzca su dirección de correo electrónico.'
              : 'Please enter your email address.'; // Texto dinámico
        }
        return null;
      },
    );
  }
}