import 'package:sqflite/sqflite.dart';
import 'bd_local.dart';

class RepositorioRangos {
  Future<bool> esInvalido({
    required int corte,
    required String serie,
    required int numeroInt,
  }) async {
    final Database db = await BdLocal.instancia();

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