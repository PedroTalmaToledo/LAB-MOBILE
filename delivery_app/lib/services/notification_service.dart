import 'package:flutter/material.dart';

class NotificationService with ChangeNotifier {
  String? mensagem;

  void mostrar(String texto) {
    mensagem = texto;
    notifyListeners();
  }

  void limpar() {
    mensagem = null;
    notifyListeners();
  }
}
