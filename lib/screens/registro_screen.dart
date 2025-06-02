import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import '../providers/language_provider.dart'; // Importa el LanguageProvider
import '../widgets/widgets_registro/header_image.dart';
import '../widgets/widgets_registro/create_account_title.dart';
import '../widgets/widgets_registro/sign_up_subtitle.dart';
import '../widgets/widgets_registro/name_input.dart';
import '../widgets/widgets_registro/email_input.dart';
import '../widgets/widgets_registro/password_input.dart';
import '../widgets/widgets_registro/create_account_button.dart';
import 'login_screen.dart'; // Importa la pantalla de inicio de sesión
import 'role_selection_screen.dart'; // Importa la pantalla de selección de rol
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class RegistroScreen extends StatefulWidget {
  const RegistroScreen({Key? key}) : super(key: key);

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

void _handleCreateAccount() async {
  if (_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'es'
              ? 'Procesando registro'
              : 'Processing Registration',
        ),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.69:3000/registro'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre_completo': _nameController.text,
          'correo_electronico': _emailController.text,
          'contrasena': _passwordController.text,
        }),
      );

    if (response.statusCode == 201) {
  // Decodificar respuesta si el backend regresa el ID del usuario o token
  final data = jsonDecode(response.body);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', data['token']);
  await prefs.setString('nombre_completo', _nameController.text);
  await prefs.setString('correo_electronico', _emailController.text);
  await prefs.setString('token', data['token'] ?? ''); // si usas token
  await prefs.setInt('userId', data['userId']);



  // Navegar a selección de rol
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const RoleSelectionScreen(),
    ),
  );
}
 else {
        final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
        final errorMessage = jsonDecode(response.body)['error'] ?? 'Error desconocido';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.currentLanguage == 'es'
                  ? 'Error en el registro: $errorMessage'
                  : 'Registration error: $errorMessage',
            ),
          ),
        );
      }
    } catch (e) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.currentLanguage == 'es'
                ? 'Error al conectar con el servidor.'
                : 'Error connecting to the server.',
          ),
        ),
      );
    }
  }
}


  void _handleGoogleSignIn() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    // Aquí debes agregar la lógica para la autenticación con Google
    // Ejemplo usando Firebase Authentication:
    /*
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Registro exitoso, navegar a la pantalla de selección de rol
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const RoleSelectionScreen(),
          ),
        );
      }
    } else {
      // Mostrar error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.currentLanguage == 'es'
                ? 'Error en el registro con Google'
                : 'Google registration error',
          ),
        ),
      );
    }
    */

    // Lógica temporal para simular el registro con Google
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            languageProvider.currentLanguage == 'es' ? 'Advertencia' : 'Warning', // Texto dinámico
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languageProvider.currentLanguage == 'es'
                    ? '"Guli App" quiere usar "google.com" para iniciar sesión.'
                    : '"Guli App" wants to use "google.com" to log in.', // Texto dinámico
              ),
              const SizedBox(height: 10),
              Text(
                languageProvider.currentLanguage == 'es'
                    ? 'Esto permitirá que la aplicación y el sitio compartan información sobre usted.'
                    : 'This will allow the app and the site to share information about you.', // Texto dinámico
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: Text(
                languageProvider.currentLanguage == 'es' ? 'Cancelar' : 'Cancel', // Texto dinámico
              ),
            ),
            TextButton(
              onPressed: () {
                // Lógica para continuar con el registro usando Google
                Navigator.pop(context); // Cerrar el diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      languageProvider.currentLanguage == 'es'
                          ? 'Registro con Google exitoso'
                          : 'Registration with Google successful', // Texto dinámico
                    ),
                  ),
                );
                // Aquí puedes agregar la lógica para redirigir al usuario a su cuenta de Gmail
              },
              child: Text(
                languageProvider.currentLanguage == 'es' ? 'Continuar' : 'Continue', // Texto dinámico
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToLogin() {
    // Navegar a la pantalla de inicio de sesión
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF1B1B1B),
            ),
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with pink background
                SizedBox(
                  height: 100, // Reducir el tamaño del HeaderImage
                  child: HeaderImage(
                    onClosePressed: _navigateToLogin, // Pasar la función
                  ),
                ),

                // Form section
                Padding(
                  padding: const EdgeInsets.fromLTRB(35, 20, 35, 40), // Ajustar el padding superior
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Create Account title
                        CreateAccountTitle(),

                        const SizedBox(height: 35), // Reducido para igualar la referencia

                        // Sign up subtitle
                        SignUpSubtitle(),

                        const SizedBox(height: 35), // Reducido para igualar la referencia

                        // Name field
                        NameInput(controller: _nameController),

                        const SizedBox(height: 20),

                        // Email field
                        EmailInput(controller: _emailController),

                        const SizedBox(height: 20),

                        // Password field
                        PasswordInput(controller: _passwordController),

                        const SizedBox(height: 20),

                        // Create Account button
                        CreateAccountButton(
                          onPressed: _handleCreateAccount, // Pasar la función
                        ),

                        const SizedBox(height: 1),

                        // Separador con "or"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: const Color(0xFFFF22AE).withOpacity(0.5),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                languageProvider.currentLanguage == 'es' ? 'o' : 'or', // Texto dinámico
                                style: TextStyle(
                                  color: const Color(0xFFFF22AE).withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: const Color(0xFFFF22AE).withOpacity(0.5),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // Botón de registro con Google
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleGoogleSignIn,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.transparent,
                              side: BorderSide(
                                color: const Color(0xFFFF22AE).withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google.png', // Ruta de la imagen de Google
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  languageProvider.currentLanguage == 'es'
                                      ? 'Registrate con Google'
                                      : 'Sign up with Google', // Texto dinámico
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
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