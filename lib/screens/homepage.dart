import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/widgets_homepage/header_section.dart';
import '../widgets/widgets_homepage/search_bar.dart' as my_search;
import '../widgets/widgets_homepage/welcome_banner.dart';
import '../widgets/widgets_homepage/menu_bar.dart' as my_menu;
import '../widgets/widgets_homepage/card_item.dart';
import '../constants/app_colors.dart';
import '../screens/pacientes_ecg_screen.dart';
import '../screens/configuraciones_screen.dart';
import '../screens/subir_arch_screen.dart';
import 'role_selection_screen.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _isRoleSelected = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkRoleSelection();
    _loadUserName();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_userRole != null) {
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        notificationProvider.setUserRole(_userRole!);
      }
    });

  }

  void _checkRoleSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('tipo_perfil');
    print('ROL OBTENIDO SharedPreferences: $role'); // <--- Agrega esta línea

    if (role == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      });
    } else {
      setState(() {
        _isRoleSelected = true;
        _userRole = role;
      });
    }
  }

  void _loadUserName() async {
  }


  void _handlePacientesButtonPress(BuildContext context) async {
    if (_userRole == 'paciente') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'es'
                ? 'Acceso restringido. Cuenta de paciente.'
                : 'Access denied. Patient account.',
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PacientesEcgScreen()),
      ).then((_) {
        Provider.of<NotificationProvider>(context, listen: false).markNotificationsAsRead();
      });
    }
  }

  ////Para el rol de profesionista, se bñloquea el boton de subir
  void _handleUploadButtonPress(BuildContext context) async {
  if (_userRole == 'profesional') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'es'
              ? 'Acceso restringido. Cuenta de profesional.'
              : 'Access denied. Professional account.',
        ),
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubirArchScreen()),
    );
  }
}

  Future<Map<String, String>> _obtenerDatosBienvenida() async {
  final prefs = await SharedPreferences.getInstance();
  final nombre = prefs.getString('nombre_completo') ?? 'Usuario';
  final correo = prefs.getString('correo_electronico') ?? '';
  
  return {
    'nombre': nombre,
    'userName': correo,
  };
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    if (!_isRoleSelected) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderSection(
                      
                    ),

                    my_search.SearchBar(),

                    // ------------------------------------------------------------------------
                    // WelcomeBanner con conexión al servidor (dejar comentado hasta integración)
                    // ------------------------------------------------------------------------
                    /*WelcomeBanner(
                      welcomeText: languageProvider.currentLanguage == 'es'
                          ? 'Bienvenido a \nGuli App'
                          : 'Welcome to \nGuli App',
                      userName: _userName,
                    ),*/
                    FutureBuilder(
                          future: _obtenerDatosBienvenida(),
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (snapshot.hasData) {
                              return WelcomeBanner(
                                welcomeText: languageProvider.currentLanguage == 'es'
                                    ? 'Bienvenido/a, ${snapshot.data!['nombre']}'
                                    : 'Welcome, ${snapshot.data!['nombre']}',
                                userName: snapshot.data!['userName']!,
                              );
                            } else {
                              return Text('Error al cargar los datos');
                            }
                          },
                        ),


                    Container(
                      margin: const EdgeInsets.only(top: 25),
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 58, 28, 58),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? Colors.grey[800] : AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.primary,
                            blurRadius: 4,
                            offset: Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => _handlePacientesButtonPress(context),
                                child: CardItem(
                                  imagePath: 'assets/images/Ecg Machine.png',
                                  label: languageProvider.currentLanguage == 'es'
                                      ? 'Pacientes'
                                      : 'Patients',
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ConfiguracionesScreen(),
                                    ),
                                  );
                                },
                                child: CardItem(
                                  imagePath: 'assets/images/Setting.png',
                                  label: languageProvider.currentLanguage == 'es'
                                      ? 'Config.'
                                      : 'Settings',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                            GestureDetector(
                            onTap: () => _handleUploadButtonPress(context), 
                            child: CardItem(
                            imagePath: 'assets/images/Folder Up.png',
                            label: languageProvider.currentLanguage == 'es'
                            ? 'Subir'
                            : 'Upload',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Positioned(
                  top: 8,
                  child: my_menu.MenuBar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}