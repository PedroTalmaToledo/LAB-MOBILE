import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/delivery_database.dart';

class ClientHistoryScreen extends StatelessWidget {
  const ClientHistoryScreen({super.key});

  Future<List<Map<String, dynamic>>> _carregarHistorico() async {
    final entregas = await DeliveryDatabase.listarEntregas();
    return entregas.where((e) => e['status'] == 'Entregue').toList();
  }

  Future<void> _mostrarDetalhes(BuildContext context, Map<String, dynamic> entrega) async {
    final local = entrega['localizacao'] ?? '';
    final podeVerMapa = local.contains(',');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Detalhes da Entrega"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cliente: ${entrega['cliente']}"),
              Text("Endereço: ${entrega['endereco']}"),
              Text("Descrição: ${entrega['descricao']}"),
              Text("Data: ${entrega['data']}"),
              if (podeVerMapa)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text("Ver no mapa"),
                    onPressed: () async {
                      final partes = local.split(',');
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
                    },
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Fechar"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Histórico de Entregas")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _carregarHistorico(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final entregas = snapshot.data!;
          if (entregas.isEmpty) return const Center(child: Text("Nenhuma entrega concluída."));
          return ListView.builder(
            itemCount: entregas.length,
            itemBuilder: (context, index) {
              final e = entregas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(e['descricao']),
                  subtitle: Text("Cliente: ${e['cliente']}"),
                  trailing: const Text("✅ Entregue"),
                  onTap: () => _mostrarDetalhes(context, e),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
