
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
//import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import 'dart:convert'; // Para jsonDecode()
import 'package:http/http.dart' as http; // Para las peticiones HTTP
import 'package:flutter/foundation.dart'; // Para debugPrint()

enum SignalType { ecg, fcg }

class GraficaScreen extends StatefulWidget {
  final String patientId;
  final SignalType signalType;
  final String signalId;
  final String? assetPath;

  const GraficaScreen({
    Key? key,
    required this.patientId,
    required this.signalType,
    required this.signalId,
    this.assetPath,
  }) : super(key: key);

  @override
  _GraficaScreenState createState() => _GraficaScreenState();
}

class _GraficaScreenState extends State<GraficaScreen> {
  
  late Future<Map<String, dynamic>> _signalDataFuture;
  double _visibleDuration = 5.0;
  double _currentPosition = 0.0;
  double _signalScale = 1.0;
  double _signalOffset = 0.0;
  List<ECGFeature> _detectedFeatures = [];

  // Textos localizados
  final Map<String, Map<String, String>> _localizedTexts = {
    'es': {
      'time_label': 'Tiempo (s)',
      'amplitude_label': 'Amplitud (mV)',
      'signal_label': 'Señal ECG',
      'error': 'Error',
      'no_data': 'No se encontraron datos',
      'duration': 'Duración',
      'samples': 'Muestras',
      'unknown_patient': 'Paciente desconocido',
      'zoom': 'Zoom',
      'position': 'Posición',
      'scale': 'Escala',
      'offset': 'Desplazamiento',
      'features': 'Ondas detectadas',
    },
    'en': {
      'time_label': 'Time (s)',
      'amplitude_label': 'Amplitude (mV)',
      'signal_label': 'ECG Signal',
      'error': 'Error',
      'no_data': 'No data found',
      'duration': 'Duration',
      'samples': 'Samples',
      'unknown_patient': 'Unknown patient',
      'zoom': 'Zoom',
      'position': 'Position',
      'scale': 'Scale',
      'offset': 'Offset',
      'features': 'Detected waves',
    },
  };

  String _getText(BuildContext context, String key) {
    final language = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    return _localizedTexts[language]?[key] ?? _localizedTexts['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _signalDataFuture = _fetchSignalDataFromServer();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.tryParse(dateString);
      if (date == null) return dateString;
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      debugPrint('Error formateando fecha: $e');
      return dateString;
    }
  }

   Future<Map<String, dynamic>> _fetchSignalDataFromServer() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.69:3000/ecg/${widget.signalId}'),
      );
//debugPrint('Respuesta del servidor: ${response.body}');
      if (response.statusCode != 200) {
        
        throw Exception('Error al obtener la señal: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      
      // Convertir los datos de la señal a List<double>
      final dynamic signalData = data['signal_data'];
      List<double> signal = [];
      
     if (signalData is List) {
  signal = signalData.map((e) {
    if (e is num) {
      return e.toDouble();
    } else if (e is String) {
      return double.tryParse(e) ?? 0.0;
    }
    return 0.0; // Valor por defecto si no es numérico
  }).toList();
}

      // Procesar la señal (filtrado, normalización)
      final processedSignal = _processECGSignal(signal);
      
      // Detectar características ECG
      _detectedFeatures = _detectECGFeatures(processedSignal, data['sampling_rate'] ?? 250.0);

      return {
        'signal': processedSignal,
        'samplingRate': data['sampling_rate'] ?? 250.0,
        'duration': signal.length / (data['sampling_rate'] ?? 250.0),
        'metadata': {
          'patient': data['patient_name'] ?? 'Paciente ${widget.patientId}',
          'date': data['record_date'] ?? DateTime.now().toIso8601String(),
          'signalType': 'ECG',
        },
      };
    } catch (e) {
      //debugPrint('Error loading signal from server: $e');
      return {
        'signal': [],
        'samplingRate': 250.0,
        'duration': 0.0,
        'metadata': {
          'patient': 'Paciente ${widget.patientId}',
          'date': 'Fecha no disponible',
          'signalType': 'ECG',
        },
      };
    }
  }



  List<double> _processECGSignal(List<double> rawSignal) {
    if (rawSignal.isEmpty) return rawSignal;
    
    // 1. Remove baseline wander
    final baselineRemoved = _applyHighPassFilter(rawSignal, sampleRate: 250.0, cutoff: 0.5);
    
    // 2. Apply smoothing
    final smoothedSignal = _applyMovingAverage(baselineRemoved, windowSize: 3);
    
    // 3. Normalize amplitude
    return _normalizeSignal(smoothedSignal);
  }

  List<double> _applyHighPassFilter(List<double> signal, {required double sampleRate, required double cutoff}) {
    final double alpha = 1.0 / (1.0 + 1.0 / (2.0 * 3.14159 * cutoff * (1.0 / sampleRate)));
    final filtered = List<double>.filled(signal.length, 0.0);
    
    filtered[0] = signal[0];
    for (int i = 1; i < signal.length; i++) {
      filtered[i] = alpha * (filtered[i-1] + signal[i] - signal[i-1]);
    }
    
    return filtered;
  }

  List<double> _applyMovingAverage(List<double> signal, {int windowSize = 3}) {
    if (signal.isEmpty || windowSize < 1) return signal;
    
    final filtered = List<double>.filled(signal.length, 0.0);
    final halfWindow = windowSize ~/ 2;
    
    for (int i = 0; i < signal.length; i++) {
      double sum = 0.0;
      int count = 0;
      
      for (int j = -halfWindow; j <= halfWindow; j++) {
        if (i + j >= 0 && i + j < signal.length) {
          sum += signal[i + j];
          count++;
        }
      }
      
      filtered[i] = sum / count;
    }
    
    return filtered;
  }

  List<double> _normalizeSignal(List<double> signal) {
    if (signal.isEmpty) return signal;
    
    double minVal = signal.reduce((a, b) => a < b ? a : b);
    double maxVal = signal.reduce((a, b) => a > b ? a : b);
    double range = maxVal - minVal;
    
    if (range == 0) return signal;
    
    return signal.map((value) => ((value - minVal) / range * 2.0) - 1.0).toList();
  }

  List<ECGFeature> _detectECGFeatures(List<double> signal, double samplingRate) {
    final features = <ECGFeature>[];
    final qrsComplexes = _detectQRSComplexes(signal, samplingRate);
    
    for (final qrs in qrsComplexes) {
      // Detectar onda P (antes del QRS)
      final pWave = _detectPWave(signal, qrs.startIndex, samplingRate);
      if (pWave != null) features.add(pWave);
      
      // Añadir complejo QRS
      features.add(qrs);
      
      // Detectar onda T (después del QRS)
      final tWave = _detectTWave(signal, qrs.endIndex, samplingRate);
      if (tWave != null) features.add(tWave);
    }
    
    return features;
  }

  List<ECGFeature> _detectQRSComplexes(List<double> signal, double samplingRate) {
    final complexes = <ECGFeature>[];
    final threshold = 0.5; // Umbral para detección de QRS
    var inComplex = false;
    var startIndex = 0;
    
    for (int i = 1; i < signal.length - 1; i++) {
      if (signal[i].abs() > threshold && !inComplex) {
        inComplex = true;
        startIndex = i;
      } else if (signal[i].abs() <= threshold && inComplex) {
        inComplex = false;
        final peakIndex = _findPeak(signal, startIndex, i);
        complexes.add(ECGFeature(
          'QRS',
          startIndex,
          i,
          signal[peakIndex],
        ));
      }
    }
    
    return complexes;
  }

  ECGFeature? _detectPWave(List<double> signal, int qrsStart, double samplingRate) {
    final searchStart = qrsStart - (0.2 * samplingRate).toInt();
    final searchEnd = qrsStart;
    
    if (searchStart < 0) return null;
    
    final peakIndex = _findPeak(signal, searchStart, searchEnd);
    if (peakIndex == -1) return null;
    
    return ECGFeature(
      'P',
      peakIndex - (0.04 * samplingRate).toInt(),
      peakIndex + (0.04 * samplingRate).toInt(),
      signal[peakIndex],
    );
  }

  ECGFeature? _detectTWave(List<double> signal, int qrsEnd, double samplingRate) {
    final searchStart = qrsEnd;
    final searchEnd = qrsEnd + (0.4 * samplingRate).toInt();
    
    if (searchEnd >= signal.length) return null;
    
    final peakIndex = _findPeak(signal, searchStart, searchEnd);
    if (peakIndex == -1) return null;
    
    return ECGFeature(
      'T',
      peakIndex - (0.08 * samplingRate).toInt(),
      peakIndex + (0.08 * samplingRate).toInt(),
      signal[peakIndex],
    );
  }

  int _findPeak(List<double> signal, int start, int end) {
    if (start >= end) return -1;
    
    double maxVal = signal[start].abs();
    int maxIndex = start;
    
    for (int i = start + 1; i < end; i++) {
      if (signal[i].abs() > maxVal) {
        maxVal = signal[i].abs();
        maxIndex = i;
      }
    }
    
    return maxIndex;
  }

  List<ChartData> _getVisibleData(List<double> fullSignal, double samplingRate) {
    final startIndex = (_currentPosition * samplingRate).toInt();
    final endIndex = ((_currentPosition + _visibleDuration) * samplingRate)
        .toInt()
        .clamp(0, fullSignal.length);
    
    return List.generate(
      endIndex - startIndex,
      (i) => ChartData(
        x: _currentPosition + (i / samplingRate),
        y: (fullSignal[startIndex + i] * _signalScale) + _signalOffset,
      ),
    );
  }

  List<ChartData> _getFeaturePoints(List<double> signal, double samplingRate) {
    final points = <ChartData>[];
    
    for (final feature in _detectedFeatures) {
      final time = feature.startIndex / samplingRate;
      if (time >= _currentPosition && time <= _currentPosition + _visibleDuration) {
        points.add(ChartData(
          x: time,
          y: (signal[feature.startIndex] * _signalScale) + _signalOffset,
          feature: feature,
        ));
      }
    }
    
    return points;
  }

  Widget _buildEcgChart(List<double> signal, double samplingRate) {
    final visibleData = _getVisibleData(signal, samplingRate);
    final featurePoints = _getFeaturePoints(signal, samplingRate);
    
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(
        title: AxisTitle(text: _getText(context, 'time_label')),
        minimum: _currentPosition,
        maximum: _currentPosition + _visibleDuration,
        interval: _calculateXAxisInterval(),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: _getText(context, 'amplitude_label')),
        minimum: -1.5 * _signalScale + _signalOffset,
        maximum: 1.5 * _signalScale + _signalOffset,
        interval: 0.5,
      ),
      series: <CartesianSeries>[
        FastLineSeries<ChartData, double>(
          dataSource: visibleData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          color: Colors.red,
          width: 1.5,
        ),
        ScatterSeries<ChartData, double>(
          dataSource: featurePoints,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          markerSettings: MarkerSettings(
            shape: DataMarkerType.diamond,
            color: Colors.blue,
            width: 4,
            height: 4,
            borderWidth: 1,
            borderColor: Colors.white,
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(fontSize: 10, color: Colors.blue),
            builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
              return Text(featurePoints[pointIndex].feature?.type ?? '');
            },
          ),
        ),
      ],
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enablePanning: true,
        zoomMode: ZoomMode.x,
      ),
    );
  }

  double _calculateXAxisInterval() {
    if (_visibleDuration <= 5) return 0.2;
    if (_visibleDuration <= 10) return 0.5;
    if (_visibleDuration <= 20) return 1.0;
    return 2.0;
  }

  Widget _buildPatientInfo(Map<String, dynamic> metadata, Color textColor) {
    final duration = metadata['duration'] ?? 0.0;
    final signalLength = (metadata['signal'] as List?)?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metadata['patient'] ?? _getText(context, 'unknown_patient'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${metadata['signalType']} - ${_formatDate(metadata['date'])}',
            style: TextStyle(color: textColor),
          ),
          Text(
            '${_getText(context, 'duration')}: ${duration.toStringAsFixed(1)}s - '
            '${_getText(context, 'samples')}: $signalLength',
            style: TextStyle(color: textColor),
          ),
          if (_detectedFeatures.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${_getText(context, 'features')}: ${_detectedFeatures.map((f) => f.type).toSet().join(', ')}',
              style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationControls(double duration) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(_getText(context, 'position')),
          Slider(
            value: _currentPosition,
            min: 0.0,
            max: (duration - _visibleDuration).clamp(0.0, double.infinity),
            onChanged: (value) => setState(() => _currentPosition = value),
          ),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(_getText(context, 'scale')),
                    Slider(
                      value: _signalScale,
                      min: 0.1,
                      max: 3.0,
                      onChanged: (value) => setState(() => _signalScale = value),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(_getText(context, 'offset')),
                    Slider(
                      value: _signalOffset,
                      min: -2.0,
                      max: 2.0,
                      onChanged: (value) => setState(() => _signalOffset = value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.fast_rewind),
                onPressed: () => setState(() {
                  _currentPosition = (_currentPosition - _visibleDuration/2)
                      .clamp(0.0, duration - _visibleDuration);
                }),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: () => setState(() {
                  _visibleDuration = (_visibleDuration * 0.8).clamp(0.1, 60.0);
                }),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: () => setState(() {
                  _visibleDuration = (_visibleDuration / 0.8).clamp(0.5, 60.0);
                }),
              ),
              IconButton(
                icon: const Icon(Icons.fast_forward),
                onPressed: () => setState(() {
                  _currentPosition = (_currentPosition + _visibleDuration/2)
                      .clamp(0.0, duration - _visibleDuration);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getText(context, 'signal_label'),
          style: TextStyle(color: textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _signalDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(
              '${_getText(context, 'error')}: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ));
          }

          if (!snapshot.hasData || (snapshot.data!['signal'] as List).isEmpty) {
            return Center(child: Text(
              _getText(context, 'no_data'),
              style: TextStyle(color: textColor),
            ));
          }

          final signalData = snapshot.data!;
          final metadata = signalData['metadata'] as Map<String, dynamic>;

          return Column(
            children: [
              _buildPatientInfo(metadata, textColor),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildEcgChart(
                    signalData['signal'] as List<double>,
                    signalData['samplingRate'] as double,
                  ),
                ),
              ),

              _buildNavigationControls(
                signalData['duration'] as double,
              ),
            ],
          );
        },
      ),
    );
  }
}

class ChartData {
  final double x;
  final double y;
  final ECGFeature? feature;

  ChartData({required this.x, required this.y, this.feature});
}

class ECGFeature {
  final String type; // 'P', 'QRS', 'T'
  final int startIndex;
  final int endIndex;
  final double amplitude;
  
  ECGFeature(this.type, this.startIndex, this.endIndex, this.amplitude);
}
