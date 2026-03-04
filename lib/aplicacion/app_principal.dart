import 'package:flutter/material.dart';
import '../pantallas/pantalla_escaneo.dart';

class AppPrincipal extends StatelessWidget {
  const AppPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billetes Bolivia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const PantallaEscaneo(),
    );
  }
}