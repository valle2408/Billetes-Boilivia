import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BdLocal {
  // AJUSTA ESTA RUTA a lo que tengas en pubspec.yaml
  static const String rutaAssetDb = 'assets/seguridad_bolivia.db';
  static const String nombreDb = 'seguridad_bolivia.db';

  static Database? _db;

  static Future<Database> instancia() async {
    _db ??= await _abrirCopiandoDesdeAssets();
    return _db!;
  }

  static Future<Database> _abrirCopiandoDesdeAssets() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, nombreDb);

    final existe = await File(dbPath).exists();
    if (!existe) {
      final data = await rootBundle.load(rutaAssetDb);
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(dbPath);
  }
}