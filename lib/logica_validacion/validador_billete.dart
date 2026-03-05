import '../datos_bd/repositorio_rangos.dart';
import '../logica_ocr/detector_corte.dart';
import '../logica_ocr/extractor_serial.dart';
import 'resultado_validacion.dart';

class ValidadorBillete {
  final RepositorioRangos repo;
  ValidadorBillete(this.repo);

  // ✅ Normaliza "como BCB": ignora ceros a la izquierda para comparar
  // Ej: "091889407" -> "91889407"
  //     "077317008" -> "77317008"
  //     "000000001" -> "1"
  //     "0" -> "0"
  int _aNumeroComparable(String numeroStr) {
    final soloDigitos = numeroStr.replaceAll(RegExp(r'[^0-9]'), '');
    final sinCerosIzq = soloDigitos.replaceFirst(RegExp(r'^0+'), '');
    final canon = sinCerosIzq.isEmpty ? '0' : sinCerosIzq;
    return int.parse(canon);
  }

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

    // ✅ Mantén lo leído para mostrar al usuario (con 0 si el OCR lo captó)
    final numeroLeido = datos.numeroStr;

    // ✅ Pero compara como BCB (ignorando ceros a la izquierda)
    final numeroComparable = _aNumeroComparable(numeroLeido);

    final invalido = await repo.esInvalidoPorNumero(
      corte: corte,
      serie: datos.serie,
      numeroInt: numeroComparable,
    );

    if (invalido) {
      return ResultadoValidacion(
        estado: EstadoValidacion.ilegal,
        mensaje: 'ILEGAL: coincide con un rango inválido.',
        corte: corte,
        serie: datos.serie,
        numeroStr: numeroLeido, // mostramos lo leído (no el canon)
      );
    }

    return ResultadoValidacion(
      estado: EstadoValidacion.legal,
      mensaje: 'LEGAL: no coincide con rangos inválidos.',
      corte: corte,
      serie: datos.serie,
      numeroStr: numeroLeido,
    );
  }
}