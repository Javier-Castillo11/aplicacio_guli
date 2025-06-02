import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/widgets_homepage/header_section.dart';
import '../widgets/widgets_configuraciones_screen/menu_bar.dart' as my_menu;
import '../widgets/widgets_configuraciones_screen/back_button.dart' as my_back;
import '../widgets/widgets_configuraciones_screen/cuenta_item.dart';
import '../widgets/widgets_configuraciones_screen/idioma_item.dart';
import '../constants/app_colors.dart';
import 'idioma_screen.dart';


class ConfiguracionesScreen extends StatelessWidget {
  const ConfiguracionesScreen({Key? key}) : super(key: key);



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

                      Padding(
                        padding: const EdgeInsets.only(left: 3, top: 28),
                        child: Text(
                          languageProvider.currentLanguage == 'es'
                              ? 'Configuración'
                              : 'Settings',
                          style: TextStyle(
                            fontFamily: 'Inria Serif',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? Colors.grey[800] : AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.primary,
                              blurRadius: 4,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CuentaItem(),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                languageProvider.currentLanguage == 'es'
                                    ? 'Cambia tu contraseña o cierra sesión'
                                    : 'Change your password or log out',
                                style: TextStyle(
                                  fontFamily: 'Inria Serif',
                                  fontSize: 14,
                                  color: themeProvider.isDarkMode ? Colors.white : AppColors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.grey),
                            const SizedBox(height: 16),
                            IdiomaItem(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const IdiomaScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                languageProvider.currentLanguage == 'es'
                                    ? 'Cambia el idioma de la aplicación'
                                    : 'Change the application language',
                                style: TextStyle(
                                  fontFamily: 'Inria Serif',
                                  fontSize: 14,
                                  color: themeProvider.isDarkMode ? Colors.white : AppColors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.grey),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: Text(
                                languageProvider.currentLanguage == 'es'
                                    ? 'Modo Oscuro'
                                    : 'Dark Mode',
                                style: TextStyle(
                                  fontFamily: 'Inria Serif',
                                  fontSize: 16,
                                  color: themeProvider.isDarkMode ? Colors.white : const Color.fromARGB(255, 138, 138, 138),
                                ),
                              ),
                              value: themeProvider.isDarkMode,
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                              },
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