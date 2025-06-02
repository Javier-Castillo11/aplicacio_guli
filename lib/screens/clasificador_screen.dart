import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../constants/app_colors.dart';
import '../widgets/widgets_subir_arch_screen/back_button.dart' as my_back;

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ClasificadorScreen extends StatefulWidget {
  const ClasificadorScreen({Key? key}) : super(key: key);

  @override
  State<ClasificadorScreen> createState() => _ClasificadorScreenState();
}

class _ClasificadorScreenState extends State<ClasificadorScreen> {
  String? _nombreArchivoSubido;
  String? _resultadoClasificacion;
  File? _archivoSeleccionado;
  bool _procesando = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final bool isDarkMode = themeProvider.isDarkMode;

    final Map<String, String> textos = {
      'titulo': languageProvider.currentLanguage == 'es'
          ? 'Clasificar Señal Cardíaca'
          : 'Classify Heart Signal',
      'formatos': languageProvider.currentLanguage == 'es'
          ? 'Formatos aceptados:'
          : 'Accepted formats:',
      'fcg': languageProvider.currentLanguage == 'es'
          ? 'Fonocardiograma (FCG): archivos .mp3 o .wav'
          : 'Phonocardiogram (FCG): .mp3 or .wav files',
      'subir': languageProvider.currentLanguage == 'es'
          ? 'Subir señal'
          : 'Upload signal',
      'clasificar': languageProvider.currentLanguage == 'es'
          ? 'Clasificar señal'
          : 'Classify signal',
      'resultado': languageProvider.currentLanguage == 'es'
          ? 'Resultado:'
          : 'Result:',
      'esperando': languageProvider.currentLanguage == 'es'
          ? 'Cargue un archivo para clasificar'
          : 'Upload a file to classify',
    };

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
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
                      // Sección principal de clasificación
                      Container(
                        margin: const EdgeInsets.only(top: 28),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              textos['titulo']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              textos['formatos']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• ${textos['fcg']}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Botón para subir archivo
                            ElevatedButton.icon(
                              onPressed: _procesando ? null : () => _subirArchivo(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: const Icon(Icons.cloud_upload, size: 22, color: Colors.white),
                              label: Text(
                                textos['subir']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Inria Serif',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (_nombreArchivoSubido != null) ...[
                              const SizedBox(height: 15),
                              Text(
                                _nombreArchivoSubido!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                            if (_archivoSeleccionado != null && _resultadoClasificacion == null) ...[
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _procesando ? null : _clasificarSenal,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary.withOpacity(0.3),
                                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                icon: const Icon(Icons.analytics, size: 22, color: Colors.white),
                                label: Text(
                                  textos['clasificar']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Inria Serif',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                            if (_procesando) ...[
                              const SizedBox(height: 20),
                              const CircularProgressIndicator(color: Colors.white),
                              const SizedBox(height: 10),
                              Text(
                                languageProvider.currentLanguage == 'es'
                                    ? 'Analizando señal cardíaca...'
                                    : 'Analyzing heart signal...',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_resultadoClasificacion != null) ...[
                        const SizedBox(height: 30),
                        Text(
                          textos['resultado']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _resultadoClasificacion!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ] else if (_archivoSeleccionado == null) ...[
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            textos['esperando']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Positioned(
                    bottom: 20,
                    left: -8,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
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
      ),
    );
  }

  Future<void> _subirArchivo(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav'],
        dialogTitle: languageProvider.currentLanguage == 'es'
            ? 'Seleccione su fonocardiograma'
            : 'Select your phonocardiogram',
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        PlatformFile file = result.files.first;
        String extension = file.extension?.toLowerCase() ?? '';

        if (extension != 'mp3' && extension != 'wav') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                languageProvider.currentLanguage == 'es'
                    ? 'Formato no válido. Use .mp3 o .wav para FCG'
                    : 'Invalid format. Use .mp3 or .wav for FCG',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 60),
            ),
          );
          return;
        }

        setState(() {
          _nombreArchivoSubido = file.name;
          _archivoSeleccionado = File(file.path!);
          _resultadoClasificacion = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.currentLanguage == 'es'
                  ? '${file.name} subido correctamente'
                  : '${file.name} uploaded successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.currentLanguage == 'es'
                ? 'Error al subir el archivo: ${e.toString()}'
                : 'Upload error: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _clasificarSenal() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (_archivoSeleccionado == null) return;

    setState(() {
      _procesando = true;
    });

    try {
      final uri = Uri.parse('http://192.168.1.69:3000/clasificar');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('audio', _archivoSeleccionado!.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final resultado = jsonDecode(response.body);
        setState(() {
          _resultadoClasificacion = resultado['diagnostico'];
        });
      } else {
        throw Exception('Error en el servidor: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.currentLanguage == 'es'
                ? 'Error al clasificar: ${e.toString()}'
                : 'Classification error: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _procesando = false;
      });
    }
  }
}
