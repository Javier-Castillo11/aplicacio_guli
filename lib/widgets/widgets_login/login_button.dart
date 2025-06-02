import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String text; // Parámetro para el texto dinámico
  final VoidCallback onPressed;

  const LoginButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 320, // Ancho fijo
        height: 62, // Alto fijo
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF22AE), // Color inicial
              Color(0xFFCEAAC1), // Color final
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: Text(
            text, // Usar el texto dinámico
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}