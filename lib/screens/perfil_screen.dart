import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/widgets_homepage/header_section.dart';
import '../widgets/widgets_perfil_screen/menu_bar.dart' as my_menu;
import '../widgets/widgets_perfil_screen/back_button.dart' as my_back;
import '../widgets/widgets_perfil_screen/user_info.dart';
import '../constants/app_colors.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _obtenerDatosPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      if (token.isEmpty) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.69:3000/obtener-perfil-completo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Respuesta del servidor: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final datos = responseData['datos'];
          
          return {
            'nombre': datos['nombre_completo'] ?? 'Usuario',
            'correo': datos['correo_electronico'] ?? 'No disponible',
            'tipo_perfil': datos['tipo_perfil'] ?? 'paciente',
            'fecha_registro': datos['fecha_registro'] ?? 'No disponible',
            'ultimo_login': datos['ultimo_login'] ?? 'No disponible'
          };
        } else {
          throw Exception(responseData['error'] ?? 'Error desconocido');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor vuelve a iniciar sesión');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener datos del perfil: $e');
      throw Exception('Error al cargar los datos del perfil');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _obtenerDatosPerfil(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    languageProvider.currentLanguage == 'es'
                      ? 'Error al cargar los datos'
                      : 'Error loading data',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : AppColors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PerfilScreen()),
                      );
                    },
                    child: Text(languageProvider.currentLanguage == 'es' ? 'Reintentar' : 'Retry'),
                  ),
                ],
              ),
            );
          }

          final datosPerfil = snapshot.data ?? {};
          final nombreUsuario = datosPerfil['nombre'] ?? 'Usuario';
          final correoUsuario = datosPerfil['correo'] ?? 'No disponible';
          final fechaRegistro = datosPerfil['fecha_registro'] ?? 'No disponible';
          final ultimoLogin = datosPerfil['ultimo_login'] ?? 'No disponible';
          final tipoPerfil = datosPerfil['tipo_perfil']?.toString().toLowerCase() ?? 'paciente';

          final String profileTitle = tipoPerfil.contains('profesional')
              ? (languageProvider.currentLanguage == 'es' 
                  ? 'Perfil Profesional' 
                  : 'Professional Profile')
              : (languageProvider.currentLanguage == 'es' 
                  ? 'Perfil del Paciente' 
                  : 'Patient Profile');

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
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
                          HeaderSection(),
                          
                          // Sección de título
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: themeProvider.isDarkMode 
                                    ? Colors.grey[700]! 
                                    : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              profileTitle,
                              style: TextStyle(
                                fontFamily: 'Inria Serif',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode ? Colors.white : AppColors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Sección de información básica
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: themeProvider.isDarkMode 
                                    ? Colors.grey[700]! 
                                    : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                UserInfo(
                                  label: languageProvider.currentLanguage == 'es' ? 'Nombre' : 'Name',
                                  value: nombreUsuario,
                                ),
                                const SizedBox(height: 16),
                                UserInfo(
                                  label: languageProvider.currentLanguage == 'es'
                                    ? 'Correo electrónico'
                                    : 'Email',
                                  value: correoUsuario,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Sección de detalles de cuenta
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: themeProvider.isDarkMode 
                                    ? Colors.grey[700]! 
                                    : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                UserInfo(
                                  label: languageProvider.currentLanguage == 'es'
                                    ? 'Rol de usuario'
                                    : 'User role',
                                  value: tipoPerfil.contains('profesional')
                                      ? (languageProvider.currentLanguage == 'es' 
                                          ? 'Profesional' 
                                          : 'Professional')
                                      : (languageProvider.currentLanguage == 'es' 
                                          ? 'Paciente' 
                                          : 'Patient'),
                                ),
                                const SizedBox(height: 16),
                                UserInfo(
                                  label: languageProvider.currentLanguage == 'es'
                                    ? 'Fecha de registro'
                                    : 'Registration date',
                                  value: fechaRegistro,
                                ),
                                const SizedBox(height: 16),
                                UserInfo(
                                  label: languageProvider.currentLanguage == 'es'
                                    ? 'Último acceso'
                                    : 'Last login',
                                  value: ultimoLogin,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const Positioned(
                        top: 8,
                        child: my_menu.MenuBar(),
                      ),

                      Positioned(
                        bottom: 20,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const my_back.BackButton(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}