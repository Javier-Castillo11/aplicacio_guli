import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
///import 'package:shared_preferences/shared_preferences.dart'; //habilitar para el server 
import '../widgets/widgets_homepage/header_section.dart';
import '../widgets/widgets_pacientes_ecg_screen/menu_bar.dart' as my_menu;
import '../widgets/widgets_pacientes_ecg_screen/back_button.dart' as my_back;
import 'lista_señales_p.dart';
import '../constants/app_colors.dart';
import '../widgets/widgets_pacientes_ecg_screen/filter_menu.dart';
import '../widgets/widgets_pacientes_ecg_screen/sin_señales_aviso.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PacientesEcgScreen extends StatefulWidget {
  final bool highlightNewSignal;

  const PacientesEcgScreen({
    Key? key,
    this.highlightNewSignal = false,
  }) : super(key: key);

  @override
  _PacientesEcgScreenState createState() => _PacientesEcgScreenState();
}

class _PacientesEcgScreenState extends State<PacientesEcgScreen> {
  List<Map<String, dynamic>> pacientes= [];
  bool _isNewSignalHighlighted = false;
  String _filtroSeleccionado = 'reciente';

  @override
  void initState() {
    super.initState();
    if (widget.highlightNewSignal) {
      _isNewSignalHighlighted = true;
      Future.delayed(const Duration(seconds: 5), () {
     setState(() => _isNewSignalHighlighted = false);
      });
    }
    _cargarPacientesDesdeServidor(); // Llama al método real
  }


Future<void> _cargarPacientesDesdeServidor() async {
  try {
    final response = await http.get(Uri.parse('http://192.168.1.69:3000/obtener-pacientes-con-senales'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

for (var item in data) {
  print(item); // Verifica que 'id' esté presente
}

      setState(() {
        pacientes = data.map((item) => {
        'id': item['id_usuario'], // <--
          'nombre': item['nombre_completo'],
          'fecha': _formatearFecha(item['fecha_ultima_senal']),
        }).toList();
      });
    } else {
      print('Error al obtener pacientes: ${response.body}');
    }
  } catch (e) {
    print('Error de conexión: $e');
  }
}

// Método para formatear fecha en formato dd/MM/yyyy
String _formatearFecha(String fecha) {
  final DateTime parsed = DateTime.parse(fecha);
  return '${parsed.day}/${parsed.month}/${parsed.year}';
}


List<Map<String, dynamic>> _filtrarPacientes() {
  // Función auxiliar para parsear fechas en formato dd/MM/yyyy
  DateTime _parseFecha(String fecha) {
    final parts = fecha.split('/');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }

  switch (_filtroSeleccionado) {
    case 'reciente':
      return List.from(pacientes)..sort((a, b) => _parseFecha(b['fecha']).compareTo(_parseFecha(a['fecha'])));
    case '30dias':
      final hace30Dias = DateTime.now().subtract(const Duration(days: 30));
      return pacientes
          .where((paciente) => _parseFecha(paciente['fecha']).isAfter(hace30Dias))
          .toList();
    case 'antiguo':
      return List.from(pacientes)..sort((a, b) => _parseFecha(a['fecha']).compareTo(_parseFecha(b['fecha'])));
    default:
      return pacientes;
  }
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
                      HeaderSection(
                       
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languageProvider.currentLanguage == 'es'
                                ? 'Lista de pacientes'
                                : 'Patients list',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 18,
                              fontFamily: 'Inria Serif',
                              fontWeight: FontWeight.w700,
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
                      Container(
                        margin: const EdgeInsets.only(top: 9),
                        padding: const EdgeInsets.fromLTRB(11, 28, 11, 28),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? Colors.grey[800] : AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          height: 300,
                          child: _filtrarPacientes().isEmpty
                              ? const SinSenalesAviso()
                              : SingleChildScrollView(
                                  child: Column(
                                    children: _filtrarPacientes().map((paciente) {
                                      final isNewSignal = _isNewSignalHighlighted && paciente == pacientes.last;
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.fromLTRB(7, 10, 7, 10),
                                        decoration: BoxDecoration(
                                          color: isNewSignal ? AppColors.primary.withOpacity(0.3) : Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/Personal.png',
                                              width: 44,
                                              height: 36,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        paciente['nombre']!,
                                                        style: TextStyle(
                                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                                          fontSize: 14,
                                                          fontFamily: 'Inria Serif',
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    paciente['fecha']!,
                                                    style: TextStyle(
                                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                                      fontSize: 12,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                       IconButton(
  onPressed: () {
if (paciente['id'] != null && paciente['nombre'] != null) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ListaSenalesPacienteScreen(
        idPaciente: paciente['id'],
        nombrePaciente: paciente['nombre'],
      ),
    ),
  );
} else {
  print('Paciente inválido: id o nombre es null');
}

  },
  icon: Icon(
    Icons.arrow_forward,
    color: Color(0xFFFF22AE),
  ),
),

                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 100),
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