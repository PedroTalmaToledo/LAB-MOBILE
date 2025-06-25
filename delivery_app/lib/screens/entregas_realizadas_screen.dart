import 'dart:io';
import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/delivery_service.dart';

class EntregasRealizadasScreen extends StatefulWidget {
  const EntregasRealizadasScreen({super.key});

  @override
  State<EntregasRealizadasScreen> createState() => _EntregasRealizadasScreenState();
}

class _EntregasRealizadasScreenState extends State<EntregasRealizadasScreen> {
  List<Pedido> entregas = [];

  @override
  void initState() {
    super.initState();
    _carregarEntregas();
  }

  Future<void> _carregarEntregas() async {
    try {
      final pedidos = await DeliveryService().listarPedidos();
      setState(() {
        entregas = pedidos.where((p) => p.status == 'ENTREGUE').toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar entregas: $e')),
      );
    }
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
                    leading: const Icon(Icons.check_circle, size: 40, color: Colors.green),
                    title: Text(e.cliente),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo: ${e.tipoMercadoria}'),
                        Text('Origem: ${e.origem}'),
                        Text('Destino: ${e.destino}'),
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
