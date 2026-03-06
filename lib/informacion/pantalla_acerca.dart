import 'package:flutter/material.dart';

class PantallaAcerca extends StatelessWidget {
  const PantallaAcerca({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de nosotros')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            const Text(
              'Billetes Bolivia — v2.0',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 14),

            // ===== 3) Párrafo del contexto + propósito + condolencias =====
            const Text(
              'Esta aplicación fue desarrollada como apoyo informativo y de verificación '
              'ante las repercusiones y la preocupación generadas tras el accidente ocurrido '
              'en el aeropuerto de El Alto, Bolivia. Nuestro objetivo es ayudar a los usuarios a '
              'identificar, mediante escaneo, series que puedan estar dentro de rangos reportados '
              'como inválidos.\n\n'
              'Este proyecto no tiene fines de lucro ni busca generar ingresos. '
              'Expresamos nuestras condolencias a las familias afectadas por los hechos y '
              'reafirmamos el compromiso de aportar con una herramienta útil y responsable.',
              style: TextStyle(fontSize: 14, height: 1.35),
            ),

            const SizedBox(height: 18),

            // ===== 4) Contacto =====
            const Text(
              'Contacto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            const Text(
              'Ing. Jhonattan Ibarra Condo y colaboradores',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text('Cel: 69859294', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            const Text(
              'Correo: developmentgroupibarra@gmail.com',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 6),
            // ===== 1) Información (imágenes) =====
            const Text(
              'Información: cortes de billetes invalidos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            _TarjetaBillete(
              titulo: 'Billete de 10 Bs.',
              asset: 'assets/10bs.jpg',
            ),
            const SizedBox(height: 12),

            _TarjetaBillete(
              titulo: 'Billete de 20 Bs.',
              asset: 'assets/20bs.jpg',
            ),
            const SizedBox(height: 12),

            _TarjetaBillete(
              titulo: 'Billete de 50 Bs.',
              asset: 'assets/50bs.jpg',
            ),

            const SizedBox(height: 22),
            const Divider(),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _TarjetaBillete extends StatelessWidget {
  final String titulo;
  final String asset;

  const _TarjetaBillete({required this.titulo, required this.asset});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) {
                  return const Center(
                    child: Text(
                      'Imagen no encontrada.\nSuba el archivo a assets.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
