import 'dart:typed_data'; // Solo para Uint8List
import 'package:flutter/services.dart' show rootBundle;

class WfdbParser {
  static Future<Map<String, dynamic>> parseFromAssets(String assetPath) async {
    try {
      // Carga solo el archivo .dat
      final byteData = await rootBundle.load('assets/signals/$assetPath.dat');
      final bytes = byteData.buffer.asUint8List();
      
      return {
        'signal': _parseDatFile(bytes),
        'samplingRate': 250.0,
        'duration': bytes.length / (250 * 2), // 250Hz, 2 bytes por muestra
        'metadata': {
          'patient': 'Paciente',
          'date': DateTime.now().toIso8601String(),
          'signalType': 'ECG',
        },
      };
    } catch (e) {
      throw Exception('Error loading ECG data: $e');
    }
  }

  static List<double> _parseDatFile(Uint8List bytes) {
    final data = <double>[];
    for (int i = 0; i < bytes.length; i += 2) {
      // Interpreta como 16-bit signed (ajusta según tu formato)
      data.add((bytes[i] | (bytes[i + 1] << 8)).toSigned(16).toDouble());
    }
    return data;
  }
}














/*import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class WfdbParser {
  static Future<Map<String, dynamic>> parseFromAssets(String assetPath) async {
    try {
      // Extraer el nombre base sin extensión
      final baseName = assetPath.split('/').last.split('.').first;
      
      // 1. Cargar y parsear encabezado (si existe)
      Map<String, dynamic> header = {};
      try {
        final headerContent = await rootBundle.loadString('assets/signals/$baseName.hea');
        header = _parseHeader(headerContent);
      } catch (_) {
        header = {
          'sampleFrequency': 44100.0, // Default para audio
          'signalType': 'FCG',
        };
      }

      // 2. Preparar archivo de audio
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/$baseName.mp3');
      
      // Copiar a almacenamiento temporal
      final byteData = await rootBundle.load('assets/signals/$baseName.mp3');
      await audioFile.writeAsBytes(byteData.buffer.asUint8List());

      return {
        'signal': [], // No hay datos para graficar en FCG
        'samplingRate': header['sampleFrequency'],
        'duration': header['duration'] ?? 30.0, // Default 30 seg
        'metadata': {
          'patient': header['patientId'] ?? 'Unknown',
          'date': header['startDate'] ?? 'No date',
          'signalType': header['signalType'] ?? 'FCG',
          'audioPath': audioFile.path, // Ruta al archivo MP3
        },
      };
    } catch (e) {
      throw Exception('Error parsing files: $e');
    }
  }

  static Map<String, dynamic> _parseHeader(String content) {
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) return {};

    final result = <String, dynamic>{};
    
    // Parsear línea de información básica
    if (lines.isNotEmpty) {
      final firstLine = lines[0].trim().split(RegExp(r'\s+'));
      if (firstLine.length >= 4) {
        result['sampleFrequency'] = double.tryParse(firstLine[2]) ?? 44100.0;
        result['numberOfSamples'] = int.tryParse(firstLine[3]) ?? 0;
      }
    }

    // Parsear metadatos adicionales
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('#PatientID:')) {
        result['patientId'] = trimmedLine.substring('#PatientID:'.length).trim();
      } else if (trimmedLine.startsWith('#StartDate:')) {
        result['startDate'] = trimmedLine.substring('#StartDate:'.length).trim();
      } else if (trimmedLine.startsWith('#Duration:')) {
        result['duration'] = double.tryParse(
          trimmedLine.substring('#Duration:'.length).trim()
        );
      }
    }

    return result;
  }
}*/