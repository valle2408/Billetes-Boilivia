import 'package:flutter/material.dart';

class PantallaAcerca extends StatelessWidget {
  const PantallaAcerca({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de nosotros')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Aquí tú editarás lo que quieras.\n'
          'Ej: descripción, contacto, versión, etc.',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}