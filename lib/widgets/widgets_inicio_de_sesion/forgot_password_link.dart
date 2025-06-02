import 'package:aplicacion_guli/screens/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import '../../providers/language_provider.dart'; // Importa el LanguageProvider

class ForgotPasswordLink extends StatelessWidget {
  final LanguageProvider languageProvider;

  const ForgotPasswordLink({Key? key, required this.languageProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          // Navegar a la pantalla ForgotPasswordScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        child: Text(
          languageProvider.currentLanguage == 'es'
              ? '¿Has olvidado tu contraseña?'
              : 'Forgot password?', // Texto dinámico
          style: const TextStyle(
            color: Color.fromRGBO(255, 34, 174, 1),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}