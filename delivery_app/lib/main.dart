import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/client_screen.dart';
import 'screens/driver_screen.dart';
import 'screens/entregas_realizadas_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('tema_escuro') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => NotificationService(),
      child: MyApp(isDark: isDark),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isDark;
  const MyApp({super.key, required this.isDark});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDark;
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _darkMode = !_darkMode);
    await prefs.setBool('tema_escuro', _darkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bia Delivery',
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginScreen(),
        '/cliente': (context) => const ClientScreen(),
        '/motorista': (context) => const DriverScreen(),
        '/entregues': (context) => const EntregasRealizadasScreen(),
        '/config': (context) => SettingsScreen(onToggleTheme: _toggleTheme),
      },
    );
  }
}
