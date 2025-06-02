import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../providers/language_provider.dart'; // Importa el LanguageProvider
import '../widgets/widgets_login/logo_widget.dart';
import '../widgets/widgets_login/login_button.dart';
import '../widgets/widgets_login/register_text.dart';
import 'inicio_de_sesion.dart'; // Importa la pantalla InicioDeSesion
import 'registro_screen.dart'; // Importa la pantalla RegistroScreen

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480), // Ancho máximo de 480 (como un celular)
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(35, 22, 35, 68), // Mismos márgenes que el diseño original
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
              crossAxisAlignment: CrossAxisAlignment.center, // Centrar horizontalmente
              children: [
                // Espacio para centrar el logo
                SizedBox(height: screenHeight * 0.2), // 20% de la altura de la pantalla

                // Logo (centrado)
                const LogoWidget(),

                // Espacio entre el logo y el botón
                const SizedBox(height: 280), // Espacio fijo como en el diseño original

                // Login Button
                LoginButton(
                  text: languageProvider.currentLanguage == 'es'
                      ? 'Iniciar sesión'
                      : 'Login', // Texto dinámico
                  onPressed: () {
                    // Navegar a InicioDeSesion
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InicioDeSesion(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16), // Espacio entre el botón y el texto

                // Register Text (centrado)
                Center(
                  child: RegisterText(
                    text: languageProvider.currentLanguage == 'es'
                        ? '¿Aún no tienes cuenta? '
                        : 'Don\'t have an account yet? ', // Texto dinámico
                    onPressed: () {
                      // Navegar a RegistroScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistroScreen(),
                        ),
                      );
                    },
                  ),
                ),

                // Espacio adicional para evitar que el contenido se corte
                SizedBox(height: screenHeight * 0.2), // 20% de la altura de la pantalla
              ],
            ),
          ),
        ),
      ),
    );
  }
}