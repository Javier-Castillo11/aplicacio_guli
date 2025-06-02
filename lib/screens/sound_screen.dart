import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
//import 'dart:typed_data';
//import 'package:flutter/services.dart';
//import 'dart:math';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';



class SoundScreen extends StatefulWidget {
  final String patientId;
  final String signalId;
  final String base64Audio;

  const SoundScreen({
    Key? key,
    required this.patientId,
    required this.signalId,
    required this.base64Audio,
  }) : super(key: key);

  @override
  _SoundScreenState createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  late Future<Map<String, dynamic>> _signalDataFuture;
  final AudioPlayer _audioPlayer = AudioPlayer(); // mismo nombre, diferente clase
  
  List<double> _audioSamples = [];
  double _visibleDuration = 5.0;
  double _currentPosition = 0.0;
  bool _isPlaying = false;
  double _playbackRate = 1.0;
  bool _audioError = false;
  Duration? _audioDuration;
  double _signalScale = 1.0;
  double _signalOffset = 0.0;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;



  // Textos localizados
  final Map<String, Map<String, String>> _localizedTexts = {
    'es': {
      'time_label': 'Tiempo (s)',
      'amplitude_label': 'Amplitud',
      'signal_label': 'Fonocardiograma',
      'error': 'Error',
      'no_data': 'No se encontraron datos',
      'duration': 'Duración',
      'unknown_patient': 'Paciente desconocido',
      'play': 'Reproducir',
      'pause': 'Pausar',
      'speed': 'Velocidad',
      'position': 'Posición',
      'loading_audio': 'Cargando audio...',
      'scale': 'Escala',
      'offset': 'Desplazamiento',
    },
    'en': {
      'time_label': 'Time (s)',
      'amplitude_label': 'Amplitude',
      'signal_label': 'Phonocardiogram',
      'error': 'Error',
      'no_data': 'No data found',
      'duration': 'Duration',
      'unknown_patient': 'Unknown patient',
      'play': 'Play',
      'pause': 'Pause',
      'speed': 'Speed',
      'position': 'Position',
      'loading_audio': 'Loading audio...',
      'scale': 'Scale',
      'offset': 'Offset',
    },
  };

  String _getText(BuildContext context, String key) {
    final language = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    return _localizedTexts[language]?[key] ?? _localizedTexts['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _signalDataFuture = _loadAudioData();
  }

void _setupAudioPlayer() {
  _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
    setState(() {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
        _currentPosition = 0.0;
      }
    });
  });

_audioPlayer.positionStream.listen((position) {
  print('Position: ${position.inSeconds}');
  if (!mounted) return;
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    setState(() {
      _currentPosition = position.inMilliseconds / 1000.0;
    });
  });
});

_audioPlayer.durationStream.listen((duration) {
  setState(() {
    _audioDuration = duration ?? Duration.zero; // para evitar nulls
  });
});

}


@override
void dispose() {
  _playerStateSubscription?.cancel();
  _positionSubscription?.cancel();
  _durationSubscription?.cancel();
  _audioPlayer.dispose();
  super.dispose();
}



Future<Map<String, dynamic>> _loadAudioData() async {
  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.69:3000/fcg/${widget.signalId}'),
    );

    if (response.statusCode == 200) {
      final audioData = jsonDecode(response.body);
      
      // Configurar reproductor de audio
      await _audioPlayer.setUrl(audioData['audio_url']);
      
      // Procesar muestras de audio (ya vienen normalizadas desde el servidor)
      if (audioData.containsKey('audio_samples')) {
        setState(() {
          _audioSamples = List<double>.from(audioData['audio_samples'])
              .map((sample) => sample * 1.5) // Ajuste opcional de amplitud
              .toList();
        });
      }

      return {
        'duration': audioData['duration']?.toDouble() ?? 0.0,
        'metadata': {
          'patient': audioData['patient_name'] ?? 'Paciente ${widget.patientId}',
          'date': audioData['record_date'] ?? DateTime.now().toIso8601String(),
          'signalType': 'FCG',
        },
      };
    } else {
      throw Exception('Error al obtener audio desde el servidor');
    }
  } catch (e) {
    debugPrint('Error loading audio: $e');
    if (mounted) setState(() => _audioError = true);
    return {
      'duration': 0.0,
      'metadata': {
        'patient': 'Paciente ${widget.patientId}',
        'date': 'Fecha no disponible',
        'signalType': 'FCG',
      },
    };
  }
}


  /*List<double> _processAudioSamples(Uint8List bytes) {
    // Convertir bytes a muestras de audio
    final ByteData byteData = ByteData.sublistView(bytes);
    final rawSamples = Int16List(bytes.length ~/ 2);
    for (int i = 0; i < rawSamples.length; i++) {
      rawSamples[i] = byteData.getInt16(i * 2, Endian.little);
    }

    final samples = List<double>.generate(
      rawSamples.length,
      (i) => rawSamples[i] / 32768.0, // Normalizar a [-1.0, 1.0]
    );

    final filtered = _bandpassFilter(samples, 20.0, 400.0, 44100.0);
    return _medianFilter(filtered, windowSize: 3);
  }*/

  /*List<double> _bandpassFilter(List<double> input, double lowCutoff, double highCutoff, double sampleRate) {
    final n = input.length;
    final output = List<double>.filled(n, 0.0);
    
    final dt = 1.0 / sampleRate;
    final rcLow = 1.0 / (2 * pi * lowCutoff);
    final rcHigh = 1.0 / (2 * pi * highCutoff);
    double alphaLow = dt / (rcLow + dt);
    double alphaHigh = rcHigh / (rcHigh + dt);

    double prevHigh = input[0];
    double prevLow = input[0];
    
    for (int i = 1; i < n; i++) {
      prevHigh = alphaHigh * (prevHigh + input[i] - input[i-1]);
      prevLow = alphaLow * input[i] + (1 - alphaLow) * prevLow;
      output[i] = prevLow - prevHigh;
    }

    return output;
  }*/

  /*List<double> _medianFilter(List<double> input, {int windowSize = 3}) {
    final halfWindow = windowSize ~/ 2;
    final output = List<double>.from(input);
    
    for (int i = halfWindow; i < input.length - halfWindow; i++) {
      final window = input.sublist(i - halfWindow, i + halfWindow + 1);
      window.sort();
      output[i] = window[halfWindow];
    }
    
    return output;
  }*/

 List<ChartData> _getVisibleData() {
  if (_audioSamples.isEmpty || _audioDuration == null) return [];
  
  final samplesPerSecond = _audioSamples.length / _audioDuration!.inSeconds;
  final startIndex = (_currentPosition * samplesPerSecond).toInt().clamp(0, _audioSamples.length - 1);
  final endIndex = ((_currentPosition + _visibleDuration) * samplesPerSecond)
      .toInt()
      .clamp(0, _audioSamples.length);
  
  return List.generate(
    endIndex - startIndex,
    (i) => ChartData(
      x: _currentPosition + (i / samplesPerSecond),
      y: _audioSamples[startIndex + i],
    ),
  );
}

  Widget _buildAudioChart() {
   
    
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
    minimum: -1.5,  // Rango ajustado para señal de audio
    maximum: 1.5,
    interval: 0.5,
  ),
  series: <CartesianSeries>[
    FastLineSeries<ChartData, double>(
      dataSource: _getVisibleData(),
      xValueMapper: (ChartData data, _) => data.x,
      yValueMapper: (ChartData data, _) => data.y,
      color: Colors.blue,
      width: 1.2,
    ),
  ],
);
  }

  double _calculateXAxisInterval() {
    if (_visibleDuration <= 1.0) return 0.05;
    if (_visibleDuration <= 5) return 0.2;
    if (_visibleDuration <= 10) return 0.5;
    return 1.0;
  }

  Widget _buildPatientInfo(Map<String, dynamic> metadata, Color textColor) {
    final duration = metadata['duration'] ?? 0.0;

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
            '${_getText(context, 'duration')}: ${duration.toStringAsFixed(1)}s',
            style: TextStyle(color: textColor),
          ),
          if (_audioError)
            Text(
              _getText(context, 'error'),
              style: TextStyle(color: Colors.orange),
            ),
        ],
      ),
    );
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

  Widget _buildAudioControls(double duration) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.fast_rewind),
                onPressed: _audioError ? null : () => _seekRelative(-5),
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _audioError ? null : _togglePlayback,
                iconSize: 36,
                color: Colors.blue,
              ),
              IconButton(
                icon: Icon(Icons.fast_forward),
                onPressed: _audioError ? null : () => _seekRelative(5),
              ),
            ],
          ),
          
          
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(_getText(context, 'scale')),
           Slider(
  value: _signalScale.clamp(0.5, 2.0), // Garantiza que el valor esté entre min y max
  min: 0.5,
  max: 2.0,
  onChanged: (value) => setState(() => _signalScale = value),
),
                    //control nuevo para quitar lo de yellow, es para la velocidad del audio
Slider(
  value: _playbackRate.clamp(0.5, 2.0),
  min: 0.5,
  max: 2.0,
  divisions: 3,
  label: '${_playbackRate.toStringAsFixed(1)}x',
  onChanged: _audioError ? null : (value) {
    setState(() => _playbackRate = value);
    _audioPlayer.setSpeed(value); // Usar el valor seleccionado para setSpeed
  },
),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(_getText(context, 'offset')),
             
Slider(
  value: _signalOffset.clamp(-1.0, 1.0),
  min: -1.0,
  max: 1.0,
  onChanged: (value) => setState(() => _signalOffset = value),
),
                  ],
                ),
              ),
            ],
          ),
          
          Text(_getText(context, 'position')),
    Slider(
  value: (_currentPosition.clamp(0.0, duration)),
  min: 0.0,
  max: (duration > 0) ? duration : 1.0, // Si duration es 0, usar 1.0 para evitar max=0
  onChanged: _audioError ? null : (value) {
    setState(() => _currentPosition = value);
  },
  onChangeEnd: _audioError ? null : (value) {
    _audioPlayer.seek(Duration(seconds: value.toInt()));
  },
),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.zoom_in),
                onPressed: () => setState(() {
                  _visibleDuration = (_visibleDuration * 0.8).clamp(0.1, 60.0);
                }),
              ),
              Text('${_visibleDuration.toStringAsFixed(1)}s'),
              IconButton(
                icon: Icon(Icons.zoom_out),
                onPressed: () => setState(() {
                  _visibleDuration = (_visibleDuration / 0.8).clamp(0.1, 60.0);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();

    }
  }

  Future<void> _seekRelative(double seconds) async {
    final newPosition = (_currentPosition + seconds).clamp(0.0, _audioDuration?.inSeconds.toDouble() ?? 0.0);
    await _audioPlayer.seek(Duration(seconds: newPosition.toInt()));
    setState(() => _currentPosition = newPosition);
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
          onPressed: () {
            _audioPlayer.pause();
            Navigator.pop(context);
          },
        ),
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _signalDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(_getText(context, 'loading_audio')),
              ],
            ));
          }

          if (snapshot.hasError) {
            return Center(child: Text(
              '${_getText(context, 'error')}: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ));
          }

          if (!snapshot.hasData) {
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
                  child: _buildAudioChart(),
                ),
              ),

              _buildAudioControls(
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

  ChartData({required this.x, required this.y});
}