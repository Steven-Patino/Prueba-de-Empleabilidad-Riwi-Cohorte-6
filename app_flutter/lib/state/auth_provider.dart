import "package:flutter/material.dart";

import "../session.dart";

class AuthProvider extends ChangeNotifier {
  bool get isLoggedIn => Session.usuario.isNotEmpty;

  String get usuario => Session.usuario;

  void login(String usuario, String apiKey) {
    Session.usuario = usuario.trim();
    Session.apiKey = apiKey.trim();
    notifyListeners();
  }

  void logout() {
    Session.usuario = "";
    Session.apiKey = "";
    notifyListeners();
  }
}
