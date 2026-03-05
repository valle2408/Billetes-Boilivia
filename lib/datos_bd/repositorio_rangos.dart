import 'bd_local.dart';

class RepositorioRangos {
  /// Regla (modo BCB):
  /// - Para comparar, el serial se interpreta como NÚMERO (ignora ceros a la izquierda).
  /// - Si el número cae dentro de cualquier rango para el corte/serie => ILEGAL.
  /// - Esto coincide con el verificador del BCB (0 adelante no cambia el valor).
  Future<bool> esInvalidoPorNumero({
    required int corte,
    required String serie,
    required int numeroInt,
  }) async {
    final db = await BdLocal.instancia();

    final res = await db.rawQuery(
      '''
      SELECT 1
      FROM series_invalidas
      WHERE corte = ?
        AND serie = ?
        AND ? BETWEEN numero_inicio AND numero_fin
      LIMIT 1
      ''',
      [corte, serie, numeroInt],
    );

    return res.isNotEmpty;
  }
}