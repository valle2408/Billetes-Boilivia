import 'package:flutter/material.dart';

class Advertencias extends StatelessWidget {
  const Advertencias({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        ' Escanee solo billetes.\n'
        ' Otros objetos pueden dar resultados incorrectos.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}