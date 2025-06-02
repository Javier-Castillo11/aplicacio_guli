import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa SharedPreferences
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../widgets/widgets_homepage/header_section.dart';
import '../widgets/widgets_signal_view/menu_bar.dart' as my_menu;
import '../widgets/widgets_signal_view/back_button.dart' as my_back;
import '../widgets/widgets_signal_view/comment_section.dart';
import '../screens/grafica_screen.dart';
import '../screens/sound_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class SignalViewScreen extends StatefulWidget {
  final int signalId;  
  final String signalType; // Tipo de señal: 'ECG' o 'FCG'
  final String patientName; // Nombre del paciente
  //final String signalData; // Datos de la señal (simulado como String)
  //final String? archivo; // Archivo de la señal (.hea)

  const SignalViewScreen({
    Key? key,
    required this.signalId,
    required this.signalType,
    required this.patientName,
  }) : super(key: key);

  @override
  _SignalViewScreenState createState() => _SignalViewScreenState();
}



class _SignalViewScreenState extends State<SignalViewScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController(); // Nuevo

late Future<Map<String, dynamic>> _signalFuture;
final AudioPlayer _player = AudioPlayer();

@override
void initState() {
  super.initState();
  _signalFuture = fetchSignalData(widget.signalId);
}

  ////
Future<Map<String, dynamic>> fetchSignalData(int id) async {
  // Determina el endpoint según el tipo de señal
  final endpoint = widget.signalType == 'ECG' ? 'ecg' : 'fcg';
  final uri = Uri.parse('http://192.168.1.69:3000/$endpoint/$id');
  
  final resp = await http.get(uri);
  if (resp.statusCode != 200) {
    throw Exception('Error al obtener la señal ${resp.statusCode}');
  }
  
  final data = jsonDecode(resp.body) as Map<String, dynamic>;
  
  // Asegura que los datos tengan la estructura esperada
  return {
    'patientId': data['patient_id'] ?? '0', // Ajusta según tu API
    'signalData': data['signal_data'] ?? [],
    'audioBase64': data['audio_base64'] ?? '', // Solo para FCG
    'patientName': data['patient_name'] ?? widget.patientName,
    // Agrega otros campos necesarios
  };
}
///

@override
void dispose() {
  _player.dispose();
   _commentController.dispose();
    _diagnosisController.dispose();
  super.dispose();
}
 

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

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
                      
                      // Header section
                        HeaderSection(
                       
                      ),

                      // Título dinámico según el tipo de señal
                      Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Text(
                          languageProvider.currentLanguage == 'es'
                              ? 'Señal ${widget.signalType} ${widget.patientName}'
                              : '${widget.signalType} Signal ${widget.patientName}',
                          style: TextStyle(
                            fontFamily: 'Inria Serif',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botón para abrir la gráfica en una nueva ventana
                      Container(
                        height: 200,
                        margin: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3E3E3),
                          borderRadius: BorderRadius.circular(10),
                        ),
child: Center(
  child: FutureBuilder<Map<String, dynamic>>(
    future: _signalFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text(
          languageProvider.currentLanguage == 'es'
              ? 'Error al cargar la señal'
              : 'Failed to load signal',
          style: TextStyle(color: Colors.red),
        );
      } else if (!snapshot.hasData || snapshot.data == null) {
        return Text(
          languageProvider.currentLanguage == 'es'
              ? 'Datos no disponibles'
              : 'No data available',
        );
      }

      final signalData = snapshot.data!;
      final String base64Audio = signalData['audioBase64'] ?? '';
      //final String fileName = signalData['fileName'] ?? 'sin_nombre.wav';
      final String patientId = signalData['patientId'] ?? 'sin_id';

      return ElevatedButton(
        onPressed: () {
          if (widget.signalType == 'ECG') {

      


            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GraficaScreen(
                  patientId: patientId,
                  signalType: SignalType.ecg,
                  signalId: widget.signalId.toString(),
                  //assetPath: 'signals/$fileName',
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SoundScreen(
                  patientId: patientId,
                  signalId: widget.signalId.toString(),
                  base64Audio: base64Audio,
                  //assetPath: 'signals/$fileName',
                ),
              ),
            );
          }
        },
        child: Text(
          languageProvider.currentLanguage == 'es'
              ? 'Abrir señal'
              : 'Open signal',
          style: TextStyle(
            fontFamily: 'Inria Serif',
            fontSize: 16,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
    },
  ),
),

  ),

// Sección de Comentario 
CommentSection(controller: _commentController),

const SizedBox(height: 16),

// NUEVO: Campo para el diagnóstico resumido
TextField(
  controller: _diagnosisController,
  decoration: InputDecoration(
    labelText: languageProvider.currentLanguage == 'es' 
        ? 'Diagnóstico' 
        : 'Diagnosis',
    border: OutlineInputBorder(),
    filled: true,
    fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
  ),
  style: TextStyle(
    fontFamily: 'Inria Serif',
    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
  ),
  maxLines: 1,
),

const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _sendDiagnosisToServer(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF22AE),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            languageProvider.currentLanguage == 'es'
                                ? 'Enviar'
                                : 'Send',
                            style: TextStyle(
                              fontFamily: 'Inria Serif',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Positioned(
                    top: 8,
                    child: my_menu.MenuBar(),
                  ),
                  Positioned(
                    bottom: 10,
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
  }






  // Función para enviar el diagnóstico al servidor
Future<void> _sendDiagnosisToServer(BuildContext context) async {
  final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
  final String comment = _commentController.text.trim();
  final String diagnosis = _diagnosisController.text.trim();

  if (comment.isEmpty || diagnosis.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          languageProvider.currentLanguage == 'es'
              ? 'Por favor, completa ambos campos.'
              : 'Please fill both fields.',
        ),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? userId = prefs.getInt('userId'); // Obtén el ID del usuario directamente de SharedPreferences

    if (token == null || userId == null) {
      throw Exception(languageProvider.currentLanguage == 'es'
          ? 'Sesión no válida. Por favor, inicia sesión nuevamente.'
          : 'Invalid session. Please log in again.');
    }

    print('User ID obtenido: $userId'); // Debug

    final response = await http.post(
      Uri.parse('http://192.168.1.69:3000/guardar-diagnostico'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id_senal': widget.signalId,
        'id_profesional': userId, // Usa el userId de SharedPreferences
        'diagnostico_resumen': diagnosis,
        'comentario': comment,
        'es_urgente': false,
      }),
    );

    print('Respuesta del servidor: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.currentLanguage == 'es'
                ? 'Diagnóstico enviado con éxito.'
                : 'Diagnosis sent successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _commentController.clear();
      _diagnosisController.clear();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Error desconocido');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          languageProvider.currentLanguage == 'es'
              ? 'Error al enviar diagnóstico: ${e.toString()}'
              : 'Error sending diagnosis: ${e.toString()}',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

}