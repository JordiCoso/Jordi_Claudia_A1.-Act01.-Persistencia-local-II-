import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/habito.dart';

class Databasehelper {
  /// La instancia unica de databasehelper
  static Databasehelper? _databasehelper;

  /// La base de datos unica para uso interno.
  late Database _baseDeDatos;

  /// Constructor privado para evitar que se pueda llamar a new.
  Databasehelper._crear();

  /// Constructor publico singleton asegura que solo hay una instancia de esta clase.
  static Future<Databasehelper> crear() async {
    if (_databasehelper != null) {
      return await Future.value(_databasehelper);
    }

    var inicializando = Databasehelper._crear();

    inicializando._baseDeDatos = await inicializando._getInstanciaBD;

    _databasehelper = inicializando;

    return inicializando;
  }

  /// NO llamar, solo usa para hacer el singleton.
  Database? _comprobacionInstanciaBD;

  /// NO llamar, solo se usa en el constructor [crear].
  Future<Database> get _getInstanciaBD async {
    if (_comprobacionInstanciaBD != null) {
      return _comprobacionInstanciaBD!;
    }

    _comprobacionInstanciaBD = await _generarBase();
    return _comprobacionInstanciaBD!;
  }

  /// Crea el archivo y la primera vez usa [creacionBaseDatos] para
  /// ejecutar los SQL de creación de tablas.
  Future<Database> _generarBase() async {
    final ruta = join(await getDatabasesPath(), 'habitos.db');

    var baseCreada = await openDatabase(
      ruta,
      version: 1,
      onCreate: creacionBaseDatos,
    );

    return baseCreada;
  }

  final tablaHabitos = 'habitos';
  final columnaHabitosId = 'id';
  final columnaHabitosNombre = 'nombre';

  final tablaUsuarios = 'usuarios';
  final columnaUsuariosUsuario = 'usuario';
  final columnaUsuariosNombre = 'nombre';
  final columnaUsuariosApellidos = 'apellidos';
  final columnaUsuariosEmail = 'email';
  final columnaUsuariosContrasena = 'contrasena';
  final columnaUsuariosFechacreacion = 'fecha_creacion';
  final columnaUsuariosRol = 'rol';

  final tablaEstadisticas = 'estadisticas';
  final columnaEstadisticasId = 'id';
  final columnaEstadisticasHabitoid = 'habito_id';
  final columnaEstadisticasFechacompletado = 'fecha_completado';
  final columnaEstadisticasRachaactual = 'racha_actual';
  final columnaEstadisticasDiascompletados = 'dias_completados';

  Future<void> creacionBaseDatos(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $tablaHabitos ('
      '$columnaHabitosId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$columnaHabitosNombre TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE $tablaUsuarios ('
      '$columnaUsuariosUsuario TEXT PRIMARY KEY, '
      '$columnaUsuariosNombre TEXT NOT NULL,'
      '$columnaUsuariosApellidos TEXT NOT NULL,'
      '$columnaUsuariosEmail TEXT NOT NULL UNIQUE,' // Lo pongo unique para q no se pueda registrar dos usuarios con el mismo correo.
      '$columnaUsuariosContrasena TEXT NOT NULL,'
      '$columnaUsuariosFechacreacion TEXT NOT NULL,'
      '$columnaUsuariosRol TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE $tablaEstadisticas ('
      '$columnaEstadisticasId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$columnaEstadisticasHabitoid INTEGER NOT NULL UNIQUE,'
      '$columnaEstadisticasFechacompletado TEXT,'
      '$columnaEstadisticasRachaactual INTEGER NOT NULL,'
      '$columnaEstadisticasDiascompletados INTEGER NOT NULL)',
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
    int resultado = await _baseDeDatos.insert(tablaUsuarios, {
      columnaUsuariosUsuario: usuario,
      columnaUsuariosNombre: nombre,
      columnaUsuariosApellidos: apellidos,
      columnaUsuariosEmail: email,
      columnaUsuariosContrasena: contrasena,
      columnaUsuariosFechacreacion: fechaCreacion,
      columnaUsuariosRol: rol,
    });

    return resultado;
  }

  //vamos a comprobar si el usuario existe
  Future<bool> existeUsuario(String usuario) async {
    final resultado = await _baseDeDatos.query(
      tablaUsuarios, //usamos el query para buscar un usuario
      where: '$columnaUsuariosUsuario = ?',
      //con el ? es el valor q estamos buscando
      whereArgs: [usuario],
    ); //el whereArgs sustituye el ? por el usuario buscado

    return resultado.isNotEmpty;
  }

  //comprobamos si existe el correo o no
  Future<bool> existeEmail(String email) async {
    final resultado = await _baseDeDatos.query(
      tablaUsuarios,
      where: '$columnaUsuariosEmail = ?',
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
    int resultado = await _baseDeDatos.insert(tablaEstadisticas, {
      columnaEstadisticasHabitoid: habitoId,
      columnaEstadisticasRachaactual: rachaActual,
      columnaEstadisticasDiascompletados: diasCompletados,
      columnaEstadisticasFechacompletado: fechaCompletado,
    });
    return resultado;
  }

  Future<List<Map<String, dynamic>>> obtenerEstadisticas(int habitoId) async {
    final resultado = await _baseDeDatos.query(
      tablaEstadisticas,
      where: '$columnaEstadisticasHabitoid = ?',
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
    int resultado = await _baseDeDatos.update(
      tablaEstadisticas,
      {
        columnaEstadisticasRachaactual: rachaActual,
        columnaEstadisticasDiascompletados: diasCompletados,
        columnaEstadisticasFechacompletado: fechaCompletado,
      },
      where: '$columnaEstadisticasHabitoid = ?',
      whereArgs: [habitoId],
    );
    return resultado;
  }

  void guardarHabitos(List<Habito> listaHabitos) async {
    List<String> jsonHabitos = [];
    for (Habito habito in listaHabitos) {
      var resultado = await _baseDeDatos.query(
        tablaHabitos,
        where: '$columnaHabitosId = ?',
        whereArgs: [habito.identificador],
      );

      if (resultado.isEmpty) {
        await _baseDeDatos.insert(tablaHabitos, {
          columnaHabitosId: habito.identificador,
          columnaHabitosNombre: habito.nombre,
        });
      } else {
        await _baseDeDatos.update(
          tablaHabitos,
          {},
          where: '$columnaHabitosId = ?',
          whereArgs: [habito.identificador],
        );
      }
    }
  }

  // TODO
  /*List<Habito> cargarHabitos(String usuario) {
    List<Map<String, Object?>> jsonHabitos = await _baseDeDatos.query(
      tablaHabitos,
      where: '$columnaHabitosUsuario = ?',
      whereArgs: [usuario],
    );
    return habitos;
  }*/
}
