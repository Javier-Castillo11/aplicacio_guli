import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../providers/language_provider.dart';
import '../constants/app_colors.dart';
import 'homepage.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                languageProvider.currentLanguage == 'es'
                    ? 'Para completar su registro, conteste lo siguiente:'
                    : 'To complete your registration, answer the following:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                languageProvider.currentLanguage == 'es'
                    ? 'Usted se registra a la app como:'
                    : 'You are registering to the app as:',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _selectRole(context, 'healthcare_professional'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  languageProvider.currentLanguage == 'es'
                      ? 'Profesionista en la salud'
                      : 'Healthcare Professional',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectRole(context, 'paciente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  languageProvider.currentLanguage == 'es' ? 'Paciente' : 'Patient',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
Future<void> _selectRole(BuildContext context, String roleKey) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    print('ID del usuario en SharedPreferences: $userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    if (roleKey == 'healthcare_professional') {
      _showVerificationDialog(context, roleKey, userId);
      return;
    } else {
      await _guardarRolEnServidor(userId, roleKey);
      await prefs.setString('tipo_perfil', roleKey == 'healthcare_professional' ? 'profesional' : 'paciente');

      print('ROL GUARDADO SharedPreferences: $roleKey');
      
      _irAInicio(context, );
    }
  }


  Future<void> _guardarRolEnServidor(int userId, String roleKey) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.69:3000/guardarRol'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_usuario': userId,
        'tipo_perfil': roleKey == 'healthcare_professional' ? 'profesional' : 'paciente',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al guardar el perfil');
    }
  }

  void _irAInicio(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Homepage()),
    );
  }

Future<String?> _getUserEmail(int userId) async {
  final response = await http.post(
    Uri.parse('http://192.168.1.69:3000/obtenerCorreo'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'id_usuario': userId}), // NOMBRE CORRECTO
  );

  print('Respuesta de obtenerCorreo: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['correo'];
  } else {
    return null;
  }
}



  Future<void> _showVerificationDialog(BuildContext context, String roleKey, int userId) async {
    final email = await _getUserEmail(userId);
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener el correo electrónico')),
      );
      return;
    }

    final sent = await _sendVerificationCode(email);
    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar el código de verificación')),
      );
      return;
    }

    final codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Verificación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Introduce el código enviado a tu correo:'),
            const SizedBox(height: 10),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(hintText: 'Código'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Verificar'),
            onPressed: () async {
              final code = codeController.text.trim();
              final verified = await _verifyCode(email, code);

              if (verified) {
                final prefs = await SharedPreferences.getInstance();
           await _guardarRolEnServidor(userId, roleKey);
await prefs.setString('tipo_perfil', roleKey == 'healthcare_professional' ? 'profesional' : 'paciente');

                print('ROL GUARDADO SharedPreferences: $roleKey');
                Navigator.pop(context); // cerrar diálogo
                _irAInicio(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código incorrecto')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _sendVerificationCode(String email) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.69:3000/enviar-codigo-verificacion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo_electronico': email}),
    );
    return response.statusCode == 200;
  }

  Future<bool> _verifyCode(String email, String code) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.69:3000/verificar-codigo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo_electronico': email,
        'codigo_ingresado': code,
      }),
    );
    return response.statusCode == 200;
  }
}
