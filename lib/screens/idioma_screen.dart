import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart'; // 
import '../providers/theme_provider.dart'; // Importa tu ThemeProvider
import '../widgets/widgets_homepage/header_section.dart';
import '../widgets/widgets_idioma_screen/back_button.dart' as my_back;
import '../widgets/widgets_idioma_screen/menu_bar.dart' as my_menu;
import '../constants/app_colors.dart';

class IdiomaScreen extends StatelessWidget {
  const IdiomaScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                      // Header section (con el logo y la campana de notificaciones)
                      HeaderSection(
                      
                      ),

                      Container(
                        margin: const EdgeInsets.only(top: 28),
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
                          children: [
                            ListTile(
                              title: Text(
                                'Español',
                                style: TextStyle(
                                  fontFamily: 'Inria Serif',
                                  fontSize: 16,
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.white,
                                ),
                              ),
                              trailing: languageProvider.currentLanguage == 'es'
                                  ? const Icon(Icons.check, color: AppColors.primary)
                                  : null,
                              onTap: () {
                                languageProvider.changeLanguage('es');
                              },
                            ),
                            const Divider(color: Colors.grey),
                            ListTile(
                              title: Text(
                                'English',
                                style: TextStyle(
                                  fontFamily: 'Inria Serif',
                                  fontSize: 16,
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.white,
                                ),
                              ),
                              trailing: languageProvider.currentLanguage == 'en'
                                  ? const Icon(Icons.check, color: AppColors.primary)
                                  : null,
                              onTap: () {
                                languageProvider.changeLanguage('en');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                                    // Menu bar (positioned at the top-left)
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