import 'package:flutter/material.dart';
import 'package:habitosapp/services/databasehelper.dart';
import 'package:habitosapp/widgets/boton_principal.dart';
import 'package:habitosapp/widgets/campo_texto_app.dart';

import '../models/colores.dart';
import '../services/preferenciasservice.dart';

import '../models/habito.dart';
import '../models/usuario.dart';
import '../widgets/boton_selecion_color.dart';
import '../widgets/tarjeta_habito.dart';

class Gestiondehabitos extends StatefulWidget {
  // Nos pasan usuario y preferencias service
  final PreferenciasService _preferenciasService;
  final Databasehelper _databasehelper;
  final Usuario _usuario;

  const Gestiondehabitos({
    super.key,
    required this._preferenciasService,
    required this._databasehelper,
    required this._usuario,
  });

  @override
  State<Gestiondehabitos> createState() => _GestiondehabitosState();
}

// Un enum para que sea mas legible que significa cada codigo de color.

class _GestiondehabitosState extends State<Gestiondehabitos> {
  List<Habito> listaHabitos =
      []; //lista donde guardaremos los habitos recuperados de sqflite

  /* Al ser una lista que cambia con el numero de habitos no puedo hardcodear
   * los editing controlers y una variable global de editar.
   * Asi que hago un Map para los controladores y los booleanos.
   * Map porque tengo que saber a cual pertenece mediante el indice.
   */
  Map<int, TextEditingController> textEditingControllers = {};
  Map<int, bool> editables = {};

  @override
  void initState() {
    super.initState();
    _cargarHabitos();
  }

  //cargamos los habitos del usuario desde el sqflite
  void _cargarHabitos() async {
    List<Habito> habitos = await widget._databasehelper.cargarHabitos(
      widget._usuario.nombre,
      widget._usuario.rol,
    );

    if (!mounted) {
      setState(() {
        listaHabitos = habitos;
      });
    }
  }

  @override
  void dispose() {
    // Nos desacemos de cada uno
    textEditingControllers.forEach((index, controller) => controller.dispose());
    // Limpio la lista para que no haya problemas
    textEditingControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctxt) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar habitos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hola ${widget._usuario.nombre}',
                style: TextStyle(fontSize: 50),
              ),

              ListView.builder(
                shrinkWrap: true,
                itemCount: listaHabitos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: CampoTextoApp(
                                etiqueta: 'Habito #$index',
                                controller: _darControllador(index),
                                enabled: _darEditable(index),
                                onEditingComplete: () => _editarHabito(index),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TarjetaHabito(
                                color:
                                    listaColores[NombreColores.naranja.index],
                                completado: false,
                                editar: () => _editarHabito(index),
                                eliminar: () => _borrarHabito(index),
                                cambiarIcono: (icono) =>
                                    _iconoSeleccion(icono, index),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: BotonSelecionColor(
                                color:
                                    listaColores[NombreColores.naranja.index],
                                pulsar: () {
                                  setState(() {
                                    _cambiarColorHabito(
                                      index,
                                      listaColores[NombreColores.naranja.index],
                                    );
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: BotonSelecionColor(
                                color: listaColores[NombreColores.azul.index],
                                pulsar: () {
                                  setState(() {
                                    _cambiarColorHabito(
                                      index,
                                      listaColores[NombreColores.azul.index],
                                    );
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: BotonSelecionColor(
                                color: listaColores[NombreColores.verde.index],
                                pulsar: () {
                                  setState(() {
                                    _cambiarColorHabito(
                                      index,
                                      listaColores[NombreColores.verde.index],
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              BotonPrincipal(
                texto: 'Crear',
                pulsar: () {
                  setState(() {
                    listaHabitos.add(
                      Habito(
                        listaHabitos.length,
                        'Habito nuevo #${listaHabitos.length}',
                        listaColores[NombreColores.verde.index],
                        DateTime(0),
                        nombreUsuario: widget._usuario.nombre,
                      ),
                    );
                  });
                },
              ),
              SizedBox(height: 20),
              BotonPrincipal(
                texto: 'Guardar',
                pulsar: () {
                  widget._databasehelper.guardarHabitos(listaHabitos);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 20),
              BotonPrincipal(
                texto: 'Cancelar',
                pulsar: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editarHabito(int index) {
    setState(() {
      editables[index] = !editables[index]!;
      _confirmarEditarHabito(index);
    });
  }

  void _borrarHabito(int index) {
    setState(() {
      // Lo borro asi tengo uno limpio cada vez que cree uno nuevo
      textEditingControllers[index]?.dispose();
      // Si no lo borro de la lista intentara usar el controlador que ha hecho .dispose()
      textEditingControllers.remove(index);
      listaHabitos.removeAt(index);
    });
  }

  // Por cada TextField le asignamos un controlador dinamicamente.
  TextEditingController _darControllador(int index) {
    // Nos aseguramos que si no existe le de uno nuevo.
    TextEditingController controllador =
        textEditingControllers[index] ?? TextEditingController();
    // Si esta en la lista es porque es un habito que ya tiene texto.
    controllador.text = listaHabitos[index].nombre;
    // Nos aseguramos que si no existia ahora este en el Map.
    textEditingControllers[index] = controllador;
    // Finalmente se lo damos al parametro controller:
    return controllador;
  }

  // Asignamos a cada TextField una variable individual de editable
  bool _darEditable(int index) {
    // Si no existe entonces le asignamos false.
    bool editable = editables[index] ?? false;
    // Aseguramos que si no existia lo metemos en el Map
    editables[index] = editable;
    // Finalmente le damos el valor a editable:
    return editable;
  }

  // Una vez ha sido editado tenemos que dar el nuevo valor del controllador a la listaHabitos.
  void _confirmarEditarHabito(int index) {
    Habito habito = listaHabitos[index];

    habito.nombre = textEditingControllers[index]?.text ?? '';
  }

  void _cambiarColorHabito(int index, Color color) {
    listaHabitos[index].color = color;
  }

  void _iconoSeleccion(Icon? icon, int index) {
    //guardamos el icon en el habito y comprobamos q no sea null antes de actualizar
    if (icon != null) {
      setState(() {
        listaHabitos[index].icono = icon;
      });
    }
  }
}
