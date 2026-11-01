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
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: creacionBaseDatos,
    );

    return baseCreada;
  }

  // Claves en variables para juntarlas y evitar errores

  static const tablaHabitos = 'habitos';

  static const columnaHabitosId = 'hid';
  static const columnaHabitosNombre = 'nombre';
  static const columnaHabitosColor = 'color';
  static const columnaHabitosCompletado = 'completado';
  static const columnaHabitosUsuarioFK = 'usuario_fk';

  static const tablaUsuarios = 'usuarios';

  static const columnaUsuariosUsuario = 'usuario';
  static const columnaUsuariosNombre = 'nombre';
  static const columnaUsuariosApellidos = 'apellidos';
  static const columnaUsuariosEmail = 'email';
  static const columnaUsuariosContrasena = 'contrasena';
  static const columnaUsuariosFechacreacion = 'fecha_creacion';
  static const columnaUsuariosRol = 'rol';

  static const tablaEstadisticas = 'estadisticas';

  static const columnaEstadisticasId = 'eid';
  static const columnaEstadisticasFechacompletado = 'fecha_completado';
  static const columnaEstadisticasRachaactual = 'racha_actual';
  static const columnaEstadisticasDiascompletados = 'dias_completados';
  static const columnaEstadisticasHabitoidFK = 'habito_id_fk';
  static const columnaEstadisticasUsuarioFK = 'usuario_fk';

  Future<void> creacionBaseDatos(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $tablaUsuarios ('
      '$columnaUsuariosUsuario TEXT PRIMARY KEY, '
      '$columnaUsuariosNombre TEXT NOT NULL, '
      '$columnaUsuariosApellidos TEXT NOT NULL, '
      '$columnaUsuariosEmail TEXT NOT NULL UNIQUE, ' // Lo pongo unique para q no se pueda registrar dos usuarios con el mismo correo.
      '$columnaUsuariosContrasena TEXT NOT NULL, '
      '$columnaUsuariosFechacreacion TEXT NOT NULL, '
      '$columnaUsuariosRol TEXT NOT NULL)',
    );

    await db.execute(
      'CREATE TABLE $tablaHabitos ('
      '$columnaHabitosId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$columnaHabitosNombre TEXT NOT NULL, '
      '$columnaHabitosColor TEXT NOT NULL, ' // Lo guardo como texto porque es hexadecimal
      '$columnaHabitosCompletado TEXT NOT NULL, '
      '$columnaHabitosUsuarioFK TEXT NOT NULL, '
      'FOREIGN KEY ($columnaHabitosUsuarioFK) REFERENCES $tablaUsuarios($columnaUsuariosUsuario) ON DELETE CASCADE)',
    );

    await db.execute(
      'CREATE TABLE $tablaEstadisticas ('
      '$columnaEstadisticasId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$columnaEstadisticasFechacompletado TEXT, '
      '$columnaEstadisticasRachaactual INTEGER NOT NULL, '
      '$columnaEstadisticasDiascompletados INTEGER NOT NULL, '
      '$columnaEstadisticasUsuarioFK TEXT NOT NULL, '
      '$columnaEstadisticasHabitoidFK INTEGER NOT NULL UNIQUE, '
      'FOREIGN KEY $columnaEstadisticasUsuarioFK REFERENCES $tablaUsuarios($columnaUsuariosUsuario) ON DELETE CASCADE, '
      'FOREIGN KEY $columnaEstadisticasHabitoidFK REFERENCES $tablaHabitos($columnaHabitosId) ON DELETE CASCADE)',
    );
  }

  //creamos la funcion para insertar el usuario
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
      columnaEstadisticasHabitoidFK: habitoId,
      columnaEstadisticasRachaactual: rachaActual,
      columnaEstadisticasDiascompletados: diasCompletados,
      columnaEstadisticasFechacompletado: fechaCompletado,
    });
    return resultado;
  }

  Future<List<Map<String, dynamic>>> obtenerEstadisticas(int habitoId) async {
    final resultado = await _baseDeDatos.query(
      tablaEstadisticas,
      where: '$columnaEstadisticasHabitoidFK = ?',
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
      where: '$columnaEstadisticasHabitoidFK = ?',
      whereArgs: [habitoId],
    );
    return resultado;
  }

  void guardarHabitos(List<Habito> listaHabitos) async {
    for (Habito habito in listaHabitos) {
      var resultado = await _baseDeDatos.query(
        tablaHabitos,
        where: '$columnaHabitosId = ?',
        whereArgs: [habito.identificador],
      );

      if (resultado.isEmpty) {
        int hid = await _baseDeDatos.insert(tablaHabitos, {
          columnaHabitosNombre: habito.nombre,
          columnaHabitosColor: habito.convertirColorAString(habito.color),
          columnaHabitosCompletado: habito.completado as int,
          columnaHabitosUsuarioFK: habito.nombreUsuario,
        });
        await _baseDeDatos.insert(tablaEstadisticas, {
          columnaEstadisticasId: habito.identificadorEstadisticas,
          columnaEstadisticasFechacompletado: habito.fechaCompletado.toString(),
          columnaEstadisticasRachaactual: habito.rachaActual,
          columnaEstadisticasDiascompletados: habito.diasCompletados,
          columnaEstadisticasHabitoidFK: hid,
          columnaEstadisticasUsuarioFK: habito.nombreUsuario,
        });
      } else {
        if (habito.pendingBorrarse) {
          await _baseDeDatos.delete(
            tablaHabitos,
            where: '$columnaHabitosId = ?',
            whereArgs: [habito.identificador],
          );
          await _baseDeDatos.delete(
            tablaEstadisticas,
            where: '$columnaEstadisticasHabitoidFK = ?',
            whereArgs: [habito.identificador],
          );
        } else {
          await _baseDeDatos.update(
            tablaHabitos,
            {
              columnaHabitosNombre: habito.nombre,
              columnaHabitosColor: habito.convertirColorAString(habito.color),
              columnaHabitosCompletado: habito.completado as int,
            },
            where: '$columnaHabitosId = ?',
            whereArgs: [habito.identificador],
          );
          await _baseDeDatos.update(
            tablaEstadisticas,
            {
              columnaEstadisticasFechacompletado: habito.fechaCompletado
                  .toString(),
              columnaEstadisticasRachaactual: habito.rachaActual,
              columnaEstadisticasDiascompletados: habito.diasCompletados,
            },
            where: '$columnaEstadisticasHabitoidFK = ?',
            whereArgs: [habito.identificador],
          );
        }
      }
    }
  }

  Future<List<Habito>> cargarHabitos(String usuario) async {
    List<Habito> habitos = [];

    final List<Map<String, Object?>> keyValueHabitosIncompleto =
        await _baseDeDatos.query(
          tablaHabitos,
          where: '$columnaHabitosUsuarioFK = ?',
          whereArgs: [usuario],
        );

    final List<Map<String, Object?>> keyValueEstadisticas = await _baseDeDatos
        .query(
          tablaEstadisticas,
          where: '$columnaEstadisticasUsuarioFK = ?',
          whereArgs: [usuario],
        );

    /// Lista unificada de datos sobre habito.
    List<Map<String, Object?>> keyValueHabitos =
        keyValueHabitosIncompleto + keyValueEstadisticas;

    for (Map<String, Object?> fila in keyValueHabitos) {
      late int hid;
      late String nombreHabito;
      late String colorString;
      late int completadoInt;

      late int eid;
      late String fechaCompletadoString;
      late int rachaActual;
      late int diasCompletados;

      late String nombreUsuario;

      fila.forEach((columna, valor) {
        switch (columna) {
          case columnaHabitosId:
            hid = valor as int;
            break;
          case columnaHabitosNombre:
            nombreHabito = valor as String;
            break;
          case columnaHabitosColor:
            colorString = valor as String;
            break;
          case columnaHabitosCompletado:
            completadoInt = valor as int;
            break;
          case columnaEstadisticasId:
            eid = valor as int;
            break;
          case columnaEstadisticasFechacompletado:
            fechaCompletadoString = valor as String;
            break;
          case columnaEstadisticasRachaactual:
            rachaActual = valor as int;
            break;
          case columnaEstadisticasDiascompletados:
            diasCompletados = valor as int;
            break;
          case columnaHabitosUsuarioFK: // Solo lo necesitamos de una tabla.
            nombreUsuario = valor as String;
            break;

          default:
        }
      });

      final habito = Habito.fromBBDD(
        hid: hid,
        nombreHabito: nombreHabito,
        colorString: colorString,
        completadoInt: completadoInt,
        eid: eid,
        fechaCompletadoString: fechaCompletadoString,
        rachaActual: rachaActual,
        diasCompletados: diasCompletados,
        nombreUsuario: nombreUsuario,
      );

      habitos.add(habito);
    }

    return habitos;
  }
}
