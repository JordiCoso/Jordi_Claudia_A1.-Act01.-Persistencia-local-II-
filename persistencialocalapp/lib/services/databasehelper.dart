import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Databasehelper {
  static Databasehelper? _databasehelper;

  Databasehelper._crear();

  static Future<Databasehelper> crear() async {
    if (_databasehelper != null) {
      return await Future.value(_databasehelper);
    }

    var inicializando = Databasehelper._crear();

    inicializando._basedatos = await inicializando._getbasedatos;

    _databasehelper = inicializando;

    return inicializando;
  }

  Database? _basedatos;

  Future<Database> get _getbasedatos async {
    if (_basedatos != null) {
      return _basedatos!;
    }

    _basedatos = await _generarBase();
    return _basedatos!;
  }

  Future<Database> _generarBase() async {
    final ruta = join(await getDatabasesPath(), 'habitos.db');

    var baseCreada = await openDatabase(
      ruta,
      version: 1,
      onCreate: creacionBaseDatos,
    );

    return baseCreada;
  }

  Future<void> creacionBaseDatos(Database db, int version) async {
    await db.execute(
      'CREATE TABLE habitos ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'nombre TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE usuarios ('
      'usuario TEXT PRIMARY KEY, '
      'nombre TEXT NOT NULL,'
      'apellidos TEXT NOT NULL,'
      'email TEXT NOT NULL UNIQUE,' //lo pongo unique para q no se pueda registrar dos usuarios con el mismo correo.
      'contrasena TEXT NOT NULL,'
      'fecha_creacion TEXT NOT NULL,'
      'rol TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE estadisticas ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'habito_id INTEGER NOT NULL UNIQUE,'
      'fecha_completado TEXT,'
      'racha_actual INTEGER NOT NULL,'
      'dias_completados INTEGER NOT NULL)',
    );
  }

  //creamos el método para insertar el usuario
  Future<int> insertarUsuario(
    String usuario,
    String nombre,
    String apellidos,
    String email,
    String contrasena,
    String fechaCreacion,
    String rol,
  ) async {
    Database db = await _getbasedatos;
    int resultado = await db.insert('usuarios', {
      'usuario': usuario,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'contrasena': contrasena,
      'fecha_creacion': fechaCreacion,
      'rol': rol,
    });

    return resultado;
  }

  //vamos a comprobar si el usuario existe
  Future<bool> existeUsuario(String usuario) async {
    Database db = await _getbasedatos;

    final resultado = await db.query(
      'usuarios', //usamos el query para buscar un usuario
      where: 'usuario = ?', //con el ? es el valor q estamos buscando
      whereArgs: [usuario],
    ); //el whereArgs sustituye el ? por el usuario buscado

    return resultado.isNotEmpty;
  }

  //comprobamos si existe el correo o no
  Future<bool> existeEmail(String email) async {
    Database db = await _getbasedatos;

    final resultado = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );

    return resultado.isNotEmpty;
  }

  //guardamos las estadisticas
  Future<int> insertarEstadisticas(
    int habitoId,
    int rachaActual,
    int diasCompletados,
    String? fechaCompletado,
  ) async {
    Database db = await _getbasedatos;

    int resultado = await db.insert('estadisticas', {
      'habito_id': habitoId,
      'racha_actual': rachaActual,
      'dias_completados': diasCompletados,
      'fecha_completado': fechaCompletado,
    });
    return resultado;
  }

  Future<List<Map<String, dynamic>>> obtenerEstadisticas(int habitoId) async {
    Database db = await _getbasedatos;

    final resultado = await db.query(
      'estadisticas',
      where: 'habito_id = ?',
      whereArgs: [habitoId],
    );

    return resultado;
  }

  /*
  actualizamos la racha, dias completados y la ultima fecha usando
  update para modificar el registro.
   */
  Future<int> actualizarEstadisticas(
    int habitoId,
    int rachaActual,
    int diasCompletados,
    String? fechaCompletado,
  ) async {
    Database db = await _getbasedatos;

    int resultado = await db.update(
      'estadisticas',
      {
        'racha_actual': rachaActual,
        'dias_completados': diasCompletados,
        'fecha_completado': fechaCompletado,
      },
      where: 'habito_id = ?',
      whereArgs: [habitoId],
    );
    return resultado;
  }
}
