import 'dart:io';
import 'package:flutter/material.dart';
import '../database/delivery_database.dart';

class EntregasRealizadasScreen extends StatefulWidget {
  const EntregasRealizadasScreen({super.key});

  @override
  State<EntregasRealizadasScreen> createState() => _EntregasRealizadasScreenState();
}

class _EntregasRealizadasScreenState extends State<EntregasRealizadasScreen> {
  List<Map<String, dynamic>> entregas = [];

  @override
  void initState() {
    super.initState();
    _carregarEntregas();
  }

  Future<void> _carregarEntregas() async {
    final lista = await DeliveryDatabase.listarEntregas();
    setState(() {
      entregas = lista.where((e) => e['status'] == 'Entregue').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Entregas'),
      ),
      body: entregas.isEmpty
          ? const Center(
              child: Text('Nenhuma entrega realizada ainda.'),
            )
          : ListView.builder(
              itemCount: entregas.length,
              itemBuilder: (context, index) {
                final e = entregas[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    leading: e['foto'] != null && e['foto'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(e['foto']),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image_not_supported, size: 40),
                    title: Text(e['cliente']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pedido: ${e['descricao']}'),
                        Text('Endereço: ${e['endereco']}'),
                        Text('Data: ${e['data']}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
