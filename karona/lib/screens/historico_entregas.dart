import 'dart:io';
import 'package:flutter/material.dart';

class ListaEntregasPage extends StatelessWidget {
  final List<Map<String, dynamic>> entregas;
  const ListaEntregasPage({super.key, required this.entregas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Histórico de Entregas")),
      body: ListView.builder(
        itemCount: entregas.length,
        itemBuilder: (context, index) {
          final e = entregas[index];
          return ListTile(
            leading: e['foto'] != null ? Image.file(File(e['foto']), width: 50) : null,
            title: Text(e['descricao']),
            subtitle: Text("Lat: ${e['latitude']}, Long: ${e['longitude']}"),
          );
        },
      ),
    );
  }
}
