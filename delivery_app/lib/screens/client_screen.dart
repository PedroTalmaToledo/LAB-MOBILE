import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/pedido.dart';
import '../services/delivery_service.dart';
import '../services/notification_service.dart';
import 'client_history_screen.dart';
import 'rastrear_entrega_screen.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  List<Pedido> _entregas = [];

  @override
  void initState() {
    super.initState();
    _carregarEntregas();
  }

  Future<void> _carregarEntregas() async {
    try {
      final pedidos = await DeliveryService().listarPedidos();
      setState(() {
        _entregas = pedidos
            .where((p) => p.status != 'ENTREGUE' && p.status != 'CANCELADO')
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar entregas: $e')),
      );
    }
  }

  Future<void> _abrirMapa(String endereco) async {
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(endereco)}");
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
    final controllerOrigem = TextEditingController();
    final controllerDestino = TextEditingController();
    String tipoSelecionado = 'ELETRONICOS';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Novo Pedido"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controllerCliente,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Cliente',
                      hintText: 'Ex: João da Silva',
                    ),
                  ),
                  TextField(
                    controller: controllerOrigem,
                    decoration: const InputDecoration(
                      labelText: 'Endereço de Origem',
                      hintText: 'Ex: Av. Afonso Pena, 1500, Belo Horizonte',
                    ),
                  ),
                  TextField(
                    controller: controllerDestino,
                    decoration: const InputDecoration(
                      labelText: 'Endereço de Destino',
                      hintText: 'Ex: Rua A Jacarepaguá, 150, Rio de Janeiro',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: tipoSelecionado,
                    items: ['ELETRONICOS', 'ALIMENTOS', 'ROUPAS', 'OUTROS', 'MOVEIS', 'LIVROS']
                        .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                        .toList(),
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() {
                          tipoSelecionado = valor;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Tipo da Mercadoria'),
                  ),
                ],
              ),
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
                  final origem = controllerOrigem.text.trim();
                  final destino = controllerDestino.text.trim();

                  if (cliente.isEmpty || origem.isEmpty || destino.isEmpty || tipoSelecionado.isEmpty) return;

                  final pedido = Pedido(
                    cliente: cliente,
                    origem: origem,
                    destino: destino,
                    tipoMercadoria: tipoSelecionado,
                    status: 'ENVIADO',
                  );

                  final sucesso = await DeliveryService().criarPedido(pedido);
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (sucesso) {
                      await _carregarEntregas();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pedido criado com sucesso!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao criar pedido.')),
                      );
                    }
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _cancelarPedido(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar Pedido'),
        content: const Text('Tem certeza que deseja cancelar este pedido?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
        ],
      ),
    );

    if (confirmar == true) {
      await DeliveryService().atualizarStatus(id, 'CANCELADO');
      await _carregarEntregas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificacoes = Provider.of<NotificationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico de Entregas',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientHistoryScreen()),
              );
              _carregarEntregas();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirmar Logout'),
                  content: const Text('Tem certeza que deseja sair?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sair')),
                  ],
                ),
              );
              if (confirmar == true && mounted) Navigator.pushReplacementNamed(context, '/');
            },
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
                ? const Center(child: Text('Nenhum pedido ativo.'))
                : ListView.builder(
                    itemCount: _entregas.length,
                    itemBuilder: (context, index) {
                      final e = _entregas[index];
                      final cor = e.status == 'EM_PROCESSAMENTO' ? Colors.orange : Colors.grey;

                      return Card(
                        color: Colors.purple.shade50,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.inventory_2, color: cor),
                          title: Text(e.cliente),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('De: ${e.origem}'),
                              Text('Para: ${e.destino}'),
                              Text('Status: ${e.status}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.map),
                                tooltip: 'Ver no mapa',
                                onPressed: () => _abrirMapa(e.destino),
                              ),
                              IconButton(
                                icon: const Icon(Icons.location_searching),
                                tooltip: 'Rastrear Entrega',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RastrearEntregaScreen(pedido: e),
                                    ),
                                  );
                                },
                              ),
                              if (e.status == 'ENVIADO')
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Cancelar Pedido',
                                  onPressed: () => _cancelarPedido(e.id!),
                                ),
                            ],
                          ),
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
