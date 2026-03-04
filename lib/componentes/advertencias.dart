import 'package:flutter/material.dart';

class Advertencias extends StatelessWidget {
  const Advertencias({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• Escanee solo cortes de 10, 20 y 50 Bs.', style: TextStyle(fontSize: 12)),
        SizedBox(height: 4),
        Text('• No escanear otros billetes; puede dar error.', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}