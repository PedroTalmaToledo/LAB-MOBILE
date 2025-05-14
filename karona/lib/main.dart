// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Entregas',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const LoginPage(),
      routes: {
        '/home': (_) => const Scaffold(
              body: Center(child: Text('Página Inicial (placeholder)')),
            ),
      },
    );
  }
}
