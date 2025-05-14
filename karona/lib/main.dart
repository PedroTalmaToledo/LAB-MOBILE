import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/cliente/home_cliente.dart';
import 'screens/motorista/home_motorista.dart';
import 'screens/historico_entregas.dart';
import 'services/sincronizacao_service.dart';


void main() {
  runApp(const EntregasApp());
}

class EntregasApp extends StatefulWidget {
  const EntregasApp({super.key});

  @override
  State<EntregasApp> createState() => _EntregasAppState();
}

class _EntregasAppState extends State<EntregasApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entregas App',
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomePage(onThemeToggle: _toggleTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(bool) onThemeToggle;
  const HomePage({super.key, required this.onThemeToggle});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isMotorista = false;
  bool _isDark = false;

  List<Widget> get _pages {
    if (_isMotorista) {
      return const [
        HomeMotorista(),
        ListaEntregasPage(),
      ];
    } else {
      return const [
        HomeCliente(),
        ListaEntregasPage(),
      ];
    }
  }


  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _togglePerfil(bool value) {
    setState(() {
      _isMotorista = value;
      _selectedIndex = 0;
    });
  }

  void _toggleThemeSwitch(bool value) {
    setState(() => _isDark = value);
    widget.onThemeToggle(value);
  }

  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDark = prefs.getBool('isDark') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isMotorista ? "Modo Motorista" : "Modo Cliente"),
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(
                value: _isDark,
                onChanged: _toggleThemeSwitch,
              ),
              const Icon(Icons.dark_mode),
              const SizedBox(width: 16),
              const Text("Cliente"),
              Switch(
                value: _isMotorista,
                onChanged: _togglePerfil,
              ),
              const Text("Motorista"),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Histórico"),
        ],
      ),
    );
  }
}
