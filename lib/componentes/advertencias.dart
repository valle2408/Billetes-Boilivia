import 'package:flutter/material.dart';

class Advertencias extends StatelessWidget {
  const Advertencias({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• Escanee solo billetes.',
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          '• Otros objetos pueden dar resultados incorrectos.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}