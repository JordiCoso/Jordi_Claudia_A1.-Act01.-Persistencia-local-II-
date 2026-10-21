import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Databasehelper {
  // variable de clase para no abrir base de datos otra vez.
  late Database _baseDeDatos;

  //Especifico un constructor privado para que no se pueda llamar a new.
  Databasehelper._crear() {}

  static Future<Databasehelper> crear() async {
    var inicializando = Databasehelper._crear();

    final ruta = join(await getDatabasesPath(), 'habitos.db');

    inicializando._baseDeDatos = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE habitos ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'nombre TEXT NOT NULL)',
      ),
    );

    return inicializando;
  }
}
