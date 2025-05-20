import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/delivery_provider.dart';
import 'login_page.dart';

class MotoristaHomePage extends StatelessWidget {
  const MotoristaHomePage({super.key});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final deliveryProvider = Provider.of<DeliveryProvider>(context);
    final deliveries = deliveryProvider.allDeliveries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Motorista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              // TODO: Capturar foto de entrega
            },
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // TODO: Abrir mapa para navegação
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Olá, Motorista',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            SwitchListTile(
              title: const Text('Tema escuro'),
              value: isDark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
              secondary: const Icon(Icons.brightness_6),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                // TODO: Navegar para configurações
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entregas disponíveis:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: deliveries.length,
                itemBuilder: (context, index) {
                  final delivery = deliveries[index];
                  final accepted = delivery['status'] == 'Aceito';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.delivery_dining),
                      title: Text('Entrega #${delivery['id']}'),
                      subtitle: Text(
                        'Local: ${delivery['address']}\n'
                        'Status: ${delivery['status']}',
                      ),
                      trailing: accepted
                          ? const Text(
                              'Aceito',
                              style: TextStyle(color: Colors.green),
                            )
                          : ElevatedButton(
                              child: const Text('Aceitar'),
                              onPressed: () => deliveryProvider.acceptDelivery(
                                delivery['id'] as int,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
