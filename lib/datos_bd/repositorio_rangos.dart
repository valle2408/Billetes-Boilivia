import 'bd_local.dart';

class RepositorioRangos {
  /// Regla del proyecto:
  /// - El serial se trata como String (incluye ceros a la izquierda).
  /// - SOLO se compara con rangos cuya longitud (en dígitos) coincide con la del serial.
  /// - Si coincide => ILEGAL; si no => LEGAL.
  Future<bool> esInvalidoPorSerial({
    required int corte,
    required String serie,
    required String numeroStr,
  }) async {
    final db = await BdLocal.instancia();

    final filas = await db.rawQuery(
      '''
      SELECT numero_inicio, numero_fin
      FROM series_invalidas
      WHERE corte = ? AND serie = ?
      ''',
      [corte, serie],
    );

    final lenSerial = numeroStr.length;

    for (final row in filas) {
      final ini = (row['numero_inicio'] as int).toString();
      final fin = (row['numero_fin'] as int).toString();

      // SOLO rangos con la misma cantidad de dígitos
      if (ini.length != lenSerial || fin.length != lenSerial) continue;

      // Comparación lexicográfica válida porque la longitud es igual
      if (numeroStr.compareTo(ini) >= 0 && numeroStr.compareTo(fin) <= 0) {
        return true;
      }
    }

    return false;
  }
}