enum EstadoValidacion { legal, ilegal, noLeido }

class ResultadoValidacion {
  final EstadoValidacion estado;
  final String mensaje;
  final int? corte;
  final String? serie;
  final String? numeroStr;

  const ResultadoValidacion({
    required this.estado,
    required this.mensaje,
    this.corte,
    this.serie,
    this.numeroStr,
  });
}