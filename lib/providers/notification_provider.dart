import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  List<String> _notifications = [];
  bool _hasNewNotification = false;
  String? _userRole; ///////// con esto se almacena el rol del usuario

  String? get userRole => _userRole;

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  List<String> get notifications => _notifications;
  bool get hasNewNotification => _hasNewNotification;

  // Método modificado para agregar notificaciones filtradas por rol
  void addRoleBasedNotification(String notification, {required String targetRole}) {
    if (_userRole == targetRole) {
      _notifications.add(notification);
      _hasNewNotification = true;
      notifyListeners();
    }
    // Si el rol no coincide, se ignora la notificación
  }

  // Método para marcar las notificaciones como leídas
  void markNotificationsAsRead() {
    _hasNewNotification = false;
    notifyListeners();
  }

  // Método para limpiar todas las notificaciones
  void clearNotifications() {
    _notifications.clear();
    _hasNewNotification = false;
    notifyListeners();
  }
}