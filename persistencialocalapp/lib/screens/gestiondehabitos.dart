import 'package:flutter/material.dart';

import '../services/preferenciasservice.dart';

import '../models/habito.dart';
import '../models/usuario.dart';

// Un enum para que sea mas legible que significa cada codigo de color.
enum NombreColores { naranja, azul, verde }

class Gestiondehabitos extends StatefulWidget {
  // Nos pasan usuario y preferencias service
  final PreferenciasService _preferenciasService;
  final Usuario _usuario;

  const Gestiondehabitos({
    super.key,
    required this._preferenciasService,
    required this._usuario,
  });

  @override
  State<Gestiondehabitos> createState() => _GestiondehabitosState();
}

class _GestiondehabitosState extends State<Gestiondehabitos> {
  // La lista de colores el cual usaremos el enum para que se vea cual es.
  final List<Color> listaColores = [
    Color(0xFFFFC067), // Naranja
    Color(0xFF6CCCC4), // Azul
    Color(0xFF807B44), // Verde
  ];

  late List<Habito> listaHabitos = widget._preferenciasService.cargarHabitos();

  /* Al ser una lista que cambia con el numero de habitos no puedo hardcodear
   * los editing controlers y una variable global de editar.
   * Asi que hago un Map para los controladores y los booleanos.
   * Map porque tengo que saber a cual pertenece mediante el indice.
   */
  Map<int, TextEditingController> textEditingControllers = {};
  Map<int, bool> editables = {};

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _darControllador(index),
                            enabled: _darEditable(index),
                            onEditingComplete: () {
                              setState(() {
                                editables[index] = !editables[index]!;
                                _editarHabito(index);
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(color: listaHabitos[index].color),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _cambiarColorHabito(
                                index,
                                listaColores[NombreColores.naranja.index],
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                listaColores[NombreColores.naranja.index],
                          ),
                          child: Text(''),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _cambiarColorHabito(
                                index,
                                listaColores[NombreColores.azul.index],
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                listaColores[NombreColores.azul.index],
                          ),
                          child: Text(''),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _cambiarColorHabito(
                                index,
                                listaColores[NombreColores.verde.index],
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                listaColores[NombreColores.verde.index],
                          ),
                          child: Text(''),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          child: Text('Edit'),
                          onPressed: () {
                            setState(() {
                              editables[index] = !editables[index]!;
                              if (!editables[index]!) _editarHabito(index);
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          child: Text('Remove'),
                          onPressed: () {
                            setState(() {
                              // Lo borro asi tengo uno limpio cada vez que cree uno nuevo
                              textEditingControllers[index]?.dispose();
                              // Si no lo borro de la lista intentara usar el controlador que ha hecho .dispose()
                              textEditingControllers.remove(index);
                              listaHabitos.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Crear'),
                onPressed: () {
                  setState(() {
                    listaHabitos.add(
                      Habito(
                        listaHabitos.length,
                        'Habito nuevo #${listaHabitos.length}',
                        listaColores[NombreColores.verde.index],
                        DateTime(0),
                      ),
                    );
                  });
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                child: Text('Guardar'),
                onPressed: () {
                  widget._preferenciasService.guardarHabitos(listaHabitos);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
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
  void _editarHabito(int index) {
    Habito habito = listaHabitos[index];

    habito.nombre = textEditingControllers[index]?.text ?? '';
    // Remplazamos el habito por el nuevo con el nuevo nombre
    habito = Habito(index, habito.nombre, habito.color, habito.fechaCompletado);
  }

  void _cambiarColorHabito(int index, Color color) {
    listaHabitos[index].color = color;
  }
}
