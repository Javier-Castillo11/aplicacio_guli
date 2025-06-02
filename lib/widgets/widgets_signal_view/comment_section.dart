import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class CommentSection extends StatelessWidget {
  final TextEditingController controller; // Controlador para el campo de texto

  const CommentSection({
    Key? key,
    required this.controller, // Hacemos que el controlador sea requerido
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFA7A7A7),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller, // Asignamos el controlador al TextField
        decoration: InputDecoration(
          hintText: languageProvider.currentLanguage == 'es'
              ? 'Escribe un comentario...'
              : 'Write a comment...', // Texto dinámico
          hintStyle: TextStyle(
            fontFamily: 'Inria Serif',
            fontSize: 14,
            color: Colors.black,
          ),
          border: InputBorder.none,
        ),
        style: TextStyle(
          fontFamily: 'Inria Serif',
          fontSize: 14,
          color: Colors.black,
        ),
        maxLines: 3,
      ),
    );
  }
}