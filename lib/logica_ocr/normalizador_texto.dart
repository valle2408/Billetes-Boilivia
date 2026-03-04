class NormalizadorTexto {
  static String basico(String raw) {
    var s = raw.toUpperCase();
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  /// Esto SOLO se aplica a la parte numérica (para evitar comerse el 0).
  static String corregirSoloDigitos(String rawDigitsLike) {
    var s = rawDigitsLike.toUpperCase();
    s = s
        .replaceAll('O', '0')
        .replaceAll('I', '1')
        .replaceAll('L', '1')
        .replaceAll('Z', '2')
        .replaceAll('G', '6');
    return s;
  }
}