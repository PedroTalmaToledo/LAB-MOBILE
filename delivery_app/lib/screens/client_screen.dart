import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/delivery_database.dart';
import '../services/notification_service.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  List<Map<String, dynamic>> _entregas = [];

  @override
  void initState() {
    super.initState();
    _carregarEntregas();
  }

  Future<void> _carregarEntregas() async {
    final dados = await DeliveryDatabase.listarEntregas();
    final ids = <String, Map<String, dynamic>>{};

    for (var e in dados) {
      final key = '${e['cliente']}_${e['descricao']}';
      if (!ids.containsKey(key) || e['id'] > ids[key]!['id']) {
        ids[key] = e;
      }
    }

    setState(() => _entregas = ids.values.toList());
  }

  Future<void> _abrirMapa(String coordenadas) async {
    final partes = coordenadas.split(',');
    if (partes.length != 2) return;
    final lat = partes[0].trim();
    final lng = partes[1].trim();
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa.')),
      );
    }
  }

  Future<void> _criarPedido() async {
    final controllerCliente = TextEditingController();
    final controllerEndereco = TextEditingController();
    final controllerDescricao = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Novo Pedido"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controllerCliente, decoration: const InputDecoration(labelText: 'Nome do Cliente')),
              TextField(controller: controllerEndereco, decoration: const InputDecoration(labelText: 'Endereço')),
              TextField(controller: controllerDescricao, decoration: const InputDecoration(labelText: 'Descrição do Pedido')),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Salvar"),
              onPressed: () async {
                final cliente = controllerCliente.text.trim();
                final endereco = controllerEndereco.text.trim();
                final descricao = controllerDescricao.text.trim();

                if (cliente.isEmpty || endereco.isEmpty || descricao.isEmpty) return;

                final pos = await Geolocator.getCurrentPosition();
                final agora = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

                await DeliveryDatabase.salvarEntrega(
                  cliente: cliente,
                  endereco: endereco,
                  descricao: descricao,
                  status: 'Pendente',
                  foto: '',
                  data: agora,
                  localizacao: '',
                  lat: pos.latitude,
                  lng: pos.longitude,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  await _carregarEntregas();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificacoes = Provider.of<NotificationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarEntregas,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _criarPedido,
        icon: const Icon(Icons.add),
        label: const Text("Novo Pedido"),
      ),
      body: Column(
        children: [
          if (notificacoes.mensagem != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.notifications),
                label: Text(notificacoes.mensagem!),
                onPressed: () => notificacoes.limpar(),
              ),
            ),
          Expanded(
            child: _entregas.isEmpty
                ? const Center(child: Text('Nenhum pedido criado ainda.'))
                : ListView.builder(
              itemCount: _entregas.length,
              itemBuilder: (context, index) {
                final e = _entregas[index];
                final status = e['status'] as String;
                final cor = status == 'Entregue'
                    ? Colors.green
                    : status == 'Saiu para entrega'
                    ? Colors.orange
                    : Colors.grey;
                final local = e['localizacao'] ?? '';

                return Card(
                  color: Colors.purple.shade50,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.inventory_2, color: cor),
                    title: Text(e['cliente']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${e['descricao']}'),
                        Text('Status: $status'),
                      ],
                    ),
                    trailing: local.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.map),
                      tooltip: 'Ver no mapa',
                      onPressed: () => _abrirMapa(local),
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
