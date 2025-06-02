import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/widgets_homepage/header_section.dart';
import '../widgets/widgets_subir_arch_screen/menu_bar.dart' as my_menu;
import '../widgets/widgets_subir_arch_screen/back_button.dart' as my_back;
import '../constants/app_colors.dart';
import '../screens/comentario_screen.dart';
import '../widgets/widgets_subir_arch_screen/filter_menu.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 

class SubirArchScreen extends StatefulWidget {
  const SubirArchScreen({Key? key}) : super(key: key);

  @override
  State<SubirArchScreen> createState() => _SubirArchScreenState();
}

class _SubirArchScreenState extends State<SubirArchScreen> {
  String _filtroSeleccionado = 'reciente';
  bool _isLoading = true;
  late List<Map<String, dynamic>> _comentarios = [];
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDiagnosticos();
      _pruebaConexionDirecta();
    });
  }

Future<void> _cargarDiagnosticos() async {
  final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
  setState(() => _isLoading = true);
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');
    
    print('Usuario ID: $userId, Token: ${token != null ? "válido" : "nulo"}');

    if (token == null || userId == null) {
      throw Exception('Sesión inválida');
    }

    final stopwatch = Stopwatch()..start();
    final response = await http.get(
      Uri.parse('http://192.168.1.69:3000/diagnosticos-por-paciente'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('Respuesta recibida en ${stopwatch.elapsedMilliseconds}ms');
    print('Código de estado: ${response.statusCode}');
    print('Contenido de respuesta: ${response.body}');

    if (response.statusCode == 200) {
      // CAMBIO PRINCIPAL: Parsear como Map en lugar de List
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print('Datos recibidos (estructura completa): $responseData');
      
      // Verificar si la respuesta tiene la estructura esperada
      if (responseData['success'] == true) {
        final List<dynamic> diagnosticos = responseData['diagnosticos'] ?? [];
        print('Número de diagnósticos recibidos: ${diagnosticos.length}');
        
        if (diagnosticos.isEmpty) {
          print('ADVERTENCIA: El array de diagnósticos está vacío');
        }

        setState(() {
          _comentarios = diagnosticos.map((d) => _formatearDiagnostico(d)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception(responseData['error'] ?? 'Error en la respuesta del servidor');
      }
    } else {
      final errorMsg = jsonDecode(response.body)?['error'] ?? 'Error desconocido';
      throw Exception('$errorMsg (código ${response.statusCode})');
    }
  } catch (e) {
    print('Error completo: $e');
    if (e is TypeError) {
      print('Error de tipo: Verifica la estructura de la respuesta JSON');
    }
    setState(() => _isLoading = false);
    final errorMsg = e.toString().replaceAll(RegExp(r'^Exception: '), '');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          languageProvider.currentLanguage == 'es'
              ? 'Error: $errorMsg'
              : 'Error: $errorMsg'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}



// Prueba este endpoint temporal en Flutter SOLO PARA DIAGNÓSTICO
Future<void> _pruebaConexionDirecta() async {
  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.69:3000/todos-diagnosticos-debug'),
    );
    
    print('RESPUESTA CRUDA: ${response.body}');
    final data = jsonDecode(response.body);
    print('Diagnósticos existentes en total: ${data.length}');
    print('Filtrados para paciente 12: ${
      data.where((d) => d['id_paciente'] == 12).toList()
    }');
  } catch (e) {
    print('Error en prueba directa: $e');
  }
}




  Map<String, dynamic> _formatearDiagnostico(dynamic diagnostico) {
    DateTime? fecha;
    try {
      if (diagnostico['fecha_diagnostico'] != null) {
        fecha = DateTime.parse(diagnostico['fecha_diagnostico']);
      }
    } catch (e) {
      print('Error parseando fecha: $e');
    }

    return {
      'id': diagnostico['id_diagnostico'],
      'profesional': diagnostico['profesional_nombre'] ?? 'Profesional no disponible',
      'fecha': fecha != null 
          ? '${fecha.day}/${fecha.month}/${fecha.year}' 
          : 'Fecha no disponible',
      'comentario': diagnostico['comentario'] ?? 'Sin comentario',
      'tipoArchivo': diagnostico['tipo_senal'] ?? 'FCG',
      'nombreArchivo': diagnostico['ruta_archivo']?.split('/').last ?? 'archivo.dat',
      'diagnostico': diagnostico['diagnostico_resumen'] ?? 'Sin diagnóstico',
      'fechaOriginal': diagnostico['fecha_diagnostico'],
      'esUrgente': diagnostico['es_urgente'] == 1,
      'idSenal': diagnostico['id_senal'],
    };
  }

  List<Map<String, dynamic>> _filtrarComentarios() {
    final comentarios = List<Map<String, dynamic>>.from(_comentarios);
    
    switch (_filtroSeleccionado) {
      case 'reciente':
        comentarios.sort((a, b) {
          final fechaA = DateTime.tryParse(a['fechaOriginal'] ?? '') ?? DateTime(1970);
          final fechaB = DateTime.tryParse(b['fechaOriginal'] ?? '') ?? DateTime(1970);
          return fechaB.compareTo(fechaA);
        });
        return comentarios;
      case '30dias':
        final hace30Dias = DateTime.now().subtract(const Duration(days: 30));
        return comentarios.where((comentario) {
          final fecha = DateTime.tryParse(comentario['fechaOriginal'] ?? '') ?? DateTime(1970);
          return fecha.isAfter(hace30Dias);
        }).toList();
      case 'antiguo':
        comentarios.sort((a, b) {
          final fechaA = DateTime.tryParse(a['fechaOriginal'] ?? '') ?? DateTime(1970);
          final fechaB = DateTime.tryParse(b['fechaOriginal'] ?? '') ?? DateTime(1970);
          return fechaA.compareTo(fechaB);
        });
        return comentarios;
      default:
        return comentarios;
    }
  }

  Future<void> _subirArchivo(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['dat', 'mp3'],
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        String extension = file.extension?.toLowerCase() ?? '';
        
        if (extension != 'dat' && extension != 'mp3') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                languageProvider.currentLanguage == 'es'
                    ? 'Formato no válido. Use .dat para ECG o .mp3 para FCG'
                    : 'Invalid format. Use .dat for ECG or .mp3 for FCG'
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await _enviarArchivoAlClasificador(file, context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.currentLanguage == 'es'
                  ? '${file.name} subido correctamente'
                  : '${file.name} uploaded successfully'
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Recargar los comentarios después de subir un archivo
        _cargarDiagnosticos();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.currentLanguage == 'es'
                ? 'Error al subir el archivo: ${e.toString()}'
                : 'Upload error: ${e.toString()}'
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _enviarArchivoAlClasificador(PlatformFile file, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final uri = Uri.parse('http://192.168.1.69:3000/subirsenales');
    final request = http.MultipartRequest('POST', uri);

    request.fields['id_paciente'] = userId.toString();
    request.fields['tipo_senal'] = file.extension == 'dat' ? 'ECG' : 'FCG';
    request.fields['datos_senal'] = 'Datos de señal subidos';

    request.files.add(
      await http.MultipartFile.fromPath(
        'archivo',
        file.path!,
        filename: file.name,
      ),
    );

    final response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Error al subir archivo: ${response.statusCode}');
    }
  }

  void _verComentarioCompleto(BuildContext context, Map<String, dynamic> comentario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComentarioScreen(comentario: comentario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    final textos = {
      'titulo': languageProvider.currentLanguage == 'es' 
          ? 'Subir Señales Médicas' 
          : 'Upload Medical Signals',
      'formatos': languageProvider.currentLanguage == 'es' 
          ? 'Formatos aceptados:' 
          : 'Accepted formats:',
      'ecg': languageProvider.currentLanguage == 'es' 
          ? 'Electrocardiograma (ECG): archivo .dat' 
          : 'Electrocardiogram (ECG): .dat file',
      'fcg': languageProvider.currentLanguage == 'es' 
          ? 'Fonocardiograma (FCG): archivo .mp3' 
          : 'Phonocardiogram (FCG): .mp3 file',
      'subir': languageProvider.currentLanguage == 'es' 
          ? 'Subir señal' 
          : 'Upload signal',
      'comentarios': languageProvider.currentLanguage == 'es' 
          ? 'Bandeja de Comentarios' 
          : 'Comments Inbox',
      'sin_comentarios': languageProvider.currentLanguage == 'es' 
          ? 'No hay comentarios aún' 
          : 'No comments yet',
    };

   return Scaffold(
  body: RefreshIndicator(
    key: _refreshIndicatorKey,
    onRefresh: _cargarDiagnosticos,
    child: Center(
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
                    HeaderSection(
                    
                    ),

                    // Sección de subida de archivos
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
                            '• ${textos['ecg']}\n• ${textos['fcg']}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _subirArchivo(context),
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          textos['comentarios']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        FilterMenu(
                          onFilterSelected: (filtro) {
                            setState(() {
                              _filtroSeleccionado = filtro;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Bandeja de comentarios
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filtrarComentarios().isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.comment_outlined,
                                        size: 50,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        textos['sin_comentarios']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _filtrarComentarios().length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final comentario = _filtrarComentarios()[index];
                                    return Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color: comentario['esUrgente']
                                          ? Colors.red.withOpacity(0.1)
                                          : Theme.of(context).cardColor,
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(12),
                                        
                                        title: Text(
                                          comentario['profesional'],
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              comentario['fecha'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comentario['diagnostico'],
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comentario['comentario'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        trailing: comentario['esUrgente']
                                            ? const Icon(Icons.warning, color: Colors.red)
                                            : null,
                                        onTap: () => _verComentarioCompleto(context, comentario),
                                      ),
                                    );
                                  },
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
  ),
);
  }
}