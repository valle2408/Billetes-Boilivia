import 'package:flutter/material.dart';
import '../logica_validacion/resultado_validacion.dart';

class BannerResultado extends StatelessWidget {
  final ResultadoValidacion resultado;

  const BannerResultado({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final color = switch (resultado.estado) {
      EstadoValidacion.legal => Colors.green,
      EstadoValidacion.ilegal => Colors.red,
      EstadoValidacion.noLeido => Colors.grey,
    };

    final titulo = switch (resultado.estado) {
      EstadoValidacion.legal => 'LEGAL',
      EstadoValidacion.ilegal => 'ILEGAL',
      EstadoValidacion.noLeido => 'NO SE PUDO LEER',
    };

    final corteTxt = resultado.corte == null ? '-' : '${resultado.corte} Bs';
    final serieTxt = resultado.serie ?? '-';
    final numeroTxt = resultado.numeroStr ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Corte: $corteTxt  Número de serie : $numeroTxt $serieTxt ',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            resultado.mensaje,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}