import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ListaEntregasPage extends StatefulWidget {
  const ListaEntregasPage({super.key});

  @override
  State<ListaEntregasPage> createState() => _ListaEntregasPageState();
}

class _ListaEntregasPageState extends State<ListaEntregasPage> {
  List<Map<String, dynamic>> entregas = [];

  @override
  void initState() {
    super.initState();
    _carregarEntregas();
  }

  Future<void> _carregarEntregas() async {
    final path = join(await getDatabasesPath(), 'entregas.db');
    final db = await openDatabase(path);
    final dados = await db.query("entregas", orderBy: "id DESC");
    setState(() {
      entregas = dados;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (entregas.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Histórico de Entregas")),
        body: Center(child: Text("Nenhuma entrega registrada.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Histórico de Entregas")),
      body: ListView.builder(
        itemCount: entregas.length,
        itemBuilder: (context, index) {
          final e = entregas[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: e['foto'] != null
                  ? Image.file(File(e['foto']), width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported),
              title: Text(e['descricao']),
              subtitle: Text("Lat: ${e['latitude']}, Long: ${e['longitude']}"),
            ),
          );
        },
      ),
    );
  }
}
