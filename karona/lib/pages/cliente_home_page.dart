import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_provider.dart';
import '../services/delivery_provider.dart';
import 'login_page.dart';

class ClienteHomePage extends StatelessWidget {
  const ClienteHomePage({super.key});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final acceptedDeliveries =
        Provider.of<DeliveryProvider>(context).acceptedDeliveries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Exibir notificações
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Navegar para histórico de pedidos
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
                'Olá, Cliente',
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
              'Suas entregas aceitas:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: acceptedDeliveries.isEmpty
                  ? const Center(
                      child: Text('Nenhuma entrega aceita ainda.'),
                    )
                  : ListView.builder(
                      itemCount: acceptedDeliveries.length,
                      itemBuilder: (context, index) {
                        final delivery = acceptedDeliveries[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: Text('Entrega #${delivery['id']}'),
                            subtitle:
                                Text('Local: ${delivery['address']}'),
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
