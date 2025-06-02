import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'inicio_de_sesion.dart';
import 'package:http/http.dart' as http;

class NewPasswordScreen extends StatefulWidget {
  final String email;

  const NewPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'es'
                  ? 'Las contraseñas no coinciden'
                  : 'Passwords do not match',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Aquí deberías hacer la llamada a tu API para actualizar la contraseña
      
      
      final response = await http.post(
        Uri.parse('http://192.168.1.69:3000/actualizar-contrasena'),
        body: {
          'correo_electronico': widget.email,
          'nueva_contrasena': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'es'
                  ? 'Contraseña actualizada con éxito'
                  : 'Password updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => InicioDeSesion()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'es'
                  ? 'Error al actualizar la contraseña'
                  : 'Error updating password',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      

      // TEMPORAL: Simulación de actualización exitosa
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'es'
                ? 'Contraseña actualizada con éxito'
                : 'Password updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const InicioDeSesion()),
        (Route<dynamic> route) => false,
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
                      Icons.lock_reset,
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
                              ? 'Nueva Contraseña'
                              : 'New Password',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          languageProvider.currentLanguage == 'es'
                              ? 'Cree una nueva contraseña para su cuenta'
                              : 'Create a new password for your account',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 40),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: languageProvider.currentLanguage == 'es'
                                ? 'Nueva Contraseña'
                                : 'New Password',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[800],
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.currentLanguage == 'es'
                                  ? 'Por favor ingrese una contraseña'
                                  : 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return languageProvider.currentLanguage == 'es'
                                  ? 'La contraseña debe tener al menos 6 caracteres'
                                  : 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: languageProvider.currentLanguage == 'es'
                                ? 'Confirmar Contraseña'
                                : 'Confirm Password',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[800],
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return languageProvider.currentLanguage == 'es'
                                  ? 'Por favor confirme la contraseña'
                                  : 'Please confirm password';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _updatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF22AE), // Fondo rosa
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              languageProvider.currentLanguage == 'es'
                                  ? 'Actualizar Contraseña'
                                  : 'Update Password',
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