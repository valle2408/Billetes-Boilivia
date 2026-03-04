import '../datos_bd/repositorio_rangos.dart';
import '../logica_ocr/detector_corte.dart';
import '../logica_ocr/extractor_serial.dart';
import 'resultado_validacion.dart';

class ValidadorBillete {
  final RepositorioRangos repo;
  ValidadorBillete(this.repo);

  Future<ResultadoValidacion> validar(String textoOcr) async {
    final corte = DetectorCorte.detectar(textoOcr);
    if (corte == null) {
      return const ResultadoValidacion(
        estado: EstadoValidacion.noLeido,
        mensaje: 'No se pudo detectar el corte (10/20/50). Reintente.',
      );
    }

    final datos = ExtractorSerial.extraer(textoOcr);
    if (datos == null) {
      return ResultadoValidacion(
        estado: EstadoValidacion.noLeido,
        mensaje: 'No se pudo leer número/serie. Reintente.',
        corte: corte,
      );
    }

    // Convertimos a int SOLO para comparar rangos (pero guardamos numeroStr con 0)
    final numeroInt = int.parse(datos.numeroStr);

    final invalido = await repo.esInvalido(
      corte: corte,
      serie: datos.serie,
      numeroInt: numeroInt,
    );

    if (invalido) {
      return ResultadoValidacion(
        estado: EstadoValidacion.ilegal,
        mensaje: 'ILEGAL: coincide con un rango inválido.',
        corte: corte,
        serie: datos.serie,
        numeroStr: datos.numeroStr,
      );
    }

    return ResultadoValidacion(
      estado: EstadoValidacion.legal,
      mensaje: 'LEGAL: no coincide con rangos inválidos.',
      corte: corte,
      serie: datos.serie,
      numeroStr: datos.numeroStr,
    );
  }
}