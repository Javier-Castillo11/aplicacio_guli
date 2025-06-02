import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../widgets/widgets_subir_arch_screen/back_button.dart' as my_back;
import '../providers/language_provider.dart';
import 'grafica_screen.dart';
import 'sound_screen.dart';


class ComentarioScreen extends StatelessWidget {
  final Map<String, dynamic> comentario;

  const ComentarioScreen({
    Key? key,
    required this.comentario,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    // Textos traducibles
    final Map<String, String> textos = {
      'titulo': languageProvider.currentLanguage == 'es' 
          ? 'Diagnóstico Detallado' 
          : 'Detailed Diagnosis',
      'archivo': languageProvider.currentLanguage == 'es' 
          ? 'Archivo analizado:' 
          : 'Analyzed file:',
      'diagnostico': languageProvider.currentLanguage == 'es' 
          ? 'Diagnóstico:' 
          : 'Diagnosis:',
      'comentarios': languageProvider.currentLanguage == 'es' 
          ? 'Comentarios:' 
          : 'Comments:',
      'sin_diagnostico': languageProvider.currentLanguage == 'es' 
          ? 'Sin diagnóstico específico' 
          : 'No specific diagnosis',
      'ver_ecg': languageProvider.currentLanguage == 'es' 
          ? 'Ver gráfico ECG' 
          : 'View ECG chart',
      'escuchar_fcg': languageProvider.currentLanguage == 'es' 
          ? 'Escuchar fonocardiograma' 
          : 'Listen to phonocardiogram',
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
                      const SizedBox(height: 40),
                      
                      Text(
                        textos['titulo']!,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      comentario['profesional'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    comentario['fecha'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                textos['archivo']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                '${comentario['tipoArchivo']} - ${comentario['nombreArchivo']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                textos['diagnostico']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                comentario['diagnostico'] ?? textos['sin_diagnostico']!,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                textos['comentarios']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                comentario['comentario'],
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 25),
                              if (comentario['tipoArchivo'] == 'ECG')
                                 ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GraficaScreen(
            patientId: comentario['pacienteId']?.toString() ?? '',
            signalType: SignalType.ecg, // Usando el enum definido
            signalId: comentario['archivoId']?.toString() ?? '',
            //assetPath: comentario['rutaArchivo']?.toString(),
            
            // Agrega otros parámetros necesarios para GraficaScreen
          ),
        ),
      );
    },
                                  icon: const Icon(Icons.show_chart),
                                  label: Text(textos['ver_ecg']!),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                ),
                              if (comentario['tipoArchivo'] == 'FCG')
                               ElevatedButton.icon(
    onPressed: () {
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SoundScreen(
    patientId: 'abc',
    signalId: 'def',
    base64Audio: 'AAAABBBBCCC...',
  )),
);

    },
                                  icon: const Icon(Icons.audiotrack),
                                  label: Text(textos['escuchar_fcg']!),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
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
}