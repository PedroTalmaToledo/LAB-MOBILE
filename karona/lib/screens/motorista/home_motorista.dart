import 'package:flutter/material.dart';

class HomeMotorista extends StatelessWidget {
  const HomeMotorista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Motorista")),
      body: const Center(child: Text("Entregas e registro (em breve)")),
    );
  }
}
