import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../providers/language_provider.dart'; // Importa el LanguageProvider
import '../widgets/widgets_inicio_de_sesion/header_image.dart';
import '../widgets/widgets_inicio_de_sesion/title_subtitle.dart';
import '../widgets/widgets_inicio_de_sesion/email_input.dart';
import '../widgets/widgets_inicio_de_sesion/password_input.dart';
import '../widgets/widgets_inicio_de_sesion/login_button.dart';
import '../widgets/widgets_inicio_de_sesion/forgot_password_link.dart';
import 'homepage.dart'; // Importa la pantalla Homepage
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InicioDeSesion extends StatefulWidget {
  const InicioDeSesion({Key? key}) : super(key: key);

  @override
  State<InicioDeSesion> createState() => _InicioDeSesionState();
}

class _InicioDeSesionState extends State<InicioDeSesion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  // Función para manejar el inicio de sesión
void _login() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
final response = await http.post(
  Uri.parse('http://192.168.1.69:3000/login'), // o tu IP local real si estás en emulador o celular
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'correo_electronico': email,
    'contrasena': password,
  }),
);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Respuesta del backend: $data');
        final userId = data['userId'];
        final nombre = data['nombre_completo'];
        final tipoPerfil = data['tipo_perfil']; // Esto debe venir del backend

        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
await prefs.setString('token', data['token']);


        await prefs.setInt('userId', userId);
        await prefs.setString('nombre_completo', nombre);
        await prefs.setString('tipo_perfil', tipoPerfil);
        await prefs.setString('correo_electronico', email);


        // Navegar a la pantalla principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Homepage(),
          ),
        );
      } else {
        final errorMsg = jsonDecode(response.body)['error'] ?? 'Error desconocido';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'es'
                  ? errorMsg
                  : 'Incorrect email or password',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'es'
                ? 'Error de conexión con el servidor'
                : 'Server connection error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Accede al LanguageProvider

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(27, 27, 27, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formKey, // Asignar la clave del formulario
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Image
                  const HeaderImage(),

                  // Content Container
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 35),

                        // Title and Subtitle
                        TitleSubtitle(languageProvider: languageProvider),

                        const SizedBox(height: 48),

                        // Email Input
                        EmailInput(
                          controller: _emailController,
                          languageProvider: languageProvider,
                        ),

                        const SizedBox(height: 35),

                        // Password Input
                        PasswordInput(
                          controller: _passwordController,
                          languageProvider: languageProvider,
                        ),

                        const SizedBox(height: 50),

                        // Login Button
                        LoginButton(
                          onPressed: _login, // Usar la función _login
                          languageProvider: languageProvider,
                        ),

                        const SizedBox(height: 19),

                        // Forgot Password Link
                        ForgotPasswordLink(languageProvider: languageProvider),

                        const SizedBox(height: 33),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}