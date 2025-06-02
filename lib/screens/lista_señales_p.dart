import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../widgets/widgets_homepage/header_section.dart';
//import '../widgets/widgets_lista_señales_p/search_bar.dart' as my_search;
import '../widgets/widgets_lista_señales_p/menu_bar.dart' as my_menu;
import '../widgets/widgets_lista_señales_p/back_button.dart' as my_back;
import 'signal_view_screen.dart';
import '../constants/app_colors.dart';
import '../widgets/widgets_lista_señales_p/filter_menu.dart';
import '../widgets/widgets_pacientes_ecg_screen/sin_señales_aviso.dart';
import 'dart:convert';         // Para jsonEncode y jsonDecode
import 'package:http/http.dart' as http; // Para hacer peticiones HTTP

class ListaSenalesPacienteScreen extends StatefulWidget {
  final int idPaciente;
  final String nombrePaciente;

  const ListaSenalesPacienteScreen({
    Key? key,
    required this.idPaciente,
    required this.nombrePaciente,
  }) : super(key: key);



@override
  State<ListaSenalesPacienteScreen> createState() => _ListaSenalesPacienteScreenState();
}

class _ListaSenalesPacienteScreenState extends State<ListaSenalesPacienteScreen> {
  String _filtroSeleccionado = 'reciente'; // Filtro por defecto

 List<Map<String, dynamic>> _senalesFiltradas = [];
 
  @override
  void initState() {
    super.initState();

_cargarSenales();
print("Señales recibidas:");
for (var senal in _senalesFiltradas) {
  print(senal);
}

  }
  

 

  void _cargarSenales() async {
  final response = await http.post(
    
    Uri.parse('http://192.168.1.69:3000/obtener-senales-de-paciente'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'id_paciente': widget.idPaciente}),
    
  );
  print("Respuesta cruda del backend:");
print(response.body);


  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      _senalesFiltradas = List<Map<String, dynamic>>.from(data['senales']);
    });
     print("_senalesFiltradas: $_senalesFiltradas");
  } else {
    // Manejo de error
    print('Error al cargar señales');
  }
}



DateTime _parseFecha(dynamic fecha) {
  if (fecha == null || fecha.toString().trim().isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  try {
    return DateTime.parse(fecha.toString());
  } catch (e) {
    debugPrint('Error parseando fecha: $e');
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}



List<Map<String, dynamic>> _filtrarSenales() {
  final senalesValidas = _senalesFiltradas.where((senal) {
    final fecha = senal['fecha_subida'];
    return fecha != null && fecha.toString().trim().isNotEmpty;
  }).toList();

  switch (_filtroSeleccionado) {
    case 'reciente':
      return List.from(senalesValidas)
        ..sort((a, b) => _parseFecha(b['fecha']).compareTo(_parseFecha(a['fecha'])));
    case '30dias':
      final hace30Dias = DateTime.now().subtract(const Duration(days: 30));
      return senalesValidas
          .where((senal) => _parseFecha(senal['fecha']).isAfter(hace30Dias))
          .toList();
    case 'antiguo':
      return List.from(senalesValidas)
        ..sort((a, b) => _parseFecha(a['fecha']).compareTo(_parseFecha(b['fecha'])));
    default:
      return senalesValidas;
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
                      // Header section
      HeaderSection(
                     
                      ),
                      //my_search.SearchBar(),
                      Text(
                        languageProvider.currentLanguage == 'es'
                            ? 'Lista de señales del paciente'
                            : 'Patient signal list',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontFamily: 'Inria Serif',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.nombrePaciente,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 24,
                          fontFamily: 'Inria Serif',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                             child: _filtrarSenales().isEmpty
                              ? const SinSenalesAviso()
                          : SingleChildScrollView(
                            child: Column(
                              children: _filtrarSenales().map((senal) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.fromLTRB(7, 10, 7, 10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                 Image.asset(
  senal['tipo_senal'] == 'ECG'
      ? 'assets/images/Ecg.png'
      : 'assets/images/Ecg.png',
  width: 44,
  height: 36,
  fit: BoxFit.contain,
),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
  senal['tipo_senal']!,
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                                fontSize: 14,
                                                fontFamily: 'Inria Serif',
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                           Text(
  senal['fecha_subida']!,
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
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SignalViewScreen(
        signalId: senal['id_senal'],  
        signalType: senal['tipo_senal']!,
        patientName: widget.nombrePaciente,
        //signalData: senal['datos_senal'] ?? '',
        //archivo: senal['ruta_archivo'] ?? '',
      ),
    ),
  );
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