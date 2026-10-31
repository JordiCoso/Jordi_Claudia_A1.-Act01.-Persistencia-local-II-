import 'dart:async';

import 'package:flutter/cupertino.dart';
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

  void creacionBaseDatos(Database db, int version) {
    db.execute(
      'CREATE TABLE habitos ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'nombre TEXT NOT NULL)',
    );
    db.execute('CREATE TABLE usuarios ('
        'usuario TEXT PRIMARY KEY, '
        'nombre TEXT NOT NULL'
        'apellidos TEXT NOT NULL'
        'email TEXT NOT NULL'
        'contrasena TEXT NOT NULL'
        'fecha_creacion TEXT NOT NULL'
        'rol TEXT NOT NULL)');
  }
}
