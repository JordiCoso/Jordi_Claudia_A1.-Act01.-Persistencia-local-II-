import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Databasehelper {
  // variable de clase para no abrir base de datos otra vez.
  static final _baseDeDatos = Databasehelper._crear();
  static Databasehelper get = _baseDeDatos;
  bool isInitialized = false;
  Database? _basedatos;

  //Especifico un constructor privado para que no se pueda llamar a new.
  Databasehelper._crear();

  Future<Database?> basedatos() async {
    if (!isInitialized) await _iniciar();
    return _basedatos;
  }

  Future _iniciar() async {
    final ruta = join(await getDatabasesPath(), 'habitos.db');

    _basedatos = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE habitos ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'nombre TEXT NOT NULL)',
      ),
    );
  }
}
