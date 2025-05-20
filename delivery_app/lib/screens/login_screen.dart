import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_shipping, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                'Delivery',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text("Entrar como Cliente"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () => Navigator.pushNamed(context, '/cliente'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.delivery_dining),
                label: const Text("Entrar como Motorista"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () => Navigator.pushNamed(context, '/motorista'),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/config'),
                child: const Text("Configurações"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
