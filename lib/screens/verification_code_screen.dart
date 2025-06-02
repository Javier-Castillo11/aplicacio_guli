import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'new_password_screen.dart';
//import '../constants/app_colors.dart';
import 'package:http/http.dart' as http;

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({Key? key, required this.email}) : super(key: key);

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  void _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      // Aquí deberías hacer la llamada a tu API para verificar el código
    
      
      final response = await http.post(
        Uri.parse('http://192.168.1.69:3000/verificar-codigo'),
        body: {
          'correo_electronico': widget.email,
          'codigo_ingresado': _codeController.text,
        },
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordScreen(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'es'
                  ? 'Código incorrecto. Intente de nuevo.'
                  : 'Incorrect code. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      

      // TEMPORAL: Simulación de verificación exitosa
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordScreen(email: widget.email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

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
                // Header con fondo rosa
                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8BBD0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.verified_user,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Form section
                Padding(
                  padding: const EdgeInsets.fromLTRB(35, 23, 35, 51),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageProvider.currentLanguage == 'es'
                              ? 'Verificación de Código'
                              : 'Code Verification',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          languageProvider.currentLanguage == 'es'
                              ? 'Ingrese el código de 4 dígitos que fue enviado a ${widget.email}'
                              : 'Enter the 4-digit code sent to ${widget.email}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 40),

                        TextFormField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: languageProvider.currentLanguage == 'es'
                                ? 'Código de verificación'
                                : 'Verification Code',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[800],
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.currentLanguage == 'es'
                                  ? 'Por favor ingrese el código'
                                  : 'Please enter the code';
                            }
                            if (value.length != 4) {
                              return languageProvider.currentLanguage == 'es'
                                  ? 'El código debe tener 4 dígitos'
                                  : 'Code must be 4 digits';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _verifyCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF22AE), // Fondo rosa
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              languageProvider.currentLanguage == 'es'
                                  ? 'Verificar Código'
                                  : 'Verify Code',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
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