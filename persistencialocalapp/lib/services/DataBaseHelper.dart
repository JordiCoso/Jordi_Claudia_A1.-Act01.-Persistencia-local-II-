import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final ruta = join(
    await getDatabasesPath(), 'habitos.db');
final db = await openDatabase(
ruta,
version: 1,
onCreate: (db, version) => db.execute(
'CREATE TABLE habitos ('
'id INTEGER PRIMARY KEY AUTOINCREMENT, '
'nombre TEXT NOT NULL)'),
);