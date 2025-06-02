import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
//import '../../providers/notification_provider.dart';
import '../../constants/app_colors.dart';

class HeaderSection extends StatelessWidget {
  final bool hasNotification;
  final VoidCallback onNotificationPressed;

  const HeaderSection({
    Key? key,
    required this.hasNotification, // Cambiado a required
    required this.onNotificationPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return Container(
      height: 105,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 62),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  height: 60,
                  width: 60,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              width: 60,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      size: 25,
                    ),
                    onPressed: onNotificationPressed, // Usamos directamente el callback
                    tooltip: hasNotification
                        ? (languageProvider.currentLanguage == 'es'
                            ? 'Ver notificaciones'
                            : 'View notifications')
                        : (languageProvider.currentLanguage == 'es'
                            ? 'Sin notificaciones'
                            : 'No notifications'),
                  ),
                  if (hasNotification)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}