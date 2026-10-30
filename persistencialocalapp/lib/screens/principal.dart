import 'package:flutter/material.dart';

import '../services/preferenciasservice.dart';
import '../models/habito.dart';
import '../models/usuario.dart';
import 'ajustes.dart';
import 'estadisticas.dart';
import 'gestiondehabitos.dart';

class Principal extends StatefulWidget {
  // Nos pasan usuario y preferencias service
  final PreferenciasService _preferenciasService;
  final Usuario _usuario;

  const Principal({
    super.key,
    required this._preferenciasService,
    required this._usuario,
  });

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  // Cargamos la lista de habitos.
  late List<Habito> listaHabitos = widget._preferenciasService.cargarHabitos();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú principal')),
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
              SizedBox(height: 20),
              Text(
                'Has completado ${_contarHabitosCompletados()} de ${widget._usuario.numeroHabitos} habitos',
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: listaHabitos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: listaHabitos[index].completado,
                          onChanged: (bool? newValue) {
                            _completarHabito(newValue, index);
                          },
                        ),

                        Text(
                          softWrap: true,
                          '${listaHabitos[index].nombre} ${listaHabitos[index].completado ? listaHabitos[index].fechaCompletado : ''}',
                          style: TextStyle(color: listaHabitos[index].color),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _abrirGestionHabitos,
                child: const Text('Gestionar habitos'),
              ),

              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaAjustes(
                        preferenciasService: widget._preferenciasService,
                      ),
                    ),
                  );
                },
                child: Text('Ajustes'),
              ),

              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaEstadisticas(
                        preferenciasService: widget._preferenciasService,
                      ),
                    ),
                  );
                },
                child: Text('Estadísticas'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirGestionHabitos() async {
    // Esperamos a que la pagina vuelva.
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Gestiondehabitos(
          preferenciasService: widget._preferenciasService,
          usuario: widget._usuario,
        ),
      ),
    );
    // Cuando vuelva cargamos los datos nuevos y remplazamos.
    setState(() {
      listaHabitos = widget._preferenciasService.cargarHabitos();
    });
  }

  void _completarHabito(bool? newValue, int index) {
    /* Me parece que asignar una variable en dart asigna un puntero
     * porque si lo copiase tendria que remplazar el original que hay
     * en la lista pero funciona sin hacerlo.
     */
    Habito habito = listaHabitos[index];

    // Cuando cambia el CheckBox comprobamos a que y actualizamos pantalla.
    setState(() {
      if (newValue == null) return;
      if (newValue == false) {
        habito.completado = false;
        return;
      }

      habito.actualizarRacha();
      habito.fechaCompletado = DateTime.now();
      habito.completado = true;

      // Una vez esta hecho los cambios guardamos;
      widget._preferenciasService.guardarHabitos(listaHabitos);
    });
  }

  int _contarHabitosCompletados() {
    int contadorCompletados = 0;

    for (Habito habito in listaHabitos) {
      if (habito.completado) contadorCompletados++;
    }
    return contadorCompletados;
  }
}
