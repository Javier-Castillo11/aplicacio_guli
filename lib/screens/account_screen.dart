import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/widgets_account_screen/menu_bar.dart' as my_menu;
import '../widgets/widgets_account_screen/back_button.dart' as my_back;
import '../widgets/widgets_account_screen/profile_picture.dart';
import '../widgets/widgets_homepage/header_section.dart';
import '../constants/app_colors.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  // Función para obtener datos del usuario desde el servidor
 Future<Map<String, dynamic>> _getSecureUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtención segura de todos los datos necesarios
      final token = prefs.getString('token') ?? '';
      final userId = prefs.get('userId')?.toString() ?? ''; // Conversión segura a String
      final userEmail = prefs.getString('userEmail') ?? '';
      final userRole = prefs.getString('userRole') ?? '';

      // Verificación de datos mínimos requeridos
      if (token.isEmpty || userId.isEmpty) {
        throw Exception('Sesión no válida. Por favor inicie sesión nuevamente');
      }

      // Intento de obtener datos frescos del servidor
      try {
        final serverResponse = await http.get(
          Uri.parse('http://192.168.1.69:3000/obtener-datos-usuario'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (serverResponse.statusCode == 200) {
          final serverData = json.decode(serverResponse.body);
          return {
            'correo_electronico': serverData['correo_electronico']?.toString() ?? userEmail,
            'tipo_perfil': serverData['tipo_perfil']?.toString() ?? userRole,
          };
        }
      } catch (e) {
        // Si falla la conexión con el servidor, usamos los datos locales
        print('Error al conectar con el servidor: $e');
      }

      // Datos de respaldo desde SharedPreferences
      return {
        'correo_electronico': userEmail,
        'tipo_perfil': userRole.isNotEmpty ? userRole : 'sin_definir',
      };
    } catch (e) {
      print('Error crítico al obtener datos: $e');
      throw Exception('No se pudieron cargar los datos del usuario');
    }
  }

  // Función para enviar código de verificación
Future<void> _sendVerificationCode(String email, BuildContext context) async {
  final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
  
  // VALIDACIÓN EXTRA PARA EL CORREO
  if (email.isEmpty || !email.contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(languageProvider.currentLanguage == 'es' 
            ? 'Correo electrónico no válido'
            : 'Invalid email address'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    print('Enviando código a: $email'); // DEBUG
    
    final response = await http.post(
      Uri.parse('http://192.168.1.69:3000/enviar-codigo-verificacion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo_electronico': email.trim()}),
    );

    print('Respuesta del servidor: ${response.body}'); // DEBUG

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.currentLanguage == 'es'
                ? 'Código enviado a $email'
                : 'Code sent to $email',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Error desconocido';
      throw Exception(error);
    }
  } catch (e) {
    print('Error al enviar código: $e'); // DEBUG
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          languageProvider.currentLanguage == 'es'
              ? 'Error al enviar código: ${e.toString().replaceAll("Exception: ", "")}'
              : 'Failed to send code: ${e.toString().replaceAll("Exception: ", "")}',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  // Función para verificar código y cambiar contraseña
Future<void> _verifyCodeAndChangePassword(
  String email, 
  String code, 
  String newPassword,
  BuildContext context,
) async {
  final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
  
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.69:3000/cambio-contrasena-app'), // Nueva ruta
      body: json.encode({
        'correo': email,
        'codigo_verificacion': code,
        'nueva_contrasena': newPassword,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    final responseData = json.decode(response.body);
    
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.currentLanguage == 'es'
                ? 'Contraseña cambiada exitosamente'
                : 'Password changed successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      throw Exception(responseData['error'] ?? 'Error desconocido');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          languageProvider.currentLanguage == 'es'
              ? 'Error: ${e.toString()}'
              : 'Error: ${e.toString()}',
        ),
        backgroundColor: Colors.red,
      ),
    );
    rethrow;
  }
}

  // Diálogo de cambio de contraseña actualizado
void _showChangePasswordDialog(BuildContext context, String userEmail) async {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
  
  // VERIFICACIÓN DEL CORREO (ahora viene como parámetro)
  final email = userEmail.trim();
  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(languageProvider.currentLanguage == 'es'
            ? 'No se encontró el correo electrónico'
            : 'Email not found'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final _newPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool _codeSent = false;

  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Theme(
              data: themeProvider.currentTheme,
              child: AlertDialog(
                title: Text(
                  languageProvider.currentLanguage == 'es'
                      ? 'Cambiar contraseña'
                      : 'Change Password',
                  style: TextStyle(
                    fontFamily: 'Inria Serif',
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_codeSent) ...[
                        Text(
                          languageProvider.currentLanguage == 'es'
                              ? 'Se enviará un código de verificación a $email'
                              : 'A verification code will be sent to $email',
                          style: TextStyle(
                            fontFamily: 'Inria Serif',
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (_codeSent) ...[
                        TextField(
                          controller: _verificationCodeController,
                          decoration: InputDecoration(
                            labelText: languageProvider.currentLanguage == 'es'
                                ? 'Código de verificación'
                                : 'Verification Code',
                            labelStyle: TextStyle(
                              fontFamily: 'Inria Serif',
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: languageProvider.currentLanguage == 'es'
                                ? 'Nueva contraseña'
                                : 'New Password',
                            labelStyle: TextStyle(
                              fontFamily: 'Inria Serif',
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      languageProvider.currentLanguage == 'es' ? 'Cancelar' : 'Cancel',
                      style: TextStyle(
                        fontFamily: 'Inria Serif',
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (!_codeSent) {
                        try {
                          await _sendVerificationCode(email, context);
                          setState(() => _codeSent = true);
                        } catch (e) {
                          // El error ya se muestra en el snackbar
                        }
                      } else {
                        try {
                          await _verifyCodeAndChangePassword(
                            email,
                            _verificationCodeController.text,
                            _newPasswordController.text,
                            context,
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          // El error ya se muestra en el snackbar
                        }
                      }
                    },
                    child: Text(
                      _codeSent
                          ? (languageProvider.currentLanguage == 'es'
                              ? 'Guardar'
                              : 'Save')
                          : (languageProvider.currentLanguage == 'es'
                              ? 'Enviar código'
                              : 'Send Code'),
                      style: TextStyle(
                        fontFamily: 'Inria Serif',
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getSecureUserData(),
      builder: (context, snapshot) {
        // Manejo de estados de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Cargando información...'),
                ],
              ),
            ),
          );
        }

        // Manejo de errores mejorado
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AccountScreen()),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    ),
                    child: const Text('Ir al login'),
                  ),
                ],
              ),
            ),
          );
        }

        // Verificación de datos
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 50),
                  SizedBox(height: 20),
                  Text('No se encontraron datos del usuario'),
                ],
              ),
            ),
          );
        }

        final userData = snapshot.data!;
        final themeProvider = Provider.of<ThemeProvider>(context);
        final languageProvider = Provider.of<LanguageProvider>(context);

// Conversión segura del rol
        final roleKey = userData['tipo_perfil']?.toString().toLowerCase() ?? '';
        final userRole = roleKey.contains('healthcare') || roleKey.contains('profesional')
            ? (languageProvider.currentLanguage == 'es'
                ? 'Profesional de salud'
                : 'Healthcare Professional')
            : (languageProvider.currentLanguage == 'es'
                ? 'Paciente'
                : 'Patient');

        return Scaffold(
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.fromLTRB(35, 22, 35, 68),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HeaderSection(),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const ProfilePicture(),
                                const SizedBox(height: 16),
                                Text(
                                  userRole,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode 
                                        ? Colors.white 
                                        : AppColors.black,
                                    fontFamily: 'Inria Serif',
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ListTile(
                                  leading: Icon(Icons.email, color: AppColors.primary),
                                  title: Text(
                                    userData['correo_electronico']?.toString() ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Inria Serif',
                                      fontSize: 14,
                                      color: themeProvider.isDarkMode 
                                          ? Colors.white 
                                          : AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () => _showChangePasswordDialog(
    context, 
    userData['correo_electronico']?.toString() ?? ''
  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32, 
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),  
                            ),
                            child: Text(
                              languageProvider.currentLanguage == 'es'
                                  ? 'Cambiar contraseña'
                                  : 'Change Password',
                              style: TextStyle(
                                fontFamily: 'Inria Serif',
                                fontSize: 16,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen()
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary.withOpacity(0.8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32, 
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              languageProvider.currentLanguage == 'es'
                                  ? 'Cerrar sesión'
                                  : 'Log out',
                              style: TextStyle(
                                fontFamily: 'Inria Serif',
                                fontSize: 14,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                      const Positioned(
                        top: 8,
                        child: my_menu.MenuBar(),
                      ),
                      Positioned(
                        bottom: 20,
                        left: -8,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const my_back.BackButton(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}