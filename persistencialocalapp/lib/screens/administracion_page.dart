import 'package:flutter/material.dart';

import '../services/databasehelper.dart';

class AdministracionPage extends StatefulWidget {
  final Databasehelper _databasehelper;

  const AdministracionPage({super.key, required Databasehelper databasehelper})
    : _databasehelper = databasehelper;

  @override
  State<AdministracionPage> createState() => _AdministracionPageState();
}

class _AdministracionPageState extends State<AdministracionPage> {
  List<Map<String, Object?>> listaUsuarios = [];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final usuarios = await widget._databasehelper.obtenerUsuarios();

    if (!mounted) return;

    setState(() {
      listaUsuarios = usuarios;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Administración')),
      body: ListView.builder(
        itemCount: listaUsuarios.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              listaUsuarios[index][Databasehelper.columnaUsuariosUsuario]
                  .toString(),
            ),
            subtitle: Text(
              listaUsuarios[index][Databasehelper.columnaUsuariosRol]
                  .toString(),
            ),
          );
        },
      ),
    );
  }
}
