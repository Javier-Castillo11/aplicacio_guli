import 'package:flutter/material.dart';

class LoginLink extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginLink({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPressed, // Usar el onPressed proporcionado
        child: const Text(
          'Login',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFF22AE),
          ),
        ),
      ),
    );
  }
}