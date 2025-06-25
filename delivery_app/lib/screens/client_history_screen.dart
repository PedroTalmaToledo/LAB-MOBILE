import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/pedido.dart';
import '../services/delivery_service.dart';
import '../services/tracking_service.dart';

class ClientHistoryScreen extends StatelessWidget {
  const ClientHistoryScreen({super.key});

  Future<List<Pedido>> _carregarHistorico() async {
    final pedidos = await DeliveryService().listarPedidos();
    return pedidos.where((p) => p.status == 'ENTREGUE').toList();
  }

  Future<void> _mostrarDetalhes(BuildContext context, Pedido pedido) async {
    final endereco = pedido.destino;
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(endereco)}");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Detalhes da Entrega"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cliente: ${pedido.cliente}"),
              Text("Origem: ${pedido.origem}"),
              Text("Destino: ${pedido.destino}"),
              Text("Tipo: ${pedido.tipoMercadoria}"),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text("Ver Destino no Mapa"),
                onPressed: () async {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Não foi possível abrir o mapa.')),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.location_history),
                label: const Text("Última Localização do Motorista"),
                onPressed: () async {
                  final dados = await TrackingService().buscarUltimaLocalizacao(pedido.id.toString());

                  if (dados != null &&
                      dados['location'] != null &&
                      dados['location']['coordinates'] != null &&
                      dados['location']['coordinates'].length == 2) {
                    final coords = dados['location']['coordinates'];
                    final double lng = double.tryParse(coords[0].toString()) ?? 0.0;
                    final double lat = double.tryParse(coords[1].toString()) ?? 0.0;

                    if (lat != 0.0 && lng != 0.0) {
                      final rastreioUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
                      if (await canLaunchUrl(rastreioUrl)) {
                        await launchUrl(rastreioUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Não foi possível abrir a última localização.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Localização indisponível.')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Localização indisponível.')),
                    );
                  }
                },
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
      body: FutureBuilder<List<Pedido>>(
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
                  title: Text(e.tipoMercadoria),
                  subtitle: Text("Cliente: ${e.cliente}"),
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
