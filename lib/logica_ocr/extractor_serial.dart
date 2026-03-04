import 'normalizador_texto.dart';

class DatosSerial {
  final String numeroStr; // ej: 012061951 (NO perder el 0)
  final String serie; // A o B
  const DatosSerial(this.numeroStr, this.serie);
}

class ExtractorSerial {
  static DatosSerial? extraer(String textoOcr) {
    final t = NormalizadorTexto.basico(textoOcr);

    // Nota: permite caracteres que el OCR confunde (O/I/L/Z/G) en zona numérica, luego corregimos.
    final re = RegExp(r'\b([0-9OILZG]{8,9})\s*([AB])\b');

    final matches = re.allMatches(t).toList();
    if (matches.isEmpty) return null;

    // Tomamos el último match (suele estar cerca del serial)
    final m = matches.last;
    final rawNum = m.group(1)!;
    final serie = m.group(2)!;

    final fixedNum = NormalizadorTexto.corregirSoloDigitos(rawNum);

    if (!RegExp(r'^\d{8,9}$').hasMatch(fixedNum)) return null;

    return DatosSerial(fixedNum, serie);
  }
}