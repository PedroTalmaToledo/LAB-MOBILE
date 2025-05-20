import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import 'login_page.dart';

class MotoristaHomePage extends StatefulWidget {
  const MotoristaHomePage({super.key});

  @override
  State<MotoristaHomePage> createState() => _MotoristaHomePageState();
}

class _MotoristaHomePageState extends State<MotoristaHomePage> {
  String _username = 'Motorista';

  @override
  void initState() {
    super.initState();
    // TODO: Carregar username via SharedPreferences ou API
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

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
                'Olá, $_username',
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
              onTap: _logout,
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
              'Bem-vindo, $_username',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'Entregas disponíveis:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // placeholder
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.delivery_dining),
                      title: Text('Entrega #${index + 1}'),
                      subtitle: const Text('Local: Rua Exemplo, 123'),
                      trailing: ElevatedButton(
                        child: const Text('Aceitar'),
                        onPressed: () {
                          // TODO: Lógica de aceitar entrega
                        },
                      ),
                      onTap: () {
                        // TODO: Detalhes da entrega
                      },
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
