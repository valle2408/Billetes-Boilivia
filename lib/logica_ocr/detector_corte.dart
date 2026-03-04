class DetectorCorte {
  static int? detectar(String textoOcr) {
    final t = textoOcr.toUpperCase();

    // Buscar 10/20/50 como número aislado (más confiable)
    final candidatos = <int>[];
    final re = RegExp(r'(^|[^0-9])(10|20|50)([^0-9]|$)');
    for (final m in re.allMatches(t)) {
      final val = int.tryParse(m.group(2) ?? '');
      if (val != null) candidatos.add(val);
    }

    if (candidatos.isNotEmpty) {
      final conteo = <int, int>{};
      for (final c in candidatos) {
        conteo[c] = (conteo[c] ?? 0) + 1;
      }
      final ordenados = conteo.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return ordenados.first.key;
    }

    // Fallback por palabras (menos confiable)
    if (t.contains('DIEZ')) return 10;
    if (t.contains('VEINTE')) return 20;
    if (t.contains('CINCUENTA')) return 50;

    return null;
  }
}