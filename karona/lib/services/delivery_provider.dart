import 'package:flutter/material.dart';

class DeliveryProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _deliveries = List.generate(5, (index) {
    return {
      'id': index + 1,
      'address': 'Rua Exemplo, ${100 + index}',
      'status': 'Pendente',
    };
  });

  List<Map<String, dynamic>> get allDeliveries => _deliveries;

  List<Map<String, dynamic>> get acceptedDeliveries =>
      _deliveries.where((d) => d['status'] == 'Aceito').toList();

  void acceptDelivery(int id) {
    final idx = _deliveries.indexWhere((d) => d['id'] == id);
    if (idx != -1) {
      _deliveries[idx]['status'] = 'Aceito';
      notifyListeners();
    }
  }
}
