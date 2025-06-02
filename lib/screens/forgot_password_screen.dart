import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../providers/language_provider.dart'; // Importa el LanguageProvider
import '../widgets/widgets_forgot_password_screen/header_image.dart';
import '../widgets/widgets_forgot_password_screen/reset_password_title.dart';
import '../widgets/widgets_forgot_password_screen/reset_password_subtitle.dart';
import '../widgets/widgets_forgot_password_screen/email_input.dart';
import '../widgets/widgets_forgot_password_screen/reset_password_button.dart';
import '../widgets/widgets_forgot_password_screen/back_to_login_link.dart';
import 'inicio_de_sesion.dart'; // Importa la pantalla InicioDeSesion
import 'verification_code_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para jsonEncode


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

void _handleResetPassword() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text.trim();
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.69:3000/enviar-codigo-verificacion'),
        headers: {'Content-Type': 'application/json'}, // ¡Importante!
        body: jsonEncode({'correo_electronico': email}), // Convertir a JSON
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationCodeScreen(email: email),
          ),
        );
      } else {
        final errorMessage = jsonDecode(response.body)['error'] ?? 
          (languageProvider.currentLanguage == 'es' 
            ? 'Error al enviar el código' 
            : 'Error sending code');
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.currentLanguage == 'es'
              ? 'Error de conexión: $e'
              : 'Connection error: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  void _handleBackToLogin() {
    // Navegar a la pantalla de inicio de sesión
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InicioDeSesion(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF1B1B1B), // Fondo oscuro
            ),
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con fondo rosa
                const HeaderImage(),

                // Form section
                Padding(
                  padding: const EdgeInsets.fromLTRB(35, 23, 35, 51),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título de restablecer contraseña
                        const ResetPasswordTitle(),

                        const SizedBox(height: 43),

                        // Subtítulo de restablecer contraseña
                        const ResetPasswordSubtitle(),

                        const SizedBox(height: 49),

                        // Campo de correo electrónico
                        EmailInput(controller: _emailController),

                        const SizedBox(height: 50),

                        // Botón para restablecer contraseña
                        ResetPasswordButton(
                          onPressed: _handleResetPassword,
                        ),

                        const SizedBox(height: 19),

                        // Enlace para volver al inicio de sesión
                        BackToLoginLink(
                          onPressed: _handleBackToLogin,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}